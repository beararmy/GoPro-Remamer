function Find-PossibleSequences {
    param (
        [string]$workingFolder = ".",
        [string]$cameraModel,
        [string]$sequenceNumber

    )
    switch ( $cameraModel ) {
        HERO5 { $sequenceNumberRegex = "GOPR*MP4" }
    }

    if ($sequenceNumber) {
        $list = Get-ChildItem -Path $workingFolder -Filter $sequenceNumberRegex | Where-Object { $_.Name -match "$sequenceNumber" }
        $nameString = $list.Name.ToString()
        $sequenceNumber = ($nameString).SubString(4, 4)
        $fullWorkingPath = $workingFolder + $list.Name
        [pscustomobject]$output = [PSCustomObject]@{
            SequenceNumber   = $sequenceNumber
            SequenceFilename = $list.Name
            FullPath         = $fullWorkingPath
            var4 = "test"

        }
        return $output
    } else {
        Write-Error "Failed to identify any Sequences"
        return $false
    }

    $list = Get-ChildItem -Path $workingFolder -Filter $sequenceNumberRegex 
    [pscustomobject]$output = foreach ($listitem in $list) {
        $nameString = $listitem.Name.ToString()
        $sequenceNumber = ($nameString).SubString(4, 4)
        $fullWorkingPath = $workingFolder + $listitem.Name
        Write-Verbose "Found $($listitem.Name) as Sequence number $sequenceNumber. File is at $fullWorkingPath"
        [PSCustomObject]@{
            SequenceNumber   = $sequenceNumber
            SequenceFilename = $listitem.Name
            FullPath         = $fullWorkingPath
            var4 = "test"

        }
    }
    return $output
}


function Find-SequenceChildren {
    param (
        [string]$workingFolder = ".",
        [string]$cameraModel,
        [string]$sequenceNumber,
        [string]$sequenceFilename,
        [bool]$includeParent = $true,
        [parameter(ValueFromPipeline = $true)]$pipelineInput
    )
$pipelineInput
    switch ( $cameraModel ) {
        HERO5 { $sequenceString = ("GP*" + $sequenceNumber + ".MP4") }
    }
    Write-Verbose "Found $($listitem.Name) as Sequence number $sequenceNumber. File is at $fullWorkingPath"
    if ($includeParent) {
        $output1 = Find-PossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel -sequenceNumber $sequenceNumber
    }
    $list = Get-ChildItem -Path $workingFolder -Filter $sequenceString
    [pscustomobject]$output2 = foreach ($listitem in $list) {
        $fullWorkingPath = $workingFolder + $listitem.Name
        Write-Verbose "Found $($listitem.Name). File is at $fullWorkingPath"
        [PSCustomObject]@{
            SequenceNumber   = $sequenceNumber
            SequenceFilename = $listitem.Name
            FullPath         = $fullWorkingPath
            var4 = "test"

        }
    }

$object3 = "boobs"
[pscustomobject]$return = $object1 + $object2
    #return $output1, $output2, $object3
    return $return
}



$workingFolder = "D:\03. Go Pro\2020-04-05 - Cycle - to Rackspace and back\"
$cameraModel = "HERO5"

# Find-PossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel
# Find-PossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel -sequenceNumber 0533

$files = ( Find-SequenceChildren -workingFolder $workingfolder -cameraModel $cameraModel -sequenceNumber 0532 )

Write-Verbose "I found $($files.count) files to process"