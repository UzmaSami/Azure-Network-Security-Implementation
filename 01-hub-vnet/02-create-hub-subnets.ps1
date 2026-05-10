# ============================================
# Script: create-hub-subnets.ps1
# Purpose: Create Hub VNet with all required
#          subnets for security architecture
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# ============================================

# ============================================
# VARIABLES
# ============================================
$location          = "uksouth"
$rgName            = "rg-network-security"
$hubVnetName       = "vnet-hub-uksouth"
$hubAddressSpace   = "10.0.0.0/16"

# Subnet address spaces
$firewallSubnet    = "10.0.1.0/26"   # Must be /26 minimum for Azure Firewall
$bastionSubnet     = "10.0.2.0/26"   # Updated to /26 for modern Azure Bastion
$gatewaySubnet     = "10.0.3.0/27"   # For VPN/ExpressRoute Gateway
$managementSubnet  = "10.0.4.0/24"   # For management VMs

# 1. Ensure Resource Group Exists
Write-Host "`nVerifying Resource Group..." -ForegroundColor Cyan
New-AzResourceGroup -Name $rgName -Location $location -Force | Out-Null

Write-Host "`nCreating Hub VNet Subnets..." -ForegroundColor Cyan

# 2. Create Azure Firewall Subnet
$firewallSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "AzureFirewallSubnet" `
    -AddressPrefix $firewallSubnet
Write-Host "✅ Firewall Subnet configured: $firewallSubnet" -ForegroundColor Green

# 3. Create Azure Bastion Subnet
$bastionSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "AzureBastionSubnet" `
    -AddressPrefix $bastionSubnet
Write-Host "✅ Bastion Subnet configured: $bastionSubnet" -ForegroundColor Green

# 4. Create Gateway Subnet
$gatewaySubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -AddressPrefix $gatewaySubnet
Write-Host "✅ Gateway Subnet configured: $gatewaySubnet" -ForegroundColor Green

# 5. Create Management Subnet
$mgmtSubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "snet-management" `
    -AddressPrefix $managementSubnet
Write-Host "✅ Management Subnet configured: $managementSubnet" -ForegroundColor Green

# 6. Create the Hub VNet with all subnets
Write-Host "`nCreating Hub Virtual Network..." -ForegroundColor Cyan
$hubVnet = New-AzVirtualNetwork `
    -Name $hubVnetName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AddressPrefix $hubAddressSpace `
    -Subnet @(
        $firewallSubnetConfig,
        $bastionSubnetConfig,
        $gatewaySubnetConfig,
        $mgmtSubnetConfig
    ) `
    -Tag @{
        Purpose     = "Hub-Network"
        Security    = "High"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Hub VNet created successfully!" -ForegroundColor Green
Write-Host "VNet Name:     $($hubVnet.Name)" -ForegroundColor Cyan
Write-Host "Address Space: $($hubVnet.AddressSpace.AddressPrefixes)" -ForegroundColor Cyan
Write-Host "Location:      $($hubVnet.Location)" -ForegroundColor Cyan

# 7. Display all subnets
Write-Host "`n=== HUB VNET SUBNETS ===" -ForegroundColor Cyan
$hubVnet.Subnets | 
    Select-Object Name, `
    @{N="AddressPrefix";E={$_.AddressPrefix}} |
    Format-Table -AutoSize

# 8. Save VNet ID for later use
$hubVnet.Id | Out-File ".\hub-vnet-id.txt"
Write-Host "✅ Hub VNet ID saved to Cloud Shell storage!" -ForegroundColor Green

