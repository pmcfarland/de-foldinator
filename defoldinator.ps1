# @Author:	Patrick McFarland
# @Date:	06.02.2026

# This script is designed to help remove items from within multiple subfolders into the selected root folder.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-Folder {
    param(
        [string]$InitialDirectory = ""
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select a root folder"
    $dialog.SelectedPath = $InitialDirectory

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }

    return $null
}

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$LogTextBox,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogTextBox.AppendText("[$timestamp] $Message`r`n")
    $LogTextBox.SelectionStart = $LogTextBox.Text.Length
    $LogTextBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Get-UniqueDestinationPath {
    param(
        [Parameter(Mandatory)]
        [string]$DestinationFolder,

        [Parameter(Mandatory)]
        [string]$FileName
    )

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $extension = [System.IO.Path]::GetExtension($FileName)

    $candidate = Join-Path $DestinationFolder $FileName
    $counter = 1

    while (Test-Path -LiteralPath $candidate) {
        $newName = "{0} ({1}){2}" -f $baseName, $counter, $extension
        $candidate = Join-Path $DestinationFolder $newName
        $counter++
    }

    return $candidate
}

function Move-FilesToRoot {
    param(
        [Parameter(Mandatory)]
        [string]$RootPath,

        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$LogTextBox,

        [Parameter(Mandatory)]
        [System.Windows.Forms.ProgressBar]$ProgressBar,

        [Parameter(Mandatory)]
        [System.Windows.Forms.Label]$ProgressLabel,

        [switch]$AutoRenameDuplicates,
        [switch]$RemoveEmptyFolders
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        throw "The selected root folder does not exist: $RootPath"
    }

    $rootItem = Get-Item -LiteralPath $RootPath
    $rootFullName = $rootItem.FullName.TrimEnd('\')

    Write-Log -LogTextBox $LogTextBox -Message "Starting extraction from root folder: $rootFullName"

    $files = Get-ChildItem -LiteralPath $RootPath -File -Recurse | Where-Object {
        $_.Directory.FullName.TrimEnd('\') -ne $rootFullName
    }

    $totalFiles = @($files).Count
    $ProgressBar.Minimum = 0
    $ProgressBar.Value = 0
    $ProgressBar.Maximum = if ($totalFiles -gt 0) { $totalFiles } else { 1 }
    $ProgressLabel.Text = "Progress: 0 / $totalFiles"

    $moved = 0
    $skipped = 0
    $renamed = 0
    $errors = 0
    $processed = 0

    foreach ($file in $files) {
        try {
            $destinationPath = Join-Path $rootFullName $file.Name

            if (Test-Path -LiteralPath $destinationPath) {
                if ($AutoRenameDuplicates) {
                    $newDestinationPath = Get-UniqueDestinationPath -DestinationFolder $rootFullName -FileName $file.Name
                    Move-Item -LiteralPath $file.FullName -Destination $newDestinationPath -ErrorAction Stop
                    $moved++
                    $renamed++
                    Write-Log -LogTextBox $LogTextBox -Message "Moved (renamed): '$($file.FullName)' -> '$newDestinationPath'"
                }
                else {
                    $skipped++
                    Write-Log -LogTextBox $LogTextBox -Message "Skipped duplicate: '$($file.FullName)'"
                }
            }
            else {
                Move-Item -LiteralPath $file.FullName -Destination $destinationPath -ErrorAction Stop
                $moved++
                Write-Log -LogTextBox $LogTextBox -Message "Moved: '$($file.FullName)' -> '$destinationPath'"
            }
        }
        catch {
            $errors++
            Write-Log -LogTextBox $LogTextBox -Message "ERROR moving '$($file.FullName)': $($_.Exception.Message)"
        }
        finally {
            $processed++
            if ($processed -le $ProgressBar.Maximum) {
                $ProgressBar.Value = $processed
            }
            $ProgressLabel.Text = "Progress: $processed / $totalFiles"
            [System.Windows.Forms.Application]::DoEvents()
        }
    }

    $removedFolders = 0

    if ($RemoveEmptyFolders) {
        Write-Log -LogTextBox $LogTextBox -Message "Removing empty subfolders..."

        $folders = Get-ChildItem -LiteralPath $RootPath -Directory -Recurse |
            Sort-Object FullName -Descending

        foreach ($folder in $folders) {
            try {
                $hasChildren = Get-ChildItem -LiteralPath $folder.FullName -Force -ErrorAction Stop
                if ($hasChildren.Count -eq 0) {
                    Remove-Item -LiteralPath $folder.FullName -Force -ErrorAction Stop
                    $removedFolders++
                    Write-Log -LogTextBox $LogTextBox -Message "Removed empty folder: '$($folder.FullName)'"
                }
            }
            catch {
                Write-Log -LogTextBox $LogTextBox -Message "ERROR removing folder '$($folder.FullName)': $($_.Exception.Message)"
            }
        }
    }

    Write-Log -LogTextBox $LogTextBox -Message "Extraction complete."
    $ProgressLabel.Text = "Progress: $processed / $totalFiles (Complete)"

    return [pscustomobject]@{
        Moved          = $moved
        Skipped        = $skipped
        Renamed        = $renamed
        Errors         = $errors
        RemovedFolders = $removedFolders
        TotalFiles     = $totalFiles
    }
}

# ----------------------------
# Build Form
# ----------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text = "De-Foldinator"
$form.Size = New-Object System.Drawing.Size(760, 580)
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(760, 580)

$instructionLabel = New-Object System.Windows.Forms.Label
$instructionLabel.Text = "Extract files from all subfolders into the selected root folder."
$instructionLabel.Location = New-Object System.Drawing.Point(20, 20)
$instructionLabel.AutoSize = $true
$form.Controls.Add($instructionLabel)

$rootLabel = New-Object System.Windows.Forms.Label
$rootLabel.Text = "Root Folder"
$rootLabel.Location = New-Object System.Drawing.Point(20, 55)
$rootLabel.AutoSize = $true
$form.Controls.Add($rootLabel)

$rootTextBox = New-Object System.Windows.Forms.TextBox
$rootTextBox.Location = New-Object System.Drawing.Point(20, 75)
$rootTextBox.Size = New-Object System.Drawing.Size(580, 22)
$rootTextBox.Anchor = "Top, Left, Right"
$rootTextBox.Text = "C:\"
$form.Controls.Add($rootTextBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse..."
$browseButton.Location = New-Object System.Drawing.Point(615, 73)
$browseButton.Size = New-Object System.Drawing.Size(100, 26)
$browseButton.Anchor = "Top, Right"
$form.Controls.Add($browseButton)

$autoRenameCheckBox = New-Object System.Windows.Forms.CheckBox
$autoRenameCheckBox.Text = "Auto-rename duplicate files"
$autoRenameCheckBox.Location = New-Object System.Drawing.Point(20, 115)
$autoRenameCheckBox.AutoSize = $true
$autoRenameCheckBox.Checked = $true
$form.Controls.Add($autoRenameCheckBox)

$removeEmptyFoldersCheckBox = New-Object System.Windows.Forms.CheckBox
$removeEmptyFoldersCheckBox.Text = "Remove empty subfolders after extraction"
$removeEmptyFoldersCheckBox.Location = New-Object System.Drawing.Point(250, 115)
$removeEmptyFoldersCheckBox.AutoSize = $true
$removeEmptyFoldersCheckBox.Checked = $true
$form.Controls.Add($removeEmptyFoldersCheckBox)

$extractButton = New-Object System.Windows.Forms.Button
$extractButton.Text = "Extract"
$extractButton.Location = New-Object System.Drawing.Point(20, 150)
$extractButton.Size = New-Object System.Drawing.Size(100, 32)
$form.Controls.Add($extractButton)

$clearLogButton = New-Object System.Windows.Forms.Button
$clearLogButton.Text = "Clear Log"
$clearLogButton.Location = New-Object System.Drawing.Point(130, 150)
$clearLogButton.Size = New-Object System.Drawing.Size(100, 32)
$form.Controls.Add($clearLogButton)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 200)
$progressBar.Size = New-Object System.Drawing.Size(695, 22)
$progressBar.Anchor = "Top, Left, Right"
$progressBar.Minimum = 0
$progressBar.Maximum = 1
$progressBar.Value = 0
$form.Controls.Add($progressBar)

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Text = "Progress: 0 / 0"
$progressLabel.Location = New-Object System.Drawing.Point(20, 230)
$progressLabel.AutoSize = $true
$form.Controls.Add($progressLabel)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Text = "Output Log"
$logLabel.Location = New-Object System.Drawing.Point(20, 260)
$logLabel.AutoSize = $true
$form.Controls.Add($logLabel)

$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Location = New-Object System.Drawing.Point(20, 280)
$logTextBox.Size = New-Object System.Drawing.Size(695, 220)
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.ReadOnly = $true
$logTextBox.Anchor = "Top, Bottom, Left, Right"
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($logTextBox)

# ----------------------------
# Events
# ----------------------------

$browseButton.Add_Click({
    $selectedFolder = Get-Folder -InitialDirectory $rootTextBox.Text
    if ($selectedFolder) {
        $rootTextBox.Text = $selectedFolder
        Write-Log -LogTextBox $logTextBox -Message "Selected root folder: $selectedFolder"
    }
})

$clearLogButton.Add_Click({
    $logTextBox.Clear()
})

$extractButton.Add_Click({
    $rootPath = $rootTextBox.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($rootPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select or enter a root folder.",
            "Missing Folder",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show(
            "The selected root folder is invalid or does not exist.",
            "Invalid Folder",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        "This will move all files from subfolders into the root folder. Continue?",
        "Confirm Extraction",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $extractButton.Enabled = $false
    $browseButton.Enabled = $false
    $clearLogButton.Enabled = $false

    try {
        Write-Log -LogTextBox $logTextBox -Message "----------------------------------------"

        $result = Move-FilesToRoot `
            -RootPath $rootPath `
            -LogTextBox $logTextBox `
            -ProgressBar $progressBar `
            -ProgressLabel $progressLabel `
            -AutoRenameDuplicates:($autoRenameCheckBox.Checked) `
            -RemoveEmptyFolders:($removeEmptyFoldersCheckBox.Checked)

        $summary = @"
Done.

Total files found: $($result.TotalFiles)
Moved files:       $($result.Moved)
Renamed files:     $($result.Renamed)
Skipped files:     $($result.Skipped)
Errors:            $($result.Errors)
Removed folders:   $($result.RemovedFolders)
"@

        Write-Log -LogTextBox $logTextBox -Message "Summary: Total=$($result.TotalFiles), Moved=$($result.Moved), Renamed=$($result.Renamed), Skipped=$($result.Skipped), Errors=$($result.Errors), RemovedFolders=$($result.RemovedFolders)"

        [System.Windows.Forms.MessageBox]::Show(
            $summary,
            "Extraction Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
    catch {
        Write-Log -LogTextBox $logTextBox -Message "FATAL ERROR: $($_.Exception.Message)"

        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    finally {
        $extractButton.Enabled = $true
        $browseButton.Enabled = $true
        $clearLogButton.Enabled = $true
    }
})

# ----------------------------
# Show Form
# ----------------------------

[void]$form.ShowDialog()
