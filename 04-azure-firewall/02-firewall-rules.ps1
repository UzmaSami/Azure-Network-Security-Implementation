# Author: Uzma Shabbir
# Project: Network Security Baseline
$rgName = "rg-network-security"
$policyName = "afwpol-hub-uksouth"

Write-Host "1. Fetching Policy..." -ForegroundColor Cyan
$policy = Get-AzFirewallPolicy -Name $policyName -ResourceGroupName $rgName

# ---- Build Network Rules ----
Write-Host "2. Building Network Rules..." -ForegroundColor Cyan
$dns = New-AzFirewallPolicyNetworkRule -Name "Allow-DNS" -Protocol UDP -SourceAddress "10.0.0.0/8" -DestinationAddress "168.63.129.16" -DestinationPort "53"
$ntp = New-AzFirewallPolicyNetworkRule -Name "Allow-NTP" -Protocol UDP -SourceAddress "10.0.0.0/8" -DestinationAddress "*" -DestinationPort "123"
$internal = New-AzFirewallPolicyNetworkRule -Name "Allow-Spoke-Internal" -Protocol Any -SourceAddress @("10.1.0.0/16","10.2.0.0/16") -DestinationAddress @("10.1.0.0/16","10.2.0.0/16") -DestinationPort "*"

$netColl = New-AzFirewallPolicyFilterRuleCollection -Name "NetworkRules-Core" -Priority 200 -Rule @($dns, $ntp, $internal) -ActionType Allow

# ---- Build App Rules ----
Write-Host "3. Building Application Rules..." -ForegroundColor Cyan

# FIXED: Removed -Protocol from WindowsUpdate as FqdnTag handles it automatically
$winUpdate = New-AzFirewallPolicyApplicationRule -Name "Allow-WindowsUpdate" -SourceAddress "10.0.0.0/8" -FqdnTag "WindowsUpdate"

$azServices = New-AzFirewallPolicyApplicationRule -Name "Allow-AzureServices" -SourceAddress "10.0.0.0/8" -Protocol "https:443" -TargetFqdn @("*.azure.com", "*.microsoft.com", "*.windows.net")

$appColl = New-AzFirewallPolicyFilterRuleCollection -Name "AppRules-Core" -Priority 300 -Rule @($winUpdate, $azServices) -ActionType Allow

# ---- Apply to Policy ----
Write-Host "4. Pushing to Azure Policy (Uzma Shabbir)... This takes ~3 minutes." -ForegroundColor Yellow
$rcg = New-AzFirewallPolicyRuleCollectionGroup -Name "rcg-core-rules" -Priority 100 -FirewallPolicyObject $policy -RuleCollection @($netColl, $appColl)

Write-Host "`n✅ SUCCESS! All rules are now active." -ForegroundColor Green

