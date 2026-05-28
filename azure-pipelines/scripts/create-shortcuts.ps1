# Post-deployment script: Create shortcuts in target workspace
# Shortcuts don't deploy via Fabric Deployment Pipelines, so we create them separately
# This script runs after each deployment to ensure shortcuts exist in the target environment

param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceId,
    
    [Parameter(Mandatory=$true)]
    [string]$LakehouseId,
    
    [Parameter(Mandatory=$true)]
    [string]$TargetWorkspaceId,
    
    [Parameter(Mandatory=$true)]
    [string]$TargetLakehouseId
)

# Get Fabric API token (assumes az login or service principal auth)
$token = az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken -o tsv
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# Define shortcuts to create
$shortcuts = @(
    @{
        name = "shortcut_test"
        path = "Tables/shortcut_test"
        target = @{
            oneLake = @{
                workspaceId = $TargetWorkspaceId
                itemId = $TargetLakehouseId
                path = "Tables"
            }
        }
    }
    # Add more shortcuts here as needed
)

foreach ($shortcut in $shortcuts) {
    $body = $shortcut | ConvertTo-Json -Depth 5
    
    try {
        $response = Invoke-RestMethod `
            -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/items/$LakehouseId/shortcuts" `
            -Headers $headers `
            -Method Post `
            -Body $body
        
        Write-Host "Created shortcut: $($shortcut.name) in workspace $WorkspaceId"
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 409) {
            Write-Host "Shortcut already exists: $($shortcut.name) (skipping)"
        }
        else {
            Write-Warning "Failed to create shortcut: $($shortcut.name). Error: $_"
        }
    }
}

Write-Host "Shortcut creation complete."
