#Requires -RunAsAdministrator

<#
.Synopsis
   Desinstallation of QGIS by reading the .msi file that installed it.

.DESCRIPTION
   This script will:
      1. check the existence of the $QGIS_MSI_UNINSTALL environment variable and the .msi file
      2. check the existence of the $QGIS_MSI_PATH_LOGS environment variable
      and the writing rights in the logs directory
      3. check the existence of the $QGIS_MSI_PATH_UNINSTALLATION environment variable
      4. uninstall QGIS if the previous checkpoints are valid
      5. check that the installation has gone well
      6. open the logs directory (if $OPEN_LOGS_DIRECTORY has been set to $true)

   Requirements:

      Add the following environment variables : QGIS_MSI_UNINSTALL, QGIS_MSI_PATH_UNINSTALLATION, QGIS_MSI_PATH_LOGS
      Edit the value of the variable below OPEN_LOGS_DIRECTORY

#>

$ErrorActionPreference = "Stop"

# Retrieve environment variables
$QGIS_MSI_UNINSTALL = $env:QGIS_MSI_UNINSTALL
$QGIS_MSI_PATH_UNINSTALLATION = $env:QGIS_MSI_PATH_UNINSTALLATION
$QGIS_MSI_PATH_LOGS = $env:QGIS_MSI_PATH_LOGS
$OPEN_LOGS_DIRECTORY = $true




# Verification that the QGIS_MSI_UNINSTALL environment variable exists
if (-Not($QGIS_MSI_UNINSTALL))
{
    throw [System.Exception]"QGIS_MSI_UNINSTALL environment variable not found."
}
else
{
    $QGIS_MSI_UNINSTALL_FILE =  Get-ChildItem -Path  $QGIS_MSI_UNINSTALL -Recurse -include "*.previous.msi*"
    $QGIS_MSI_UNINSTALL_FILE -match "\-\d{1,2}\.\d{1,2}"
    # Verification that the .msi file exists
    if (-Not(Test-Path $QGIS_MSI_UNINSTALL_FILE -PathType leaf))
    {
        throw [System.IO.FileNotFoundException]"$QGIS_MSI_UNINSTALL not found."
    }
}

# Verification that the QGIS_MSI_PATH_LOGS environment variable exists
if (-Not($QGIS_MSI_PATH_LOGS))
{
    throw [System.Exception]"QGIS_MSI_PATH_LOGS environment variable not found."
}
else
{
    # Check the writing rights of the logs directory
    $TEST_PATH_WRITING_RIGHTS_LOGS = "$QGIS_MSI_PATH_LOGS\test_writing_rights.txt"
    if (Test-Path -Path $QGIS_MSI_PATH_LOGS)
    {
        try
        {
            $null = New-Item -Path $TEST_PATH_WRITING_RIGHTS_LOGS -ItemType File
            Remove-Item -Path $TEST_PATH_WRITING_RIGHTS_LOGS
        }
        catch [System.IO.IOException]
        {
            throw [System.IO.IOException]"Write permissions are required in the $QGIS_MSI_PATH_LOGS directory"
        }
    }
    else
    {
        try
        {
            $null = New-Item -Path $QGIS_MSI_PATH_LOGS -ItemType Directory
        }
        catch [System.IO.IOException]
        {
            throw [System.IO.IOException]"Write permissions are required to create the $QGIS_MSI_PATH_LOGS directory"
        }
        catch [System.Management.Automation.DriveNotFoundException]
        {
            throw [System.Management.Automation.DriveNotFoundException]"Drive not found, unable to create $QGIS_MSI_PATH_LOGS directory"
        }
    }
}

# Verification that the QGIS_MSI_PATH_UNINSTALLATION environment variable exists
if (-Not($QGIS_MSI_PATH_UNINSTALLATION))
{
    throw [System.Exception]"QGIS_MSI_PATH_UNINSTALLATION environment variable not found."
}
$QGIS_MSI_PATH_UNINSTALLATION=$QGIS_MSI_PATH_UNINSTALLATION+"\"+$matches[0].substring(1) -replace('\.','_')
# Uninstall QGIS
$UninstallProcess = Start-Process msiexec.exe -Wait -ArgumentList "/X $QGIS_MSI_UNINSTALL_FILE /L*v $QGIS_MSI_PATH_LOGS\qgis-uninstall.log /qn"

# Verification that the uninstallation is well passed
$UninstallExitCode = $UninstallProcess.ExitCode
if (!$UninstallExitCode)
{
    Write-Host "QGIS successfully uninstalled"
    Add-content "$QGIS_MSI_PATH_LOGS\qgis-uninstall.log" "QGIS successfully uninstalled"
    # Delete remaining folders and files
    try
    {
        Remove-Item $QGIS_MSI_PATH_UNINSTALLATION -Force  -Recurse -ErrorAction SilentlyContinue
        Write-Host "Directory $QGIS_MSI_PATH_UNINSTALLATION successfully deleted"
        Add-content "$QGIS_MSI_PATH_LOGS\qgis-uninstall.log" "Directory $QGIS_MSI_PATH_UNINSTALLATION successfully deleted"
    }
    catch [System.IO.IOException]
    {
        throw [System.IO.IOException]"An error occurred while deleting the directory $QGIS_MSI_PATH_UNINSTALLATION"
        Add-content "$QGIS_MSI_PATH_LOGS\qgis-uninstall.log" "An error occurred while deleting the directory $QGIS_MSI_PATH_UNINSTALLATION"
    }
}
else
{
    Write-Host "An error occurred during the uninstallation"
    Add-content "$QGIS_MSI_PATH_LOGS\qgis-uninstall.log" "An error occurred during the uninstallation"
}

# Opening the logs directory
if ($OPEN_LOGS_DIRECTORY)
{
    Invoke-Item $QGIS_MSI_PATH_LOGS
}
