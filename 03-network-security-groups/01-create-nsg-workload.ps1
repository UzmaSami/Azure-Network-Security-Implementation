# ============================================
# Script: create-nsg-workload.ps1
# Purpose: Create NSG for workload spoke with security rules
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

$rgName   = "rg-network-security"
$location = "uksouth"
$nsgName  = "nsg-workload-spoke1"

Write-Host "`nCreating Workload NSG Rules..." -ForegroundColor Cyan

# ---- INBOUND RULES ----

# Rule 1: Allow HTTPS from internet
$allowHTTPS = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-HTTPS-Inbound" `
    -Description "Allow HTTPS traffic from internet" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.1.1.0/24" `
    -DestinationPortRange 443 `
    -Access Allow

# Rule 2: Allow HTTP (redirect to HTTPS)
$allowHTTP = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-HTTP-Inbound" `
    -Description "Allow HTTP for redirect to HTTPS" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.1.1.0/24" `
    -DestinationPortRange 80 `
    -Access Allow

# Rule 3: Allow traffic from Hub VNet
$allowHub = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-Hub-Inbound" `
    -Description "Allow traffic from Hub VNet" `
    -Protocol * `
    -Direction Inbound `
    -Priority 200 `
    -SourceAddressPrefix "10.0.0.0/16" `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.1.0.0/16" `
    -DestinationPortRange * `
    -Access Allow

# Rule 4: Allow RDP from Management subnet only
$allowRDP = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-RDP-From-Management" `
    -Description "Allow RDP from management subnet only" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 300 `
    -SourceAddressPrefix "10.2.1.0/24" `
    -SourcePortRange * `
    -DestinationAddressPrefix "10.1.0.0/16" `
    -DestinationPortRange 3389 `
    -Access Allow

# Rule 5: DENY all other inbound
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

# Rule 6: Allow outbound to internet via Firewall
$allowOutbound = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-Outbound-Via-Firewall" `
    -Description "Allow outbound - forced through firewall" `
    -Protocol * `
    -Direction Outbound `
    -Priority 100 `
    -SourceAddressPrefix "10.1.0.0/16" `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange * `
    -Access Allow

# Create the NSG
Write-Host "Deploying NSG to Azure..." -ForegroundColor Cyan
$workloadNSG = New-AzNetworkSecurityGroup `
    -Name $nsgName `
    -ResourceGroupName $rgName `
    -Location $location `
    -SecurityRules @(
        $allowHTTPS,
        $allowHTTP,
        $allowHub,
        $allowRDP,
        $denyAll,
        $allowOutbound
    ) `
    -Tag @{
        Purpose     = "Workload-NSG"
        Scope       = "Spoke1"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Workload NSG created successfully!" -ForegroundColor Green

# Display all rules
Write-Host "`n=== NSG RULES ===" -ForegroundColor Cyan
$workloadNSG.SecurityRules |
    Select-Object Name, Priority, Direction, Access, Protocol, DestinationPortRange |
    Sort-Object Direction, Priority |
    Format-Table -AutoSize

