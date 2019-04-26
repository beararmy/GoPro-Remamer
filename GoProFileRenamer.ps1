param (
    [string]$workingFolder = ".",
    [string]$additionalFilesFolder = "GoPro-Additional",
    [bool]$keepJunk = $True,
    [bool]$makeChanges = $True
)
$firstFileCatch = "GOPR*MP4"

Write-Verbose "Running in $workingFolder and KeepJunk is set to $keepJunk on this run, continuing"
$filelist = (Get-ChildItem -Path $workingFolder)

foreach ($name in $filelist) {

    if ($name -like $firstFileCatch) {
        Write-Verbose "Found $name to work on"
        $nameString = $name.ToString()
        $sequenceNumber = $nameString.SubString(4, 4)
        Write-Verbose "Video Sequence Number is $sequenceNumber"
        $primaryCopyPath = $workingFolder + "\" + $name
        $primaryCopyDestination = $workingFolder + "\" + "$sequenceNumber-Part01.mp4"
        if ($makeChanges) {
            Write-Verbose "Make Changes set to true. Moving Primary files, continuing"
            Write-Verbose "Moving $primaryCopyPath over to $sequenceNumber-Part01.mp4"
            Move-Item -Path $primaryCopyPath -Destination $primaryCopyDestination
        }
        else {
            Write-Verbose "Make Changes set to False. NOT Moving Primary files, continuing"
        }
        # Start with 1 as that's what gopro does
        $x = 1
        $sequenceString = ("GP*" + $sequenceNumber + ".MP4")
        Get-ChildItem -Filter $sequenceString
        $y = ((Get-ChildItem -path $workingFolder $sequenceString).Count + 1)
        if ($y -ne 1) {
            Write-Verbose "I found $($y-1) Secondary files using $sequenceString for $sequenceNumber, continuing"
            while ($x -lt $y) {
                $segmentNumber = $x
                $secondaryFileName = ("GP0" + $segmentNumber + $sequenceNumber + ".MP4")
                $secondaryCopyPath = $workingFolder + "\" + $secondaryFileName
                $secondaryCopyDestination = $workingFolder + "\" + "$sequenceNumber-Part0$($segmentNumber+1).mp4"
                if ($makeChanges) {
                    Write-Verbose "Moving $secondaryCopyPath over to $secondaryCopyDestination, continuing"
                    Move-Item -Path $secondaryCopyPath -Destination $secondaryCopyDestination
                }
                else {
                    Write-Verbose "Make Changes set to False. NOT Moving Secondary files, continuing"
                }
                $x++
            }
            #GoPro Trash
        }
    }

    if ( (Get-ChildItem $workingFolder -Filter *LRV -Recurse).Count -eq 0 -and ((Get-ChildItem $workingFolder -Filter *THM -Recurse).Count -eq 0)) {
        Write-Verbose "No additional files exist in $workingFolder, exiting"
    }
    else {
        Write-Verbose "Additional files found, continuing"
        if ($makeChanges) {
            $additionalCopyDestination = $workingFolder + "\" + $additionalFilesFolder        
            if (Test-Path -PathType Container $additionalCopyDestination) {
                Write-verbose "$additionalCopyDestination already exists, continuing"                
            }
            else {
                Write-Verbose "$additionalCopyDestination does not exist, creating"                
                New-Item -ItemType directory -Path $additionalCopyDestination
            }
            #Moving Low Resolution files
            Move-Item -Path $workingFolder\*.LRV -Destination $additionalCopyDestination
            #Moving Low Resolution THM files
            Move-Item -Path $workingFolder\*.THM -Destination $additionalCopyDestination
        }
        else {
            Write-Verbose "Make Changes set to False. NOT Moving Additional files, continuing"
        }
    }
}