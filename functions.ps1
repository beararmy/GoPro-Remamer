function Find-GoProPossibleSequences {
    param (
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            return $true
        })]
        [string]$workingFolder,
        [string]$cameraModel = "HERO5"
    )
    switch ( $cameraModel ) {
        HERO5 { $sequenceNumberRegex = "GOPR*MP4" }
    }
    # Find possible sequences
    $list = Get-ChildItem -Path $workingFolder -Filter $sequenceNumberRegex 
    [pscustomobject]$output = foreach ($listitem in $list) {
        $nameString = $listitem.Name.ToString()
        $sequenceNumber = ($nameString).SubString(4, 4)
        $fullWorkingPath = $workingFolder + $listitem.Name
        Write-Host "Found $($listitem.Name) as Sequence number $sequenceNumber. File is at $fullWorkingPath"
        [PSCustomObject]@{
            SequenceNumber   = $sequenceNumber
            SequenceFilename = $listitem.Name
            FullPath         = $fullWorkingPath
        }
    }
    return $output
}
function Find-GoProSequenceChildren {
    param (
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            return $true
        })]
        [string]$workingFolder,
        [string]$cameraModel,
        [ValidatePattern("[0-9][0-9][0-9][0-9]")]
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
        Write-Host "Found $($file.Name). File is at $fullWorkingPath"
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
function New-GoProMergedFile {
    param (
        $sequenceObject,
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            return $true
        })]
        [string]$outputFolder,
        [string]$outputfilename
    )

    # Check for disk space
    # If no filename sequence.mp4
    # Make ffmpeg bit less hideous

    $mergefilepath = $outputFolder + $sequenceObject[0].SequenceNumber + ".txt"
    New-item -Force $mergefilepath 
    Write-Verbose "Merging $($sequenceObject.Count) files."
    foreach ($file in $sequenceObject) {
        $linetoadd = "file `'$($file.FullPath)`'"
        Add-Content -Path $mergefilepath -Value $linetoadd
    }
    if (!(Test-Path .\ffmpeg.exe -PathType Leaf)) {
        Write-Error "ffmpeg.exe not found - Please copy ffmpeg.exe into this folder"
    }
    else {
        $version = (.\ffmpeg.exe -version)
        Write-Verbose "FFmpeg found, version as: $($version[0])"
    }
    $outputfilepath = $outputFolder + $sequenceObject[0].SequenceNumber + ".mp4"
    $startpath = "./ffmpeg.exe"
    $startarguments = " -f concat -safe 0 -i `"$mergefilepath`" -c copy `"$outputfilepath`""
    Start-Process -wait -FilePath $startpath -ArgumentList $startarguments

    
}

#Find-GoProPossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel

$sequenceObject = Find-GoProSequenceChildren -workingFolder $workingFolder -cameraModel $cameraModel -sequenceNumber 0549

New-GoProMergedFile -sequenceObject $sequenceObject -outputFolder $outputfolder