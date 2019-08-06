# azure-nsg-update
This project contains code to add all the Azure public IPs to the Network Security Group for the specific region.

### Prerequisites

 - Azure Portal access
 - One NSG to be updated
 - One Azure automation account in same resource group of NSG

### Steps

1. Create one automation account
2. In automation account creation wizard, select resource group as your nsg
3. Go to automation account created
4. Go to Runbooks from side pane
5. Select create Runbooks
6. In create runbooks pane, select type as 'powershell'
7. Go the runbook view and select modules
8. In modules pane, import AzureRM.Network (with its dependencies)
9. Add the code of [updating-nsg-rules-xml.ps1](https://github.com/hassanraha/azure-nsg-update/blob/master/updating-nsg-rules-xml.ps1 "updating-nsg-rules-xml.ps1") to edit pane
10. Save and Run 

