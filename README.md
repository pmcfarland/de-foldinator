# de-foldinator


This is a simple script for extracting the contents of multiple subfolders into a selected root folder.

For example you might have a folder structure like this:


Downloads
 - Folder1
    * File1.txt
    * File2.docx
    * File3.zip
 - Folder2
    - Folder3
        * File4.mp3
        * File5.lnk
    * File7.dll
    
However after running this script when pointed at the Downloads folder you would see:


Downloads
 - Folder1
 - Folder2
    - Folder3
 * File1.txt
 * File2.docx
 * File3.zip
 * File4.mp3
 * File5.lnk
 * File7.dll
 
 Note the folders are still there, just their contents have been moved up to the Downloads location.


![defoldinator](https://user-images.githubusercontent.com/13721267/124361070-204b1d80-dbfb-11eb-9e38-dbc98a59f6e8.png)


I have added a compiled .exe to make things easier, but obviously don't just trust random strangers on the internet who tell you to run .exes. Here is the file hash for the .exe that I compiled from .ps1 to .exe using [PS2EXE](https://github.com/MScholtes/PS2EXE).

     SHA256          EDCFECEF5217F3B9E3B5C9589E9EC81283DFD479EB5C343DBFB032DFBFD2E807

I did submit it to VirusTotal and got some false positives but feel free to check for yourself.

https://www.virustotal.com/gui/file/edcfecef5217f3b9e3b5c9589e9ec81283dfd479eb5c343dbfb032dfbfd2e807/detection
