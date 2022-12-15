$Members = @()

$Organization = 'Test'
$PAT = 'PATToken'

$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) }
$UriOrganization = "https://dev.azure.com/$($Organization)/"

$top_param=50
$skip_param=0


$uriProject = $UriOrganization + "_apis/projects"
$ProjectsResult = Invoke-RestMethod -Uri $uriProject -Method get -Headers $AzureDevOpsAuthenicationHeader

Foreach ($project in $ProjectsResult.value)
{
    do
    {
        $uriTeams = $UriOrganization + "_apis/projects/$($project.id)/teams?$top=$($top_param)&$skip=$($skip_param)"
        $TeamsResult = Invoke-RestMethod -Uri $uriTeams -Method get -Headers $AzureDevOpsAuthenicationHeader
        Foreach ($team in $TeamsResult.value)
        {
            $uriTeamMembers = $UriOrganization + "_apis/projects/$($project.id)/teams/$($team.id)/members?$top=$($top_param)&$skip=$($skip_param)"
            $TeamMembersResult = Invoke-RestMethod -Uri $uriTeamMembers -Method get -Headers $AzureDevOpsAuthenicationHeader
            Foreach ($teamMember in $TeamMembersResult.value)
            {
                $Members += New-Object -TypeName PSObject -Property @{
                    ProjectID=$project.id
                    ProjectName=$project.name
                    TeamID=$team.id
                    TeamName=$team.name
                    TeamDescription=$team.description
                    MemberID=$teamMember.identity.id
                    MemberName=$teamMember.identity.displayName
                    MemberEmail=$teamMember.identity.uniqueName
                }
            }
        }
        $Members | ConvertTo-Json | Out-File -FilePath "Test\file.json" 