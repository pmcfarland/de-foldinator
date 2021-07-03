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
