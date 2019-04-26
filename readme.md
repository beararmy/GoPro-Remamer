## GoProRenamer

Script to rename the poorly (*imo*) named GoPro files into something more logical / nicer to play with. While this is not a life-ending feature of the GoPro it does mean that things don't sort nicely and when I come to join them there's always some level of thinking and referring to their [documentation](https://gopro.com/help/articles/question_answer/GoPro-Camera-File-Naming-Convention) involved.

|                |Before                    |After                      |
|----------------|--------------------------|---------------------------|
|1st File        |`GOPR0472.MP4`            |`0472-Part01.mp4`          |
|2nd File        |`GP010472.MP4`            |`0472-Part01.mp4`          |
|3rd File        |`GP020472.MP4`            |`0472-Part01.mp4`          |

### Usage
`GoProRenamer.ps1 -workingFolder <folder to work in>`

### Todo list
- Make it a function
- Validate behaviour when you have multiple recordings in the same folder
- Add a proper comment block
- Consider getting rid of verbose waffle
- Include the option to merge the files into one video (mpg123?)