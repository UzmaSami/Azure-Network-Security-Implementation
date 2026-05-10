# ============================================
# Script: setup-secure-hub.ps1 (Cloud Shell Version)
# Purpose: Build the Security Hub (VNet & Subnets)
# Project: Network Security Baseline 2026
# ============================================

# Variables
$rgName      = "rg-network-security"
$location    = "uksouth"
$vnetName    = "vnet-hub-uksouth"
$vnetAddress = "10.0.0.0/16"

# Define Subnets (Names must be EXACT for Azure to recognize them)
$subnets = @()
$subnets += New-AzVirtualNetworkSubnetConfig -Name "AzureFirewallSubnet" -AddressPrefix "10.0.1.0/26"
$subnets += New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet"  -AddressPrefix "10.0.2.0/26"
$subnets += New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet"       -AddressPrefix "10.0.3.0/27"
$subnets += New-AzVirtualNetworkSubnetConfig -Name "sn-management"       -AddressPrefix "10.0.4.0/24"

Write-Host "Creating Resource Group: $rgName..." -ForegroundColor Cyan
New-AzResourceGroup -Name $rgName -Location $location -Force

Write-Host "Deploying Secure Hub VNet..." -ForegroundColor Cyan
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name $vnetName `
    -AddressPrefix $vnetAddress `
    -Subnet $subnets

Write-Host "✅ Network Infrastructure Ready!" -ForegroundColor Green

