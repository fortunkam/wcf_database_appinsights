param([string] $dbName, 
    [string] $serverName, 
    [string] $sqlUser, 
    [string] $sqlPassword,
    [string] $resourceGroupName,
    [string] $scriptUri)

Install-Module -Name SqlServer -Force -Confirm:$false -AllowClobber -Scope CurrentUser
Write-Output "Imported module"
Get-Module SqlServer -ListAvailable | Write-Output
$publicIp = (Invoke-WebRequest http://myexternalip.com/raw).Content -replace "`n"
Write-Output $publicIp

Remove-AzSqlServerFirewallRule -FirewallRuleName create-table-deployment-script -ServerName $serverName -ResourceGroupName $resourceGroupName -Force

Start-Sleep -Seconds 10

New-AzSqlServerFirewallRule -ServerName $serverName -FirewallRuleName create-table-deployment-script -StartIpAddress $publicIp -EndIpAddress $publicIp -ResourceGroupName $resourceGroupName

Start-Sleep -Seconds 120

$sqlQuery = (Invoke-WebRequest -Uri $scriptUri -Method 'GET').Content

Write-Output $sqlQuery

$fullSqlServerFQDN = "$serverName.database.windows.net"

$sqlParams = @{
    'Database'       = $dbName
    'ServerInstance' = $fullSqlServerFQDN
    'Username'       = $sqlUser
    'Password'       = $sqlPassword
    'Query'          = $sqlQuery
}
Invoke-Sqlcmd @sqlParams