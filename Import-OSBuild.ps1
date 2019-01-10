<#	
	.NOTES
	===========================================================================
	 Created on:   	1/10/2019
	 Author:		Andrew Jimenez (asjimene) - https://github.com/asjimene/
	 Filename:     	Import-OSBuild.ps1
	===========================================================================
	.DESCRIPTION
        Imports OS Images created using David Segura's OSBuilder PowerShell module - https://www.osdeploy.com/osbuilder/overview.
#>

## Global Variables

# OSBuilder Variables
$Global:OSBuildPath = "C:\OSBuilder"

# SCCM Variables
$Global:ContentShare = "\\Path\to\Content\share"
$Global:SCCMSite = "SITE:"
$Global:PreferredDistributionLoc = "PreferredGroupName" #Must be a distribution point group at this time

# Logging Variables
$Global:LogPath = "$PSScriptRoot\OSBuilder-Import.log"
$Global:MaxLogSize = 1000kb


## Functions

function Add-LogContent {
	param
	(
		[parameter(Mandatory = $false)]
		[switch]$Load,
		[parameter(Mandatory = $true)]
		$Content
	)
	if ($Load) {
		if ((Get-Item $LogPath -ErrorAction SilentlyContinue).length -gt $MaxLogSize) {
			Write-Output "$(Get-Date -Format G) - $Content" > $LogPath
		}
		else {
			Write-Output "$(Get-Date -Format G) - $Content" >> $LogPath
		}
	}
	else {
		Write-Output "$(Get-Date -Format G) - $Content" >> $LogPath
	}
}


## Main

Add-LogContent -Content "Starting Import-OSBuild" -Load

# Import ConfigurationManager Cmdlets
if (-not (Get-Module ConfigurationManager)) {
    try {
        Add-LogContent "Importing ConfigurationManager Module"
        Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    } 
    catch {
        $ErrorMessage = $_.Exception.Message
		Add-LogContent "ERROR: Importing ConfigurationManager Module Failed!"
		Add-LogContent "ERROR: $ErrorMessage"
    }
}

# Search the OSBuilder Path for new Wim Files to import
$selectedBuilds = Get-ChildItem "$Global:OSBuildPath\OSBuilds" | Select-Object -Property Name,LastWriteTime,FullName | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Available Builds" -PassThru
Add-LogContent "Selected the Following Builds to import: $($SelectedBuilds.Name -join " ; ")"

ForEach ($Build in $SelectedBuilds){
    $wimLocation = Join-Path -Path $Build.FullName -ChildPath "OS\sources\install.wim"
    $destinationPath = "$Global:ContentShare\$($Build.Name).wim"
    if ((Test-Path $wimLocation) -and (-not (Test-Path $destinationPath))){
        #Add-LogContent "$wimLocation exists"
        #Add-LogContent "$destinationPath does not yet exist"
        Add-LogContent "Pre-Check Complete - Import can continue"

        #Get the Version Info from the OSBuild Folder
        #$BuildInfo = Get-Content -Raw -Path "$($Build.FullName)\info\json\CurrentVersion.json" | ConvertFrom-Json
        $BuildInfo = Import-Clixml -Path "$($Build.FullName)\info\xml\CurrentVersion.xml"
        $BuildVersion = $BuildInfo.CurrentBuildNumber + "." + $BuildInfo.UBR
        $BuildDescription = $BuildInfo.ProductName + " Version $BuildVersion - Imported from OSBuilder on: $(Get-Date -Format G)"

        # Copy the selected install.wim to the ContentShare using the build name
        Add-LogContent "Attempting to Copy $wimLocation to $destinationPath"
        try {
            Copy-Item -Path $wimLocation -Destination $destinationPath
            Add-LogContent "Copy Completed Successfully"
            $continueImport = $true
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Add-LogContent "ERROR: Copying $wimLocation to $destinationPath failed! Skipping import for $($Build.Name)"
            Add-LogContent "ERROR: $ErrorMessage"
            $continueImport = $false
        }

        # Import the Copied wim into SCCM
        Add-LogContent "Importing $($Build.Name)"
        if ($continueImport){
            Push-Location
            Set-Location $Global:SCCMSite
            try {
                New-CMOperatingSystemImage -Name "$($Build.Name)" -Path "$destinationPath" -Version "$BuildVersion" -Description "$BuildDescription"
                Add-LogContent "Successfully Imported the Operating System as $($Build.Name)"
                $continueDistribution = $true
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Add-LogContent "ERROR: Importing wim into SCCM from $destinationPath failed! Skipping import for $($Build.Name)"
                Add-LogContent "ERROR: $ErrorMessage"
                $continueDistribution = $false
            }
            Pop-Location
        }

        # Distribute the new OSImage to the Specified Distribution Point Group
        Add-LogContent "Distributing $($Build.Name) to $($Global:PreferredDistributionLoc)"
        if ($continueDistribution){
            Push-Location
            Set-Location $Global:SCCMSite
            try {
                Start-CMContentDistribution -OperatingSystemImageName "$($Build.Name)" -DistributionPointGroupName $Global:PreferredDistributionLoc
                Add-LogContent "Successfully Completed Copy, Import, and Distribution of OSBuild: $($Build.Name)"
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Add-LogContent "ERROR: Distributing OSImage $(Build.Name) Failed!"
                Add-LogContent "ERROR: $ErrorMessage"
            }
            Pop-Location
        }
    }
    else {
        if (-not (Test-Path $wimLocation)){
            Add-LogContent "ERROR: install.wim not found at $wimLocation - Skipping import for $($Build.Name)"
        }
        if (Test-Path $destinationPath){
            Add-LogContent "ERROR: $destinationPath already exists! Skipping import for $($Build.Name)"
        }
    }
}

Add-LogContent "Import-OSBuild has Completed!"