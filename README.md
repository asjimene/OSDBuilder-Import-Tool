# OSBuilder-Import-Tool

Imports install.wim files updated using the OSBuilder Powershell tool


## Instructions
1. Edit the Import-OSBuild.ps1 file and set the following Global Variables: ContentShare, SCCMSite, PreferredDistributionLoc
2. Run the script and choose the OSBuilds you want to import
3. The script will automatically move the install.wim to your specified content location, import the wim into SCCM, and distribute the content to the selected Distribution Point Group

The Script will not copy wims that already exist on the content share

This is a work in progress :)
