# ============================================
# Script: create-firewall.ps1
# Purpose: Deploy Azure Firewall in Hub VNet for centralized traffic inspection
# Author: Uzma Shabbir
# Date: April 2026
# Region: UK South
# Project: Network Security Baseline
# ============================================

$rgName        = "rg-network-security"
$location      = "uksouth"
$hubVnetName   = "vnet-hub-uksouth"
$firewallName  = "afw-hub-uksouth"
$pipName       = "pip-firewall-uksouth"
$policyName    = "afwpol-hub-uksouth"

Write-Host "`nDeploying Azure Firewall Infrastructure..." -ForegroundColor Cyan
Write-Host "⚠️  Please note: This deployment typically takes 10-15 minutes to complete!" -ForegroundColor Yellow

# Step 1: Create Public IP for Firewall
Write-Host "`n1. Creating Firewall Public IP..." -ForegroundColor Cyan

$firewallPIP = New-AzPublicIpAddress `
    -Name $pipName `
    -ResourceGroupName $rgName `
    -Location $location `
    -AllocationMethod Static `
    -Sku Standard `
    -Tag @{
        Purpose     = "Firewall-PIP"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Public IP created: $($firewallPIP.IpAddress)" -ForegroundColor Green

# Step 2: Create Firewall Policy
Write-Host "`n2. Creating Firewall Policy..." -ForegroundColor Cyan

$firewallPolicy = New-AzFirewallPolicy `
    -Name $policyName `
    -ResourceGroupName $rgName `
    -Location $location `
    -ThreatIntelMode Alert `
    -Tag @{
        Purpose     = "Firewall-Policy"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    } -Force

Write-Host "✅ Firewall Policy created!" -ForegroundColor Green

# Step 3: Get Hub VNet
Write-Host "`n3. Retrieving Hub VNet..." -ForegroundColor Cyan
$hubVnet = Get-AzVirtualNetwork `
    -Name $hubVnetName `
    -ResourceGroupName $rgName

# Step 4: Deploy Azure Firewall
Write-Host "`n4. Deploying Azure Firewall (Sit back and relax, this takes a while)..." -ForegroundColor Yellow

$firewall = New-AzFirewall `
    -Name $firewallName `
    -ResourceGroupName $rgName `
    -Location $location `
    -VirtualNetwork $hubVnet `
    -PublicIpAddress $firewallPIP `
    -FirewallPolicyId $firewallPolicy.Id `
    -SkuTier Standard `
    -Tag @{
        Purpose     = "Hub-Firewall"
        Security    = "Critical"
        Environment = "Production"
        Project     = "Network-Security-Baseline"
        Author      = "Uzma Shabbir"
    }

Write-Host "`n✅ Azure Firewall deployed successfully!" -ForegroundColor Green
Write-Host "Firewall Name:       $($firewall.Name)" -ForegroundColor Cyan
Write-Host "Private IP:          $($firewall.IpConfigurations[0].PrivateIPAddress)" -ForegroundColor Cyan
Write-Host "Public IP:           $($firewallPIP.IpAddress)" -ForegroundColor Cyan

# Save firewall private IP for route table
$firewallPrivateIP = $firewall.IpConfigurations[0].PrivateIPAddress
$firewallPrivateIP | Out-File ".\firewall-private-ip.txt"

Write-Host "`n⭐ SAVE THIS IP: $firewallPrivateIP ⭐" -ForegroundColor Yellow
Write-Host "It has been saved to 'firewall-private-ip.txt' in your Cloud Shell." -ForegroundColor Yellow
Write-Host "You will need this exact IP for your Route Tables in the next step!" -ForegroundColor Yellow
