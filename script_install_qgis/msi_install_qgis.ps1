#Requires -RunAsAdministrator

<#
.Synopsis
   Installation of QGIS by reading the installer in .msi format.

.DESCRIPTION
   This script will:
      1. check the existence of the $QGIS_MSI_INSTALL environment variable and the .msi file
      2. check the existence of the $QGIS_MSI_PATH_INSTALLATION environment variable
      and the writing rights in the installation directory
      3. check the existence of the $QGIS_MSI_PATH_LOGS environment variable
      and the writing rights in the logs directory
      4. install QGIS if the previous checkpoints are valid
      5. check that the installation has gone well
      6. open the logs directory (if $OPEN_LOGS_DIRECTORY has been set to $true)

   Requirements:

      The .msi installer must be downloaded beforehand.
      Add the following environment variables : QGIS_MSI, QGIS_MSI_PATH_INSTALLATION, QGIS_MSI_PATH_LOGS
      Edit the value of the variable below OPEN_LOGS_DIRECTORY

   Keep the .msi file so that you can uninstall the software later.
#>

$ErrorActionPreference = "Stop"

# Retrieve environment variables
$QGIS_MSI_INSTALL = $env:QGIS_MSI_INSTALL
$QGIS_MSI_PATH_INSTALLATION = $env:QGIS_MSI_PATH_INSTALLATION
$QGIS_MSI_PATH_LOGS = $env:QGIS_MSI_PATH_LOGS
$OPEN_LOGS_DIRECTORY = $true


#Verification that the QGIS_MSI_INSTALL environment variable exists
if (-Not($QGIS_MSI_INSTALL))
{
    throw [System.Exception]"QGIS_MSI_INSTALL environment variable not found."
}
else
{
    #Write-Host "$QGIS_MSI_INSTALL"
    $QGIS_MSI_INSTALL_FILE =  Get-ChildItem -Path  $QGIS_MSI_INSTALL -Recurse -include "*.latest.msi"
    $QGIS_MSI_INSTALL_FILE -match "\-\d{1,2}\.\d{1,2}"
    #$QGIS_VERSION=$matches[0].substring(1) -replace('\.','_')
    # Verification that the .msi file exists
    if (-Not(Test-Path $QGIS_MSI_INSTALL_FILE -PathType leaf))
    {
        throw [System.IO.FileNotFoundException]"$QGIS_MSI_INSTALL not found."
    }
}


# Verification that the QGIS_MSI_PATH_INSTALLATION environment variable exists
if (-Not($QGIS_MSI_PATH_INSTALLATION))
{
    throw [System.Exception]"QGIS_MSI_PATH_INSTALLATION environment variable not found."
}
else
{
    $QGIS_MSI_PATH_INSTALLATION=$QGIS_MSI_PATH_INSTALLATION+"\"+$matches[0].substring(1) -replace('\.','_')
    #Write-Host "$QGIS_MSI_PATH_INSTALLATION"
    # Check the writing rights of the installation directory
    $TEST_PATH_WRITING_RIGHTS_INSTALLATION = "$QGIS_MSI_PATH_INSTALLATION\test_writing_rights.txt"
    if (Test-Path -Path $QGIS_MSI_PATH_INSTALLATION)
    {
        try
        {
            $null = New-Item -Path $TEST_PATH_WRITING_RIGHTS_INSTALLATION -ItemType File
            Remove-Item -Path $TEST_PATH_WRITING_RIGHTS_INSTALLATION
        }
        catch [System.IO.IOException]
        {
            throw [System.IO.IOException]"Write permissions are required in the $QGIS_MSI_PATH_INSTALLATION directory"
        }
    }
    else
    {
        try
        {
            $null = New-Item -Path $QGIS_MSI_PATH_INSTALLATION -ItemType Directory
            Remove-Item -Path $QGIS_MSI_PATH_INSTALLATION
        }
        catch [System.IO.IOException]
        {
            throw [System.IO.IOException]"Write permissions are required to create the $QGIS_MSI_PATH_INSTALLATION directory"
        }
        catch [System.Management.Automation.DriveNotFoundException]
        {
            throw [System.Management.Automation.DriveNotFoundException]"Drive not found, unable to create $QGIS_MSI_PATH_INSTALLATION directory"
        }
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


# Install QGIS
$InstallProcess = Start-Process msiexec.exe -Wait -ArgumentList "/I $QGIS_MSI_INSTALL_FILE /L*v $QGIS_MSI_PATH_LOGS\qgis-install.log INSTALLDIR=$QGIS_MSI_PATH_INSTALLATION /qn"

# Verification that the installation is well passed
$InstallExitCode = $InstallProcess.ExitCode
if (!$InstallExitCode)
{
    Write-Host "QGIS successfully installed in the $QGIS_MSI_PATH_INSTALLATION directory"
    Add-content "$QGIS_MSI_PATH_LOGS\qgis-install.log" "QGIS successfully installed in the $QGIS_MSI_PATH_INSTALLATION directory"
}
else
{
    Write-Host "An error occurred during the installation"
    Add-content "$QGIS_MSI_PATH_LOGS\qgis-install.log" "An error occurred during the installation"
}

# Opening the logs directory
if ($OPEN_LOGS_DIRECTORY)
{
    Invoke-Item $QGIS_MSI_PATH_LOGS
}
