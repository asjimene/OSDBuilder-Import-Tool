# OSBuilder-Import-Tool

The purpose of this tool is to import OSBuilds and OSMedia created using David Segura's OSDBuilder module into SCCM. It's primary functions are as follows:
1. Copy the OSBuild/OSMedia into the correct content shares (wim file and optionally OS Upgrade Packages)
2. Import the OSBuild/OSMedia into SCCM Operating System Images (Optionally import OS Upgrade Package)
3. Distribute Content to a specified Distribution Point Group

## Pre-Requisites
Ensure that you have installed the OSDBuilder Module at least version 19.1.11.0

## Instructions
1. Edit the Import-OSBuild.ps1 file and set the following Global Variables: ContentShare, SCCMSite, PreferredDistributionLoc
2. Run the script and choose the OSBuilds you want to import
3. The script will automatically copy the install.wim to your specified content location, import the wim into SCCM, and distribute the content to the selected Distribution Point Group

The Script will not copy wims that already exist on the content share

### Import an OSBuild wim file only
`.\Import-OSBuild.ps1`

### Import an OSBuild wim file and the cooresponding OS Upgrade Package
`.\Import-OSBuild.ps1 -ImportOSUpgrade`

### Import an OSMedia wim file and the cooresponding OS Upgrade Package
`.\Import-OSBuild -Import-OSMedia -ImportOSUpgrade`

### Import an OSBuild, but do not create a new wim on the content share, instead update an exising wim
`.\Import-OSBuild -UseExistingPackages`

### Import an OSBuild wim file, and the cooresponding OS Upgrade Package but use an exising wim and Upgrade Package
`.\Import-OSBuild -UseExistingPackages -ImportOSUpgrade`

This is a work in progress, use at your own risk, I take no responsibility for any issues this may cause. :)
