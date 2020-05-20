
Import-Module .\GoProFileRenamer\GoProFileRenamer.psm1

# Variables
$workingfolder = "D:\03. Go Pro\2020-04-19 - Cycle - Shop and back\"
$cameraModel = "HERO5"
$outputfolder = $workingfolder

# Do the things
$sequences = Find-GoProPossibleSequences -workingFolder $workingfolder -cameraModel $cameraModel
foreach ($sequence in $sequences) {
    $sequenceObject = Find-GoProSequenceChildren -workingFolder $workingfolder -sequenceNumber $sequence.SequenceNumber -cameraModel $cameraModel
    New-GoProMergedFile -sequenceObject $sequenceObject -outputFolder $outputfolder
}

# Example to create a snip for police submission
# New-GoProPoliceSubmittableSnip -clipStartTime "01:04:10" -clipDuration 5 -inputFileName "C:\Users\beararmy\Desktop\2020-05-14-local-cycle\0552.mp4" -outputFileName "C:\Users\beararmy\Desktop\2020-05-14-local-cycle\AB12OOO-clip.mp4"
