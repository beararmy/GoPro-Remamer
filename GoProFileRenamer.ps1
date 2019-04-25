$workingFolder = "J:\03. Go Pro\2019-04-21 Diving - Puffin Island"
$KeepJunk = $True
$AdditionalFilesFolder = "GoPro-Additional"
$GoodFormat = "*.MP4"
$ffmpegbinary = ""
$MakeChanges = $True
$FirstFileCatch = "GOPR*MP4"
start-sleep 5
Write-Verbose "Running in $WorkingFolder and KeepJunk is set to $KeepJUnk on this run"
$filelist = (Get-ChildItem -Path $workingFolder)

if ($MakeChanges) {
    write-Verbose "Make Changes set to true. Moving Primary files. Bahahaha."
}
else {
    write-Verbose "Make Changes set to false. NOT Moving Primary files. D'awwww :("
}

foreach ($Name in $filelist) {

    if ($Name -like $FirstFileCatch) {
        Write-Verbose "Found $Name to work on"
        $NameString = $Name.ToString()
        $SequenceNumber = $NameString.SubString(4, 4)
        Write-Verbose "Video Sequence Number is $SequenceNumber"
        $PrimaryCopyPath = $workingFolder + "\" + $Name
        $PrimaryCopyDestination = $workingFolder + "\" + "$SequenceNumber-Part01.mp4"
        if ($MakeChanges) {
            write-Verbose "Make Changes set to true. Moving Primary files"
            Write-Verbose "Moving $PrimaryCopyPath over to $SequenceNumber-Part01.mp4"
            # I think this first one is dead now
            #Move-Item -Path $PrimaryCopyPath -Destination "$SequenceNumber-Part01.mp4"
            Move-Item -Path $PrimaryCopyPath -Destination $PrimaryCopyDestination

        }
        else {
            write-Verbose "Make Changes set to false. NOT Moving Primary files"
            Write-Verbose "[PRETEND] Moving $PrimaryCopyPath over to $SequenceNumber-Part01.mp4"
        }
        # Start with 1 as that's what gopro does
        $x = 1
        $SequenceString = ("GP*" + $SequenceNumber + ".MP4")
        Get-ChildItem -Filter $SequenceString
        $y = 0 #Here while I'm working on this script
        $y = ((Get-ChildItem -path $workingFolder $SequenceString).Count + 1)
        if ($y -ne 1) {
            Write-Verbose "I found $($y-1) Secondary files using $SequenceString for $SequenceNumber"
            while ($x -lt $y) {
                $SegmentNumber = $x

                $SecondaryFileName = ("GP0" + $SegmentNumber + $SequenceNumber + ".MP4")
                $SecondaryCopyPath = $workingFolder + "\" + $SecondaryFileName
                $SecondaryCopyDestination = $workingFolder + "\" + "$SequenceNumber-Part0$($SegmentNumber+1).mp4"

                if ($MakeChanges) {
                    write-Verbose "Make Changes set to true. Moving Secondary files"
                    Write-Verbose "Moving $SecondaryCopyPath over to $SecondaryCopyDestination"
                    Move-Item -Path $SecondaryCopyPath -Destination $SecondaryCopyDestination
                }
                else {
                    write-Verbose "Make Changes set to true. NOT Moving Secondary files"
                    Write-Verbose "[PRETEND] Moving $SecondaryCopyPath over to $SecondaryCopyDestination"
                }

                Write-Debug "x is $x and y is $y"
                $x++
            }
            #GoPro Trash
        }
    }

    if ( (Get-ChildItem $workingFolder -Filter *LRV -Recurse).Count -eq 0 -and ((Get-ChildItem $workingFolder -Filter *THM -Recurse).Count -eq 0)) {
        Write-Verbose "No additional files exist in $WorkingFolder, quitting"
    }
    else {
        Write-Verbose "Some additional files found, continuing"
        if ($MakeChanges) {
            $AdditionalCopyDestination = $workingFolder + "\" + $AdditionalFilesFolder
            write-Verbose "Make Changes set to true. Moving GoPro Additional files"
        
            if (Test-Path -PathType Container $AdditionalCopyDestination) {
                write-verbose "$AdditionalCopyDestination already exists, doing nothing for now"                
            }
            else {
                write-verbose "$AdditionalCopyDestination Does not exist, creating folder."                
                New-Item -ItemType directory -Path $AdditionalCopyDestination
            }
            #Moving Low Resolution files
            Move-Item -Path $workingFolder\*.LRV -Destination $AdditionalCopyDestination
            #Moving Low Resolution THM files
            Move-Item -Path $workingFolder\*.THM -Destination $AdditionalCopyDestination
        }
        else {
            write-Verbose "Make Changes set to true. NOT Moving Additional files"
            Write-Verbose "[PRETEND] Moving all .LRV and .THM files from workingFolder"
        }
    }
}