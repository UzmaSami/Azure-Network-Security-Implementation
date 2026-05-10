# ============================================
# Script enable-vnet-monitoring.ps1
# Purpose Enable modern VNet Flow Logs (Replaces retired NSG logs)
# Author Uzma Shabbir
# ============================================

$rg = rg-network-security
$location = uksouth
$vnetName = vnet-spoke1-workloads
$workspaceName = law-UzmaSami-hybrid-security-2026

# 1. Get Resources
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $rg -Name $workspaceName
$storage = Get-AzStorageAccount -ResourceGroupName $rg  Select-Object -First 1

Write-Host Connecting VNet Monitoring to Uzma's Workspace... -ForegroundColor Cyan

# 2. Enable VNet Flow Logs (The 2026 Standard)
# This covers all subnets (Web, App, Data) in one command!
New-AzNetworkWatcherFlowLog `
    -Location $location `
    -Name vnet-flowlog-spoke1 `
    -TargetResourceId $vnet.Id `
    -StorageId $storage.Id `
    -Enabled $true `
    -FormatVersion 2 `
    -EnableTrafficAnalytics `
    -TrafficAnalyticsWorkspaceId $workspace.ResourceId -Force

Write-Host `n✅ SUCCESS VNet Flow Logs enabled! -ForegroundColor Green
Write-Host ✅ Zero Trust visibility achieved for $vnetName -ForegroundColor Green
Write-Host Project managed by Uzma Shabbir -ForegroundColor White

