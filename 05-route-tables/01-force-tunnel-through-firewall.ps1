# ============================================
# Script: force-tunnel-through-firewall.ps1
# Purpose: Create route tables to force ALL traffic through Azure Firewall
# Author: Uzma Shabbir
# Date: April 2026
# Project: Network-Security-Baseline
# ============================================

$rgName           = "rg-network-security"
$location         = "uksouth"
$spoke1VnetName   = "vnet-spoke1-workloads"
$spoke2VnetName   = "vnet-spoke2-management"

# 1. Get Firewall Private IP (Automatically if file exists, or prompt)
if (Test-Path ".\firewall-private-ip.txt") {
    $firewallPrivateIP = Get-Content ".\firewall-private-ip.txt"
} else {
    Write-Host "Firewall IP file not found. Fetching from Azure..." -ForegroundColor Yellow
    $fw = Get-AzFirewall -ResourceGroupName $rgName | Select-Object -First 1
    $firewallPrivateIP = $fw.IpConfigurations[0].PrivateIPAddress
}

Write-Host "Using Firewall Private IP: $firewallPrivateIP" -ForegroundColor Cyan

# 2. Create Route Table for Spoke 1 (Workloads)
Write-Host "Configuring Route Table for Spoke 1..." -ForegroundColor Cyan
$rt1 = New-AzRouteTable `
    -Name "rt-spoke1-workloads" `
    -ResourceGroupName $rgName `
    -Location $location `
    -Tag @{Author="Uzma Shabbir"; Project="Network-Security-Baseline"} -Force

$rt1 | Add-AzRouteConfig `
    -Name "default-route" `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $firewallPrivateIP | Set-AzRouteTable | Out-Null

# 3. Create Route Table for Spoke 2 (Management)
Write-Host "Configuring Route Table for Spoke 2..." -ForegroundColor Cyan
$rt2 = New-AzRouteTable `
    -Name "rt-spoke2-management" `
    -ResourceGroupName $rgName `
    -Location $location `
    -Tag @{Author="Uzma Shabbir"; Project="Network-Security-Baseline"} -Force

$rt2 | Add-AzRouteConfig `
    -Name "default-route" `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $firewallPrivateIP | Set-AzRouteTable | Out-Null

# 4. Associate with ALL Spoke Subnets
Write-Host "Associating routes with subnets..." -ForegroundColor Cyan

# Spoke 1 Subnets
$vnet1 = Get-AzVirtualNetwork -Name $spoke1VnetName -ResourceGroupName $rgName
$subnets1 = @("snet-web", "snet-app", "snet-data")
foreach ($s in $subnets1) {
    Set-AzVirtualNetworkSubnetConfig -Name $s -VirtualNetwork $vnet1 `
        -AddressPrefix ($vnet1.Subnets | Where-Object {$_.Name -eq $s}).AddressPrefix `
        -RouteTable $rt1 | Out-Null
    Write-Host "✅ Attached to $s" -ForegroundColor Green
}
$vnet1 | Set-AzVirtualNetwork | Out-Null

# Spoke 2 Subnets
$vnet2 = Get-AzVirtualNetwork -Name $spoke2VnetName -ResourceGroupName $rgName
$subnets2 = @("snet-admin", "snet-monitoring", "snet-security")
foreach ($s in $subnets2) {
    Set-AzVirtualNetworkSubnetConfig -Name $s -VirtualNetwork $vnet2 `
        -AddressPrefix ($vnet2.Subnets | Where-Object {$_.Name -eq $s}).AddressPrefix `
        -RouteTable $rt2 | Out-Null
    Write-Host "✅ Attached to $s" -ForegroundColor Green
}
$vnet2 | Set-AzVirtualNetwork | Out-Null

Write-Host "`n🚀 DEPLOYMENT COMPLETE" -ForegroundColor Cyan
Write-Host "Author: Uzma Shabbir" -ForegroundColor White
Write-Host "All spoke traffic is now forced through the Hub Firewall!" -ForegroundColor Green

