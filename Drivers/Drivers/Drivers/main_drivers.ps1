﻿<#
.SYNOPSIS
    Driver Installer with Graphical Progress
.DESCRIPTION
    Shows professional progress bars with percentages
    All files in script directory
.NOTES
    File Name      : DriverInstaller_WithGUI.ps1
    Author         : Laptop Store IQ Developers
    Requires       : PowerShell 5.1+ (Run as Administrator)
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# Color scheme
$primaryColor = [System.Drawing.Color]::FromArgb(0, 120, 84) # Dark green
$secondaryColor = [System.Drawing.Color]::FromArgb(240, 240, 240) # Light gray
$accentColor = [System.Drawing.Color]::FromArgb(0, 168, 107) # Bright green
$textColor = [System.Drawing.Color]::FromArgb(64, 64, 64) # Dark gray

# Get script directory
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Get-Location }

# Password check before proceeding
$passwordForm = New-Object System.Windows.Forms.Form
$passwordForm.Text = "Authentication Required"
$passwordForm.Size = New-Object System.Drawing.Size(350, 200)
$passwordForm.StartPosition = "CenterScreen"
$passwordForm.FormBorderStyle = "FixedDialog"
$passwordForm.MaximizeBox = $false
$passwordForm.BackColor = $secondaryColor

$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Point(20, 20)
$passwordLabel.Size = New-Object System.Drawing.Size(300, 30)
$passwordLabel.Text = "Enter access code to continue:"
$passwordLabel.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$passwordForm.Controls.Add($passwordLabel)

$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Point(50, 60)
$passwordBox.Size = New-Object System.Drawing.Size(250, 30)
$passwordBox.PasswordChar = '*'
$passwordForm.Controls.Add($passwordBox)

$passwordButton = New-Object System.Windows.Forms.Button
$passwordButton.Location = New-Object System.Drawing.Point(125, 100)
$passwordButton.Size = New-Object System.Drawing.Size(100, 30)
$passwordButton.Text = "Continue"
$passwordButton.BackColor = $primaryColor
$passwordButton.ForeColor = [System.Drawing.Color]::White
$passwordButton.FlatStyle = "Flat"
$passwordButton.FlatAppearance.BorderSize = 0
$passwordButton.Add_Click({
    if ($passwordBox.Text -eq "laptopstore25") {
        $passwordForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $passwordForm.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Incorrect code. Please try again.", "Access Denied", "OK", "Warning")
        $passwordBox.Text = ""
    }
})
$passwordForm.Controls.Add($passwordButton)

$passwordForm.AcceptButton = $passwordButton
$result = $passwordForm.ShowDialog()

if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    exit
}

# Initialize form with modern styling
$form = New-Object System.Windows.Forms.Form
$form.Text = "Laptop Store IQ - Driver Installation"
$form.Size = New-Object System.Drawing.Size(650, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $secondaryColor
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Header panel
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.Size = New-Object System.Drawing.Size(650, 80)
$headerPanel.BackColor = $primaryColor
$form.Controls.Add($headerPanel)

# Header label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Location = New-Object System.Drawing.Point(20, 20)
$headerLabel.Size = New-Object System.Drawing.Size(600, 40)
$headerLabel.Text = "Driver Installation"
$headerLabel.ForeColor = [System.Drawing.Color]::White
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$headerPanel.Controls.Add($headerLabel)

# Content panel
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Location = New-Object System.Drawing.Point(20, 100)
$contentPanel.Size = New-Object System.Drawing.Size(600, 350)
$contentPanel.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($contentPanel)

# Phase label
$phaseLabel = New-Object System.Windows.Forms.Label
$phaseLabel.Location = New-Object System.Drawing.Point(20, 20)
$phaseLabel.Size = New-Object System.Drawing.Size(560, 25)
$phaseLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$phaseLabel.ForeColor = $primaryColor
$contentPanel.Controls.Add($phaseLabel)

# Progress bar container
$progressContainer = New-Object System.Windows.Forms.Panel
$progressContainer.Location = New-Object System.Drawing.Point(20, 60)
$progressContainer.Size = New-Object System.Drawing.Size(560, 30)
$progressContainer.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$progressContainer.BorderStyle = "FixedSingle"
$contentPanel.Controls.Add($progressContainer)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(1, 1)
$progressBar.Size = New-Object System.Drawing.Size(558, 28)
$progressBar.Style = "Continuous"
$progressBar.ForeColor = $accentColor
$progressBar.BackColor = [System.Drawing.Color]::White
$progressContainer.Controls.Add($progressBar)

# Percentage label
$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Location = New-Object System.Drawing.Point(260, 95)
$percentLabel.Size = New-Object System.Drawing.Size(80, 25)
$percentLabel.Text = "0%"
$percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$percentLabel.ForeColor = $primaryColor
$percentLabel.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$contentPanel.Controls.Add($percentLabel)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 130)
$statusLabel.Size = New-Object System.Drawing.Size(560, 40)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = $textColor
$contentPanel.Controls.Add($statusLabel)

# Log box header
$logHeader = New-Object System.Windows.Forms.Label
$logHeader.Location = New-Object System.Drawing.Point(20, 180)
$logHeader.Size = New-Object System.Drawing.Size(560, 20)
$logHeader.Text = "Installation Log:"
$logHeader.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$logHeader.ForeColor = $textColor
$contentPanel.Controls.Add($logHeader)

# Log box
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(20, 200)
$logBox.Size = New-Object System.Drawing.Size(560, 120)
$logBox.ReadOnly = $true
$logBox.BackColor = [System.Drawing.Color]::White
$logBox.BorderStyle = "FixedSingle"
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$contentPanel.Controls.Add($logBox)

# Footer label
$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Location = New-Object System.Drawing.Point(20, 330)
$footerLabel.Size = New-Object System.Drawing.Size(560, 20)
$footerLabel.Text = "Laptop Store IQ Developers"
$footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
$footerLabel.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$footerLabel.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
$contentPanel.Controls.Add($footerLabel)

function Update-Progress {
    param (
        [int]$percent,
        [string]$phase,
        [string]$status,
        [string]$logMessage
    )
    
    $progressBar.Value = $percent
    $percentLabel.Text = "$percent%"
    $phaseLabel.Text = $phase
    $statusLabel.Text = $status
    
    if ($logMessage) {
        $logBox.AppendText("$(Get-Date -Format 'HH:mm:ss') - $logMessage`r`n")
        $logBox.ScrollToCaret()
    }
    
    [System.Windows.Forms.Application]::DoEvents()
}

# Configuration
$driverFolder = $scriptDir
$intelInstaller = Join-Path $scriptDir "autoinstall-intel.ps1"
$replaceTool = Join-Path $scriptDir "replaceDriver.ps1"
$logFolder = Join-Path $scriptDir "DriverInstallLogs"

# Create log folder
$sessionID = Get-Date -Format "yyyyMMdd_HHmmss"
$logFolder = Join-Path $logFolder $sessionID
New-Item -ItemType Directory -Path $logFolder -Force | Out-Null

# Show the form with fade-in animation
$form.Opacity = 0
$form.Show() | Out-Null
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 20
$timer.Add_Tick({
    if ($form.Opacity -lt 1) {
        $form.Opacity += 0.05
    } else {
        $timer.Stop()
        $timer.Dispose()
    }
})
$timer.Start()

Update-Progress -percent 0 -phase "Initializing..." -status "Starting installation process"

# Main installation function
function Install-MainDrivers {
    Update-Progress -percent 0 -phase "Phase 1/3: Driver Installation" -status "Preparing..."
    
    $excludeFiles = @("autoinstall-intel.ps1", "replaceDriver.ps1", "DriverInstaller_WithGUI.ps1")
    $driverFiles = Get-ChildItem -Path $driverFolder -Filter "*.exe" -File |
                   Where-Object { $excludeFiles -notcontains $_.Name }
    
    # Check if VC_redist.x64.exe exists and install it first
    $vcRedist = $driverFiles | Where-Object { $_.Name -eq "VC_redist.x64.exe" }
    if ($vcRedist) {
        Update-Progress -percent 0 -status "Installing VC_redist.x64.exe (prerequisite)" `
            -logMessage "Processing VC_redist.x64.exe (prerequisite)"
        
        try {
            $process = Start-Process -FilePath $vcRedist.FullName -ArgumentList "/install /quiet /norestart" -PassThru -NoNewWindow -Wait
            Update-Progress -logMessage "Installed VC_redist.x64.exe (Exit: $($process.ExitCode))"
            
            # Remove VC_redist from the list so it doesn't get installed again
            $driverFiles = $driverFiles | Where-Object { $_.Name -ne "VC_redist.x64.exe" }
        }
        catch {
            Update-Progress -logMessage "[ERROR] Failed VC_redist.x64.exe: $_"
        }
    }
    
    $total = $driverFiles.Count
    $current = 0
    
    foreach ($driver in $driverFiles) {
        $current++
        $percent = [math]::Round(($current/$total)*100)
        
        Update-Progress -percent $percent -status "Installing $($driver.Name)" `
            -logMessage "Processing $($driver.Name) ($current/$total)"
        
        try {
            $args = if ($driver.Name -like "*crosec*") { 
                "/quiet /norestart /acceptEULA" 
            } else { 
                "/S /norestart" 
            }
            
            $process = Start-Process -FilePath $driver.FullName -ArgumentList $args -PassThru -NoNewWindow
            $startTime = Get-Date
            
            while (-not $process.HasExited) {
                if ((Get-Date) - $startTime -gt [TimeSpan]::FromSeconds(300)) {
                    Stop-Process -Id $process.Id -Force
                    throw "Timeout after 5 minutes"
                }
                Start-Sleep -Seconds 1
            }
            
            Update-Progress -logMessage "Installed $($driver.Name) (Exit: $($process.ExitCode))"
        }
        catch {
            Update-Progress -logMessage "[ERROR] Failed $($driver.Name): $_"
        }
    }
}

function Run-IntelInstaller {
    Update-Progress -percent 0 -phase "Phase 2/3: Intel Components" -status "Initializing..."
    
    if (-not (Test-Path $intelInstaller)) {
        Update-Progress -logMessage "[WARNING] Intel installer not found"
        return
    }

    try {
        $output = & $intelInstaller 2>&1 | Out-String
        Update-Progress -percent 100 -status "Intel components installed" -logMessage $output
    }
    catch {
        Update-Progress -logMessage "[ERROR] Intel installer failed: $_"
    }
}

function Run-DriverReplacement {
    Update-Progress -percent 0 -phase "Phase 3/3: Driver Replacement" -status "Initializing..."
    
    if (-not (Test-Path $replaceTool)) {
        Update-Progress -logMessage "[WARNING] Replacement tool not found"
        return
    }

    try {
        $output = & $replaceTool 2>&1 | Out-String
        Update-Progress -percent 100 -status "Driver replacement complete" -logMessage $output
    }
    catch {
        Update-Progress -logMessage "[ERROR] Driver replacement failed: $_"
    }
}

# Main execution
try {
    Install-MainDrivers
    Run-IntelInstaller
    Run-DriverReplacement
    
    Update-Progress -percent 100 -phase "Installation Complete" -status "All operations finished successfully" `
        -logMessage "=== PROCESS COMPLETED ==="
    
    # Play completion sound
    [System.Media.SystemSounds]::Exclamation.Play()
    
    # Show reboot countdown message
    $countdown = 30
    while ($countdown -gt 0) {
        Update-Progress -status "Your laptop will reboot in $countdown seconds to complete installation"
        Start-Sleep -Seconds 1
        $countdown--
    }
    
    # Initiate reboot
    Start-Process "shutdown.exe" -ArgumentList "/r /t 0 /c ""Driver installation complete. Rebooting..."""
    $form.Close()
    exit
}
catch {
    Update-Progress -percent 100 -phase "Installation Failed" -status "Error occurred" `
        -logMessage "[CRITICAL ERROR] $_"
    
    # Play error sound
    [System.Media.SystemSounds]::Hand.Play()
    
    # Modern message box at the end for errors
    $messageBox = New-Object System.Windows.Forms.Form
    $messageBox.Text = "Installation Failed"
    $messageBox.Size = New-Object System.Drawing.Size(350, 150)
    $messageBox.StartPosition = "CenterScreen"
    $messageBox.FormBorderStyle = "FixedDialog"
    $messageBox.MaximizeBox = $false
    $messageBox.BackColor = $secondaryColor

    $msgLabel = New-Object System.Windows.Forms.Label
    $msgLabel.Location = New-Object System.Drawing.Point(20, 20)
    $msgLabel.Size = New-Object System.Drawing.Size(300, 40)
    $msgLabel.Text = "The installation process encountered an error."
    $msgLabel.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    $messageBox.Controls.Add($msgLabel)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(120, 70)
    $okButton.Size = New-Object System.Drawing.Size(100, 30)
    $okButton.Text = "OK"
    $okButton.BackColor = $primaryColor
    $okButton.ForeColor = [System.Drawing.Color]::White
    $okButton.FlatStyle = "Flat"
    $okButton.FlatAppearance.BorderSize = 0
    $okButton.Add_Click({ $messageBox.Close(); $form.Close() })
    $messageBox.Controls.Add($okButton)

    $messageBox.ShowDialog() | Out-Null
}