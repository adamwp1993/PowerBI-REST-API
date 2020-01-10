# Install-Module -Name MicrosoftPowerBIMgmt

Connect-PowerBIServiceAccount

# Get all reports in all workspaces NOTE: this only reports on workspaces that have reports in them
# If you needed to you could run a seperate get-Workspace into a CSV, have that as a seperate table and create a   # one to many relationship from
# the workspace table to the Report table using workspace ID as primary / foreign keys

$dataArray = @()
$refreshHistory = @()

#Loop through the workspaces , for each workspace, loop through reports

$workspaces = Get-PowerBiWorkspace -First 5000 -Scope Organization #5000 workspaces is a hard limit on this cmdlet, you would need to implement paging if you had more =]

foreach($workspace in $workspaces) {

    $reports = Get-PowerBIReport -WorkspaceID $workspace.Id -Scope Organization
    write-output $workspace
    foreach($report in $reports) {
        # Add an object to the array
        if ($report.Id) { # if the report ID is not null
        $dataSetID = $report.DatasetID
        $dataSetInfo = Get-PowerBIDataset -Scope Organization -Id $dataSetID
        $dataArray += new-object psobject -property @{workspaceName = $workspace.Name; workspaceID = $workspace.ID; 
        reportName = $report.Name; reportID = $report.Id; datasetOwner = $dataSetInfo.ConfiguredBy }

       }

    }

}


$dataArray | Export-Csv -Path "C:\Users\adpeters\Desktop\allReports.csv" #path here
