# ============================================
# Script: create-spoke-vnet2.ps1
# Purpose: Create Spoke VNet 2 for management (Admin, Monitor, Security)
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

# ============================================
# VARIABLES
# ============================================
$location         = "uksouth"
$rgName           = "rg-network-security"
$spoke2VnetName   = "vnet-spoke2-management"
$spoke2Address    = "10.2.0.0/16"

# Spoke 2 Subnets
$adminSubnet      = "10.2.1.0/24"   # Admin systems
$monitorSubnet    = "10.2.2.0/24"   # Monitoring tools
$securitySubnet   = "10.2.3.0/24"   # Security tools

Write-Host "`nCreating Spoke VNet 2 Subnets..." -ForegroundColor Cyan

# 1. Create Admin Subnet
$adminSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-admin" `
    -AddressPrefix $adminSubnet
Write-Host "✅ Admin Subnet configured: $adminSubnet" -ForegroundColor Green

# 2. Create Monitoring Subnet
$monitorSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-monitoring" `
    -AddressPrefix $monitorSubnet
Write-Host "✅ Monitoring Subnet configured: $monitorSubnet" -ForegroundColor Green

# 3. Create Security Subnet
$securitySubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-security" `
    -AddressPrefix $securitySubnet
Write-Host "✅ Security Subnet configured: $securitySubnet" -ForegroundColor Green

Write-Host "`nDeploying Spoke VNet 2 (Management)..." -ForegroundColor Cyan

# 4. Create Spoke VNet 2
$spoke2Vnet = New-AzVirtualNetwork `
    -Name $spoke2VnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $spoke2Address `
    -Subnet @(
        $adminSubnetConfig,
        $monitorSubnetConfig,
        $securitySubnetConfig
    ) `
    -Tag @{
        Purpose     = "Management-Spoke"
        Tier        = "Operations"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Spoke VNet 2 created successfully!" -ForegroundColor Green
Write-Host "Name: $($spoke2Vnet.Name)" -ForegroundColor Cyan
Write-Host "Address Space: $($spoke2Vnet.AddressSpace.AddressPrefixes)" -ForegroundColor Cyan

# 5. Display subnets
Write-Host "`n=== SPOKE 2 VNET SUBNETS ===" -ForegroundColor Cyan
$spoke2Vnet.Subnets |
    Select-Object Name, `
    @{N="AddressPrefix";E={$_.AddressPrefix}} |
    Format-Table -AutoSize

# 6. Save Spoke VNet ID for later use (Crucial for VNet Peering!)
$spoke2Vnet.Id | Out-File ".\spoke2-vnet-id.txt"
Write-Host "✅ Spoke VNet 2 ID saved to Cloud Shell storage!" -ForegroundColor Green

