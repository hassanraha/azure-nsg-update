﻿$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
#Azure resource group name associated with the network security group
$rgName = 'test-sonar';
#Azure network security group that we need to create the rule against
$nsgname = 'sonar-nsg';
# Select-AzureRmSubscription -SubscriptionId $subscriptionId;
# Download current list of Azure Public IP ranges

Write-Host "Downloading AzureCloud Ip addresses..."
$downloadUri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"
$downloadPage = Invoke-WebRequest -Uri $downloadUri;
$request = ($downloadPage.RawContent.Split('"') -like "*.json")[0];
$json = Invoke-WebRequest -Uri $request | ConvertFrom-Json | Select Values
$ipRange = ($json.values | Where-Object {$_.Name -eq 'AzureCloud'}).properties.addressPrefixes

#set rule priority

$rulePriority = 200

#define the rule names    

$ruleNameOut = "Allow_AzureDataCenters_Out"
$ruleNameIn = "Allow_AzureDataCenters_In" 

#nonprod network security group 

$nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgname -ResourceGroupName $rgName -ErrorAction:Stop;
Write-Host "Applying AzureCloud Ip addresses to non production NSG  $nsgname..."

#check to see if the inbound rule already existed

$inboundRule = ($nsg | Get-AzureRmNetworkSecurityRuleConfig -Name $ruleNameIn -ErrorAction SilentlyContinue)

if($inboundRule -eq $null){
    #create inbound rule    
    $nsg | Add-AzureRmNetworkSecurityRuleConfig -Name $ruleNameIn -Description "Allow Inbound to Azure data centers" -Access Allow -Protocol * -Direction Inbound -Priority $rulePriority -SourceAddressPrefix $ipRange -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange * -ErrorAction:Stop | Set-AzureRmNetworkSecurityGroup -ErrorAction:Stop | Out-NULL;
    Write-Host "Created NSG rule $ruleNameIn for $nsgname"
}
else{
    #update inbound rule
    $nsg | Set-AzureRmNetworkSecurityRuleConfig -Name $ruleNameIn -Description "Allow Inbound to Azure data centers" -Access Allow -Protocol * -Direction Inbound -Priority $rulePriority -SourceAddressPrefix $ipRange -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange * -ErrorAction:Stop | Set-AzureRmNetworkSecurityGroup -ErrorAction:Stop | Out-NULL;
    Write-Host "Updated NSG rule $ruleNameIn for $nsgname"
}
#check to see if the outbound rule already existed
$outboundRule = ($nsg | Get-AzureRmNetworkSecurityRuleConfig -Name $ruleNameOut -ErrorAction SilentlyContinue)
if($outboundRule -eq $null)
{
    #create outbound rule
    $nsg | Add-AzureRmNetworkSecurityRuleConfig -Name $ruleNameOut -Description "Allow outbound to Azure data centers" -Access Allow -Protocol * -Direction Outbound -Priority $rulePriority -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix $ipRange -DestinationPortRange * -ErrorAction:Stop | Set-AzureRmNetworkSecurityGroup -ErrorAction:Stop | Out-NULL;
    Write-Host "Created NSG rule $ruleNameOut for $nsgname"
}
else
{
    #update outbound rule
    $nsg | Set-AzureRmNetworkSecurityRuleConfig -Name $ruleNameOut -Description "Allow outbound to Azure centers" -Access Allow -Protocol * -Direction Outbound -Priority $rulePriority -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix $ipRange -DestinationPortRange * -ErrorAction:Stop | Set-AzureRmNetworkSecurityGroup -ErrorAction:Stop | Out-NULL;
    Write-Host "Updated NSG rule $ruleNameOut for $nsgname"
}