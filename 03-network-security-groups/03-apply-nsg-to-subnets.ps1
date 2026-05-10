# ============================================
# Script: apply-nsg-to-subnets.ps1
# Purpose: Associate NSGs with correct subnets across VNets
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

$rgName         = "rg-network-security"
$spoke1VnetName = "vnet-spoke1-workloads"
$spoke2VnetName = "vnet-spoke2-management"

Write-Host "`nRetrieving NSGs from Azure..." -ForegroundColor Cyan

# Get NSGs
$workloadNSG = Get-AzNetworkSecurityGroup -Name "nsg-workload-spoke1" -ResourceGroupName $rgName
$mgmtNSG     = Get-AzNetworkSecurityGroup -Name "nsg-management-spoke2" -ResourceGroupName $rgName

# ============================================
# 1. APPLY TO SPOKE 1 (WORKLOADS)
# ============================================
Write-Host "`nApplying Workload NSG to Spoke 1 subnets..." -ForegroundColor Cyan
$spoke1Vnet = Get-AzVirtualNetwork -Name $spoke1VnetName -ResourceGroupName $rgName

# Update local VNet object
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke1Vnet -Name "snet-web"  -AddressPrefix "10.1.1.0/24" -NetworkSecurityGroup $workloadNSG | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke1Vnet -Name "snet-app"  -AddressPrefix "10.1.2.0/24" -NetworkSecurityGroup $workloadNSG | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke1Vnet -Name "snet-data" -AddressPrefix "10.1.3.0/24" -NetworkSecurityGroup $workloadNSG | Out-Null

# Push changes to Azure
Write-Host "Saving Spoke 1 configuration to Azure..." -ForegroundColor Yellow
Set-AzVirtualNetwork -VirtualNetwork $spoke1Vnet | Out-Null
Write-Host "✅ NSG applied to Web, App, and Data Subnets" -ForegroundColor Green

# ============================================
# 2. APPLY TO SPOKE 2 (MANAGEMENT)
# ============================================
Write-Host "`nApplying Management NSG to Spoke 2 subnets..." -ForegroundColor Cyan
$spoke2Vnet = Get-AzVirtualNetwork -Name $spoke2VnetName -ResourceGroupName $rgName

# Update local VNet object
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke2Vnet -Name "snet-admin"      -AddressPrefix "10.2.1.0/24" -NetworkSecurityGroup $mgmtNSG | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke2Vnet -Name "snet-monitoring" -AddressPrefix "10.2.2.0/24" -NetworkSecurityGroup $mgmtNSG | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spoke2Vnet -Name "snet-security"   -AddressPrefix "10.2.3.0/24" -NetworkSecurityGroup $mgmtNSG | Out-Null

# Push changes to Azure
Write-Host "Saving Spoke 2 configuration to Azure..." -ForegroundColor Yellow
Set-AzVirtualNetwork -VirtualNetwork $spoke2Vnet | Out-Null
Write-Host "✅ NSG applied to Admin, Monitoring, and Security Subnets" -ForegroundColor Green

# ============================================
# 3. VERIFICATION
# ============================================
Write-Host "`n=== NSG ASSOCIATIONS ===" -ForegroundColor Cyan

# Fixed the mapping syntax here to cleanly display connected subnets
Get-AzNetworkSecurityGroup -ResourceGroupName $rgName |
    Select-Object Name, `
    @{N="AssociatedSubnets";E={
        if ($_.Subnets) {
            ($_.Subnets.Id | ForEach-Object { $_.Split("/")[-1] }) -join ", "
        } else {
            "None"
        }
    }} |
    Format-Table -AutoSize

