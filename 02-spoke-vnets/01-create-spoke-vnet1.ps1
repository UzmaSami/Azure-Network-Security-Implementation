# ============================================
# Script: create-spoke-vnet1.ps1
# Purpose: Create Spoke VNet 1 for workloads (Web, App, Data)
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
$spoke1VnetName   = "vnet-spoke1-workloads"
$spoke1Address    = "10.1.0.0/16"

# Spoke 1 Subnets (Standard 3-Tier Architecture)
$webSubnet        = "10.1.1.0/24"   # Web tier (Frontend)
$appSubnet        = "10.1.2.0/24"   # App tier (Middleware/Logic)
$dataSubnet       = "10.1.3.0/24"   # Data tier (Databases)

Write-Host "`nCreating Spoke VNet 1 Subnets..." -ForegroundColor Cyan

# 1. Create Web Subnet
$webSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-web" `
    -AddressPrefix $webSubnet
Write-Host "✅ Web Subnet configured: $webSubnet" -ForegroundColor Green

# 2. Create App Subnet
$appSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-app" `
    -AddressPrefix $appSubnet
Write-Host "✅ App Subnet configured: $appSubnet" -ForegroundColor Green

# 3. Create Data Subnet
$dataSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-data" `
    -AddressPrefix $dataSubnet
Write-Host "✅ Data Subnet configured: $dataSubnet" -ForegroundColor Green

Write-Host "`nDeploying Spoke VNet 1 (Workloads)..." -ForegroundColor Cyan

# 4. Create Spoke VNet 1
$spoke1Vnet = New-AzVirtualNetwork `
    -Name $spoke1VnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $spoke1Address `
    -Subnet @(
        $webSubnetConfig,
        $appSubnetConfig,
        $dataSubnetConfig
    ) `
    -Tag @{
        Purpose     = "Workload-Spoke"
        Tier        = "Production"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Spoke VNet 1 created successfully!" -ForegroundColor Green
Write-Host "Name: $($spoke1Vnet.Name)" -ForegroundColor Cyan
Write-Host "Address Space: $($spoke1Vnet.AddressSpace.AddressPrefixes)" -ForegroundColor Cyan

# 5. Display subnets
Write-Host "`n=== SPOKE 1 VNET SUBNETS ===" -ForegroundColor Cyan
$spoke1Vnet.Subnets |
    Select-Object Name, `
    @{N="AddressPrefix";E={$_.AddressPrefix}} |
    Format-Table -AutoSize

# 6. Save Spoke VNet ID for later use (Crucial for VNet Peering!)
$spoke1Vnet.Id | Out-File ".\spoke1-vnet-id.txt"
Write-Host "✅ Spoke VNet 1 ID saved to Cloud Shell storage!" -ForegroundColor Green

