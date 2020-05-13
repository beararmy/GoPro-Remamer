function Find-GoProPossibleSequences {
    param (
        [string]$workingFolder = ".",
        [string]$cameraModel = "HERO5",
        [string]$sequenceNumber

    )
    switch ( $cameraModel ) {
        HERO5 { $sequenceNumberRegex = "GOPR*MP4" }
    }

    # if ($sequenceNumber) {
    #     $list = Get-ChildItem -Path $workingFolder -Filter $sequenceNumberRegex | Where-Object { $_.Name -match "$sequenceNumber" }
    #     $nameString = $list.Name.ToString()
    #     $sequenceNumber = ($nameString).SubString(4, 4)
    #     $fullWorkingPath = $workingFolder + $list.Name
    #     [pscustomobject]$output = [PSCustomObject]@{
    #         SequenceNumber   = $sequenceNumber
    #         SequenceFilename = $list.Name
    #         FullPath         = $fullWorkingPath
    #         var4 = "test"

    #     }
    #     return $output
    # } else {
    #     Write-Error "Failed to identify any Sequences"
    #     return $false
    # }

    # Find possible sequences
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
            #var4 = "test"

        }
    }
    return $output
}
function Find-GoProSequenceChildren {
    param (
        [string]$workingFolder,
        [string]$cameraModel,
        [string]$sequenceNumber
    )   
    switch ( $cameraModel ) {
        HERO5 {
            $sequenceChildrenRegex = ( "GP*" + $sequenceNumber + ".MP4")
            $sequenceParentalRegex = "GOPR*MP4" 
        }
    }
    $filelist = Get-ChildItem -Path $workingFolder -Filter $sequenceParentalRegex | Where-Object { $_.Name -match "$sequenceNumber" }
    $nameString = $filelist.Name.ToString()
    $fullWorkingPath = $workingFolder + $filelist.Name
    Write-Host "Found $nameString. File is at $fullWorkingPath"
    [int]$childCounter = 1
    $parentfile = [pscustomobject]@{
        FileNumber       = $childCounter
        SequenceNumber   = $sequenceNumber
        SequenceFilename = $nameString
        FullPath         = $fullWorkingPath
    }
    $childCounter++
    $filelist = Get-ChildItem -Path $workingFolder -Filter $sequenceChildrenRegex
    $childrenfiles = foreach ( $file in $filelist ) {
        $fullWorkingPath = $workingFolder + $file.Name
        Write-Verbose "Found $($file.Name). File is at $fullWorkingPath"
        [PSCustomObject]@{
            FileNumber       = $childCounter
            SequenceNumber   = $sequenceNumber
            SequenceFilename = $file.Name
            FullPath         = $fullWorkingPath
        }
        $childCounter++
    }
    $parentfile
    $childrenfiles
}


[string]$workingFolder = "C:\Users\msn\Desktop\testfolder\"
[string]$cameraModel = "HERO5"
[string]$sequenceNumber = "0548"

Find-GoProSequenceChildren -workingFolder $workingFolder -cameraModel $cameraModel -sequenceNumber 0548

Find-GoProPossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel
