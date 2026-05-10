# ============================================
# Script: setup-nsg-management.ps1
# Purpose: Create NSG for Management Spoke and attach to subnets
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

$rgName   = "rg-network-security"
$location = "uksouth"
$nsgName  = "nsg-management-spoke2"
$vnetName = "vnet-spoke2-management"

Write-Host "`nCreating Management NSG Rules..." -ForegroundColor Cyan

# ---- INBOUND RULES ----

# Rule 1a: Allow RDP from VPN Gateway
$allowVPNRDP = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-VPN-RDP-Inbound" `
    -Description "Allow RDP from VPN Gateway" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix "10.0.3.0/27" `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.2.0.0/16" `
    -DestinationPortRange 3389 `
    -Access Allow

# Rule 1b: Allow SSH from VPN Gateway
$allowVPNSSH = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-VPN-SSH-Inbound" `
    -Description "Allow SSH from VPN Gateway" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix "10.0.3.0/27" `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.2.0.0/16" `
    -DestinationPortRange 22 `
    -Access Allow

# Rule 2: Allow traffic from Hub VNet
$allowHub = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-Hub-Inbound" `
    -Description "Allow traffic from Hub VNet" `
    -Protocol * `
    -Direction Inbound `
    -Priority 200 `
    -SourceAddressPrefix "10.0.0.0/16" `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.2.0.0/16" `
    -DestinationPortRange * `
    -Access Allow

# Rule 3: DENY all other inbound
$denyAll = New-AzNetworkSecurityRuleConfig `
    -Name "Deny-All-Inbound" `
    -Description "Deny all other inbound traffic" `
    -Protocol * `
    -Direction Inbound `
    -Priority 4000 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange * `
    -Access Deny

# ---- OUTBOUND RULES ----

# Rule 4: Allow outbound to internet via Firewall
$allowOutbound = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-Outbound-Via-Firewall" `
    -Description "Allow outbound - forced through firewall" `
    -Protocol * `
    -Direction Outbound `
    -Priority 100 `
    -SourceAddressPrefix "10.2.0.0/16" `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange * `
    -Access Allow

# 1. Create the NSG
Write-Host "Deploying Management NSG to Azure..." -ForegroundColor Cyan
$mgmtNSG = New-AzNetworkSecurityGroup `
    -Name $nsgName `
    -ResourceGroupName $rgName `
    -Location $location `
    -SecurityRules @(
        $allowVPNRDP,
        $allowVPNSSH,
        $allowHub,
        $denyAll,
        $allowOutbound
    ) `
    -Tag @{
        Purpose     = "Management-NSG"
        Scope       = "Spoke2"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Management NSG created successfully!" -ForegroundColor Green

# 2. Attach the NSG to Spoke 2 Subnets
Write-Host "`nRetrieving Spoke 2 VNet to apply security..." -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

Write-Host "Attaching NSG to Management Subnets..." -ForegroundColor Cyan

Set-AzVirtualNetworkSubnetConfig -Name "snet-admin" `
    -VirtualNetwork $vnet `
    -AddressPrefix "10.2.1.0/24" `
    -NetworkSecurityGroup $mgmtNSG | Out-Null
Write-Host "✅ NSG attached to snet-admin" -ForegroundColor Green

Set-AzVirtualNetworkSubnetConfig -Name "snet-monitoring" `
    -VirtualNetwork $vnet `
    -AddressPrefix "10.2.2.0/24" `
    -NetworkSecurityGroup $mgmtNSG | Out-Null
Write-Host "✅ NSG attached to snet-monitoring" -ForegroundColor Green

Set-AzVirtualNetworkSubnetConfig -Name "snet-security" `
    -VirtualNetwork $vnet `
    -AddressPrefix "10.2.3.0/24" `
    -NetworkSecurityGroup $mgmtNSG | Out-Null
Write-Host "✅ NSG attached to snet-security" -ForegroundColor Green

# 3. Save Changes
Write-Host "`nSaving network configuration to Azure (This takes 10-20 seconds)..." -ForegroundColor Yellow
Set-AzVirtualNetwork -VirtualNetwork $vnet | Out-Null

Write-Host "🔐 Management Spoke is now fully secured!" -ForegroundColor Green

# Display all rules for verification
Write-Host "`n=== MANAGEMENT NSG RULES ===" -ForegroundColor Cyan
$mgmtNSG.SecurityRules |
    Select-Object Name, Priority, Direction, Access, Protocol |
    Sort-Object Direction, Priority |
    Format-Table -AutoSize

