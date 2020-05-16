
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