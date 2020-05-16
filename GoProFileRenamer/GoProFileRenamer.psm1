<#
 .Synopsis
  Tools to work with Gopro HERO5 video files

 .Description
  Small set of tools that will help to merge a set of gopro files into one large file

 .Parameter cameraModel
  Model of GoPro, currently only HERO5 accepted, add more in switch.

 .Parameter workingfolder
  [String]Folder where files are located.

 .Parameter outputfolder
  [String]Folder where merged file is to be created.

 .Parameter sequenceNumber
  [String]Specific four digit number for that video sequence.

 .Parameter outputfilename
  [String]Short filename of merged output file, ie output.mp4.
   
  .Parameter sequenceObject
  [pscustomobject]Object will all files (in order) to be merged.

 .Example
   # Find all of the video sequences in a folder
   Find-GoProPossibleSequences -workingFolder "C:\Users\beararmy\Desktop\2020-05-14-local-cycle\" -cameraModel "HERO5"

 .Example
   # Find all of the files in a particular sequence
   Find-GoProSequenceChildren -workingFolder $workingfolder -cameraModel $cameraModel -sequenceNumber "0413"

 .Example
   # Merge an entire sequence based on an object from Find-GoProSequenceChildren
   New-GoProMergedFile -sequenceObject $sequenceObject -outputFolder $outputfolder
#>  

function Find-GoProPossibleSequences {
    param (
        [ValidateScript( {
                if ( -Not ($_ | Test-Path) ) {
                    throw "Folder does not exist"
                }
                return $true
            })]
        [string]$workingFolder,
        [Parameter(Mandatory = $True)]
        [string]$cameraModel
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
        [ValidateScript( {
                if ( -Not ($_ | Test-Path) ) {
                    throw "Folder does not exist"
                }
                return $true
            })]
        [string]$workingFolder,
        [Parameter(Mandatory = $True)]
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
        [Parameter(Mandatory = $True)]
        [ValidateScript( {
                if ( -Not ($_ | Test-Path) ) {
                    throw "Folder does not exist"
                }
                return $true
            })]
        [string]$outputFolder,
        [string]$outputfilename
    )

    # Validate free space
    $driveletter = $outputFolder.Substring(0, 1)
    foreach ($file in $sequenceObject) {
        $totalSpaceEstimate = $totalSpaceEstimate + (Get-ChildItem $file.FullPath).Length
    }
    $driveFreeSpace = (Get-Volume $driveletter).SizeRemaining
    if ($driveFreeSpace -lt $totalSpaceEstimate) {
        Throw "Insufficient drive space on $driveletter to merge."
    }
    
    # Prepare the things
    $mergefilepath = $outputFolder + $sequenceObject[0].SequenceNumber + ".txt"
    New-item -Force $mergefilepath 
    Write-Verbose "Merging $($sequenceObject.Count) files."
    foreach ($file in $sequenceObject) {
        $linetoadd = "file `'$($file.FullPath)`'"
        Add-Content -Path $mergefilepath -Value $linetoadd
    }
    if (!(Test-Path .\ffmpeg.exe -PathType Leaf)) {
        Write-Verbose "ffmpeg.exe not found - Downloading"
        # Get the zip file
        $ffmpegURI = "https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip"
        $ffmpegZIP = ".\ffmpeg-latest-win64-static.zip"
        Invoke-WebRequest -Uri $ffmpegURI -OutFile $ffmpegZIP

        # Extract the zip file
        $extractedPath = "."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $extractedPath)

        # Delete everything but ffmpeg.exe
        Move-Item -Force ".\ffmpeg-latest-win64-static\bin\ffmpeg.exe" ".\ffmpeg.exe"
        Remove-Item -Force ".\ffmpeg-latest-win64-static\" -Recurse 
        remove-item -Force -confirm:$false "ffmpeg-latest-win64-static.zip"
    }
    else {
        $version = (.\ffmpeg.exe -version)
        Write-Verbose "FFmpeg found, version as: $($version[0])"
    }

    if (!($outputfilename)) {
        $outputfilepath = $outputFolder + $sequenceObject[0].SequenceNumber + ".mp4"
    }
    else {
        $outputfilepath = $outputFolder + $outputfilename
    }
    
    # Do the merge
    $startpath = "./ffmpeg.exe"
    $startarguments = " -f concat -safe 0 -i `"$mergefilepath`" -c copy `"$outputfilepath`""
    $proc = Start-Process -wait -FilePath $startpath -ArgumentList $startarguments -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Warning "$_ exited with status code $($proc.ExitCode)"
    }
    else {
        Write-Host "Appears that merge was successful! Hurray!"
    }

    # Cleanup
    Remove-Item -Force $mergefilepath
}

Export-ModuleMember -Function Find-GoProPossibleSequences, Find-GoProSequenceChildren, New-GoProMergedFile
