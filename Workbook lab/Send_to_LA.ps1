Add-Type -AssemblyName System.Web

$DcrImmutableId = "" # id available in DCR > JSON view > immutableId
$DceURI = "" # available in DCE > Logs Ingestion value
$Table = "KQL_Lab" # custom log to create

$tenantId = "" #the tenant ID in which the Data Collection Endpoint resides
$appId = "" #the app ID created and granted permissions
$appSecret = "" #the secret created for the above app - never store your secrets in the source code

$CSV_Lab = ".\BIOS_Lab.csv"
$Get_CSV_FirstLine = Get-Content $CSV_Lab | Select -First 1
$Get_Delimiter = If($Get_CSV_FirstLine.Split(";").Length -gt 1){";"}Else{","};
$Import_CSV = import-csv $CSV_Lab -Delimiter $Get_Delimiter	
$Body_JSON = $Import_CSV | ConvertTo-Json

$scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type" = "application/x-www-form-urlencoded" };
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token

$headers = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" };
$uri = "$DceURI/dataCollectionRules/$DcrImmutableId/streams/Custom-$Table"+"?api-version=2023-01-01";
$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $Body_JSON -Headers $headers;