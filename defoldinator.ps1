# @Author:	Patrick McFarland
# @Date:	07.03.2021

# This script is designed to help remove items from within multiple subfolders into the selected root folder.

Add-Type -assembly System.Windows.Forms

#creates new form
$main_form = New-Object System.Windows.Forms.Form

#sets the initial atributes of the form
$main_form.Text ='De-Foldinator'
$main_form.Width = 550
$main_form.Height = 300
$main_form.AutoSize = $true

#creating a label for instructions
$Label0 = New-Object System.Windows.Forms.Label
$Label0.Text = "This script will extract the contents of all subfolers into the selected root folder"
$Label0.Location  = New-Object System.Drawing.Point(70,10)
$Label0.AutoSize = $true
$main_form.Controls.Add($Label0)

#creating a label for folder chooser
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Root Folder"
$Label.Location  = New-Object System.Drawing.Point(55,90)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

#creating a textbox for current location
$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(40,110)
$textBox1AutoSize = $true
$textBox1.Text = "C:\"
$main_form.Controls.Add($textBox1)

#picking the root directory
Function Get-Folder($initialDirectory="")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#adds button to trigger folder picker dialog
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(210,60)
$Button.Size = New-Object System.Drawing.Size(120,25)
$Button.Text = "Choose Root Folder"
$main_form.Controls.Add($Button)

$Button.Add_Click(
{
	$a = Get-Folder
	$textBox1.text = $a
}
)

#adds button to extract contents of subfolders
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Size(210,160)
$Button2.Size = New-Object System.Drawing.Size(120,60)
$Button2.Text = "Extract"
$main_form.Controls.Add($Button2)

$Button2.Add_Click(
{
	cd $textBox1.text
	Get-ChildItem -File -Recurse | Move-Item -Destination .
	
	$pop = new-object -comobject wscript.shell
	$pop2 = $pop.popup("Files Extracted",0,"Extracted",1)
}
)

#displays the gui
$main_form.ShowDialog()