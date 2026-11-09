#requires -Version 5.1
<#
.SYNOPSIS
Report only a backup container's type and allowlisted outer format metadata.
.DESCRIPTION
Requires explicit approval for this narrow exception to the backup-inspection
boundary. Searches only the given folder's immediate children for disk-image
extensions. Candidate names are used in memory, never printed or saved. Reads
only Info.plist for a single sparsebundle/backupbundle, at most 64 KiB. Does not
open image bands, mount an image, inspect backup contents, or change files.
This is not a backup integrity test or a Time Machine compatibility verdict.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ContainerParent
)

$summary = [ordered]@{
    Status = 'unavailable'
    CandidateCount = 0
    ContainerType = $null
    OuterMetadata = 'not_read'
    VirtualCapacityBytes = $null
    BandSizeBytes = $null
    BackingStoreVersion = $null
    StandardSparseBundleType = $null
    Integrity = 'not_tested'
}

try {
    $root = [System.IO.Path]::GetFullPath($ContainerParent)
    $rootAttributes = [System.IO.File]::GetAttributes($root)
    if (($rootAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
        ($rootAttributes -band [System.IO.FileAttributes]::Directory) -eq 0) {
        throw 'The supplied folder must be a regular directory.'
    }
    $candidates = New-Object 'System.Collections.Generic.List[string]'
    foreach ($extension in @('.sparsebundle', '.backupbundle', '.sparseimage', '.dmg')) {
        foreach ($candidate in [System.IO.Directory]::EnumerateFileSystemEntries(
            $root, ('*' + $extension), [System.IO.SearchOption]::TopDirectoryOnly)) {
            if ([System.IO.Path]::GetExtension($candidate) -ine $extension) { continue }
            $candidates.Add($candidate)
            if ($candidates.Count -gt 1) { break }
        }
        if ($candidates.Count -gt 1) { break }
    }
    $summary.CandidateCount = $candidates.Count
    if ($candidates.Count -eq 0) {
        $summary.Status = 'no_matching_container'
    } elseif ($candidates.Count -gt 1) {
        $summary.Status = 'multiple_containers_no_selection'
    } else {
        $candidate = $candidates[0]
        $attributes = [System.IO.File]::GetAttributes($candidate)
        if (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Reparse-point containers are not inspected.'
        }
        $summary.ContainerType = [System.IO.Path]::GetExtension($candidate).ToLowerInvariant()
        $summary.Status = 'container_identified'
        if ($summary.ContainerType -in @('.sparsebundle', '.backupbundle') -and
            ($attributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
            $infoPath = [System.IO.Path]::Combine($candidate, 'Info.plist')
            $infoAttributes = [System.IO.File]::GetAttributes($infoPath)
            if (($infoAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw 'Reparse-point metadata is not inspected.'
            }
            $stream = $null
            $reader = $null
            try {
                $stream = [System.IO.File]::Open($infoPath,
                    [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read,
                    [System.IO.FileShare]::ReadWrite)
                if ($stream.Length -gt 65536) { throw 'Metadata exceeds the read limit.' }
                $settings = New-Object System.Xml.XmlReaderSettings
                $settings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore
                $settings.XmlResolver = $null
                $settings.MaxCharactersInDocument = 65536
                $reader = [System.Xml.XmlReader]::Create($stream, $settings)
                $document = New-Object System.Xml.XmlDocument
                $document.XmlResolver = $null
                $document.Load($reader)
                $dictionary = $document.SelectSingleNode('/plist/dict')
                if ($null -eq $dictionary) { throw 'Unsupported metadata structure.' }
                $fields = @{
                    'size' = 'VirtualCapacityBytes'
                    'band-size' = 'BandSizeBytes'
                    'bundle-backingstore-version' = 'BackingStoreVersion'
                }
                foreach ($key in $dictionary.SelectNodes('key')) {
                    $value = $key.NextSibling
                    if ($null -eq $value) { continue }
                    if ($fields.ContainsKey($key.InnerText) -and $value.Name -eq 'integer') {
                        $number = 0L
                        if ([long]::TryParse($value.InnerText, [ref]$number) -and $number -gt 0) {
                            $summary[$fields[$key.InnerText]] = $number
                        }
                    } elseif ($key.InnerText -eq 'diskimage-bundle-type' -and $value.Name -eq 'string') {
                        $summary.StandardSparseBundleType = ($value.InnerText -eq 'com.apple.diskimage.sparsebundle')
                    }
                }
                $summary.OuterMetadata = 'allowlisted_xml_fields_read'
            } finally {
                if ($null -ne $reader) { $reader.Dispose() }
                if ($null -ne $stream) { $stream.Dispose() }
            }
        }
    }
} catch {
    $summary.Status = 'inconclusive'
    $summary.OuterMetadata = 'unavailable_or_unsupported'
    # Never disclose exception text, paths, identifiers, or unrecognized values.
}
$summary | ConvertTo-Json -Depth 3
