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
 

<img width="740" height="570" alt="defoldinator" src="https://github.com/user-attachments/assets/d02c2927-7b57-43a2-ae12-000bbbe4d29e" />




I have added a compiled .exe to make things easier, but obviously don't just trust random strangers on the internet who tell you to run .exes. Here is the file hash for the .exe that I compiled from .ps1 to .exe using [PS2EXE](https://github.com/MScholtes/PS2EXE).
 
I did submit it to VirusTotal and got some false positives but feel free to check for yourself.

https://www.virustotal.com/gui/file/25211ce734225795cc690138f7b5410ceb0d8d106c40dad8f288d41ea9511b69
