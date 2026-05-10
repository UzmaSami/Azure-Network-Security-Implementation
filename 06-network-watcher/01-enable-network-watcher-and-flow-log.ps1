# ============================================
# Script: enable-network-watcher.ps1
# Purpose: Azure Network Security
# Author: Uzma Shabbir
# Date: May 2026
# ============================================
$rgName        = "rg-network-security"
$location      = "uksouth"
$workspaceName = "law-UzmaSami-hybrid-security-2026"
$nwName        = "NetworkWatcher_uksouth"

Write-Host "`n1. Connecting to Network Watcher..." -ForegroundColor Cyan
$networkWatcher = Get-AzNetworkWatcher -Name $nwName -ResourceGroupName "NetworkWatcherRG"

Write-Host "2. Connecting to Workspace..." -ForegroundColor Cyan
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $rgName -Name $workspaceName

Write-Host "3. Managing Storage..." -ForegroundColor Cyan
$storageName = "stuzmasamiflowlogs" + (Get-Random -Maximum 999)
$storageAccount = New-AzStorageAccount -ResourceGroupName $rgName -Name $storageName -Location $location -SkuName Standard_LRS -Kind StorageV2

# --- Function to enable logs (Latest 2026 Syntax) ---
function Enable-NSGFlowLog {
    param($nsgName, $flowLogName)
    $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -ErrorAction SilentlyContinue
    
    if ($nsg) {
        Write-Host "Activating Flow Logs for $nsgName..." -ForegroundColor Yellow
        # Removed RetentionInDays to match latest module requirements
        Set-AzNetworkWatcherFlowLog `
            -NetworkWatcher $networkWatcher `
            -Name $flowLogName `
            -TargetResourceId $nsg.Id `
            -StorageId $storageAccount.Id `
            -FormatVersion 2 `
            -EnableTrafficAnalytics `
            -WorkspaceResourceId $workspace.ResourceId `
            -WorkspaceGUID $workspace.CustomerId `
            -WorkspaceLocation $location | Out-Null
        Write-Host "✅ Monitoring is now LIVE for $nsgName" -ForegroundColor Green
    }
}

Enable-NSGFlowLog -nsgName "nsg-workload-spoke1" -flowLogName "fl-spoke1-uzma"
Enable-NSGFlowLog -nsgName "nsg-mgmt-spoke2" -flowLogName "fl-spoke2-uzma"

Write-Host "`n🚀 PROJECT FULLY SECURED & MONITORED" -ForegroundColor Cyan
Write-Host "Author: Uzma Shabbir" -ForegroundColor White

