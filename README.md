# OSBuilder-Import-Tool

The purpose of this tool is to import OSBuilds and OSMedia created using David Segura's OSDBuilder module into SCCM. It's primary functions are as follows:
1. Copy the OSBuild/OSMedia into the correct content shares (wim file and optionally OS Upgrade Packages)
2. Import the OSBuild/OSMedia into SCCM Operating System Images (Optionally import OS Upgrade Package)
3. Distribute Content to a specified Distribution Point Group
4. Optionally update a specified task sequence step with the new OS Image

## Pre-Requisites
Ensure that you have installed the latest OSDBuilder Module and the ConfigurationManger module
This script needs to be run on the machine that OSDBuilder is run on
The computer that this script is run on should also have the Configuration Manager Console installed (and the console needs to have been opened at least once)

## Instructions
1. Edit the Import-OSBuild.ps1 file and set the following Global Variables: ContentShare, OSUpgradeContentShare, SCCMSite, PreferredDistributionLoc
2. Run the script and choose the OSBuilds you want to import
3. The script will automatically copy the install.wim to your specified content location, import the wim into SCCM, and distribute the content to the selected Distribution Point Group
4. You can also choose to run the script silently by providing an OSUploadName. See examples for more usecases

The Script will not copy wims (or import them into SCCM) if they already exist on the content share.

###Imports an OSBuild wim file only
.\Import-OSBuild.ps1


###Import an OSBuild wim file and the cooresponding OS Upgrade Package
.\Import-OSBuild.ps1 -ImportOSUpgrade


###Import the latest OSBuild with the name like "Windows 10 Enterprise x64 1809", and import the cooresponding OSUpgrade package. This flag is helpful for automating the upload process, say... after an OSBuild is completed.
.\Import-OSBuild.ps1 -OSUploadName "Windows 10 Enterprise x64 1809" -ImportOSUpgrade


###Import the latest OSMedia with the name like "Windows 10 Enterprise x64 1809", then update the step "Install Windows 10 x64" in the task sequence "DEV Task Sequence" with the newly uploaded media
.\Import-OSBuild.ps1 -OSUploadMedia -OSUploadName "Windows 10 Enterprise x64 1809" -UpdateTS -TaskSequenceName "DEV Task Sequence" -TaskSequenceStepName "Install Windows 10 x64" 


###Import an OSMedia wim file and the cooresponding OS Upgrade Package
.\Import-OSBuild -Import-OSMedia -ImportOSUpgrade


###Import an OSBuild, but do not create a new wim on the content share, instead update an exising wim
###NOTE: This flag cannot be used silently
.\Import-OSBuild -UseExistingPackages


###Import an OSBuild wim file, and the cooresponding OS Upgrade Package but use an exising wim and Upgrade Package
.\Import-OSBuild -UseExistingPackages -ImportOSUpgrade


This is a work in progress, use at your own risk, I take no responsibility for any issues this may cause. :)
