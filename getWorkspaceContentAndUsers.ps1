# NOTE: THIS IS OPEN SOURCE "SAMPLE CODE". MICROSOFT SUPPORT WILL NOT DEBUG THIS SCRIPT. THIS IS PURELY A PERSONAL PROJECT.


# This script creates seperate CSV files that house all Workspace info, users in the workspace and permission levels, 
# all reports in the workspace , all datasets in the workspace. 


# RELATIONSHIPS - how to relate the tables in PowerBI desktop 
# workspaceTable(workspaceID) 1 -> M userTable(workspaceID)
# workspaceTable(workspaceID) 1 -> M reportTable(workspaceID)
# reportTable(datasetID) 1 -> 1 datasetTabe(datasetID)

Connect-PowerBIServiceAccount 


# Requirements: PowerBI Service Administrator  

$workspacesTable = @()
$reportsTable = @()
$datasetsTable = @()
$workspaceUsersTable = @()

$workspaces = Get-PowerBiWorkspace -First 5000 -Scope Organization #5000 workspaces is a hard limit on this cmdlet, you would need to implement paging if you had more =]

foreach($workspace in $workspaces) {
  
    write-output $workspace
    # Build Workspace table
    $workspacesTable += new-object psobject -property @{ workspaceID = $workspace.Id; Premium = $workspace.IsOnDedicatedCapacity; capacityID = $workspace.CapacityId; 
    WorkspaceName = $workspace.Name; State = $workspace.State }
    $workspacesTable += $workspaceObj
    
    #Build users table
    foreach($user in $workspace.Users) {
    if( !([string]::IsNullOrEmpty($user.UserPrincipalName ))) {
        $workspaceUsersTable += new-object psobject -property @{ workspaceID = $workspace.Id; username = $user.UserPrincipalName; permission = $user.AccessRight }
        
        }

    }
      
    $reports = Get-PowerBIReport -WorkspaceID $workspace.Id -Scope Organization
    foreach($report in $reports) {

        
        if ($report.Id) { # if the report ID is not null 
            # Build report table
            $reportsTable += new-object psobject -property @{ workspaceID = $workspace.ID; reportName = $report.Name;
            reportID = $report.Id; datasetID = $report.DatasetID; embedURL = $report.EmbedUrl }


            $dataSetInfo = Get-PowerBIDataset -Scope Organization -Id $report.DatasetID

            # Build dataset table
            $datasetsTable += new-object psobject -property @{datasetID = $datasetInfo.Id; datasetOwner = $datasetInfo.ConfiguredBy; requiresGateway = $datasetInfo.IsOnPremGatewayRequired;
            Datasources = $datasetInfo.Datasources; DatasetName = $datasetInfo.Name; }

        }
 
    }
    
}


$workspacesTable | Export-Csv -Path "C:\Users\adpeters\Desktop\WorkspaceTable.csv"
$reportsTable | Export-Csv -Path "C:\Users\adpeters\Desktop\ReportTable.csv" 
$datasetsTable | Export-Csv -Path "C:\Users\adpeters\Desktop\DatasetTable.csv"
$workspaceUsersTable | Export-Csv -Path "C:\Users\adpeters\Desktop\UsersTable.csv"
