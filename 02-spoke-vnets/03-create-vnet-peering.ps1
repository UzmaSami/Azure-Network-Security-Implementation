# ============================================
# Script: create-vnet-peering.ps1
# Purpose: Peer Hub VNet with both Spoke VNets
#          enabling traffic flow through Hub
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

$rgName         = "rg-network-security"
$hubVnetName    = "vnet-hub-uksouth"
$spoke1VnetName = "vnet-spoke1-workloads"
$spoke2VnetName = "vnet-spoke2-management"

Write-Host "`nRetrieving VNet objects from Azure..." -ForegroundColor Cyan
# Get VNet objects
$hubVnet    = Get-AzVirtualNetwork -Name $hubVnetName    -ResourceGroupName $rgName
$spoke1Vnet = Get-AzVirtualNetwork -Name $spoke1VnetName -ResourceGroupName $rgName
$spoke2Vnet = Get-AzVirtualNetwork -Name $spoke2VnetName -ResourceGroupName $rgName

Write-Host "`nCreating VNet Peering: Hub <--> Spoke 1..." -ForegroundColor Cyan

# ---- PEERING: Hub -> Spoke 1 ----
Add-AzVirtualNetworkPeering `
    -Name "peer-hub-to-spoke1" `
    -VirtualNetwork $hubVnet `
    -RemoteVirtualNetworkId $spoke1Vnet.Id `
    -AllowForwardedTraffic `
    -AllowGatewayTransit | Out-Null

Write-Host "✅ Hub -> Spoke1 peering created!" -ForegroundColor Green

# ---- PEERING: Spoke 1 -> Hub ----
Add-AzVirtualNetworkPeering `
    -Name "peer-spoke1-to-hub" `
    -VirtualNetwork $spoke1Vnet `
    -RemoteVirtualNetworkId $hubVnet.Id `
    -AllowForwardedTraffic | Out-Null

Write-Host "✅ Spoke1 -> Hub peering created!" -ForegroundColor Green

Write-Host "`nCreating VNet Peering: Hub <--> Spoke 2..." -ForegroundColor Cyan

# ---- PEERING: Hub -> Spoke 2 ----
Add-AzVirtualNetworkPeering `
    -Name "peer-hub-to-spoke2" `
    -VirtualNetwork $hubVnet `
    -RemoteVirtualNetworkId $spoke2Vnet.Id `
    -AllowForwardedTraffic `
    -AllowGatewayTransit | Out-Null

Write-Host "✅ Hub -> Spoke2 peering created!" -ForegroundColor Green

# ---- PEERING: Spoke 2 -> Hub ----
Add-AzVirtualNetworkPeering `
    -Name "peer-spoke2-to-hub" `
    -VirtualNetwork $spoke2Vnet `
    -RemoteVirtualNetworkId $hubVnet.Id `
    -AllowForwardedTraffic | Out-Null

Write-Host "✅ Spoke2 -> Hub peering created!" -ForegroundColor Green

# Verify all peerings
Write-Host "`n=== ALL VNET PEERINGS STATUS ===" -ForegroundColor Cyan

Write-Host "`nHub VNet Peerings:" -ForegroundColor Yellow
Get-AzVirtualNetworkPeering `
    -VirtualNetworkName $hubVnetName `
    -ResourceGroupName $rgName |
    Select-Object Name, PeeringState, AllowForwardedTraffic |
    Format-Table -AutoSize

Write-Host "Spoke1 VNet Peerings:" -ForegroundColor Yellow
Get-AzVirtualNetworkPeering `
    -VirtualNetworkName $spoke1VnetName `
    -ResourceGroupName $rgName |
    Select-Object Name, PeeringState |
    Format-Table -AutoSize

Write-Host "Spoke2 VNet Peerings:" -ForegroundColor Yellow
Get-AzVirtualNetworkPeering `
    -VirtualNetworkName $spoke2VnetName `
    -ResourceGroupName $rgName |
    Select-Object Name, PeeringState |
    Format-Table -AutoSize

