param([string] $dbName, 
    [string] $serverName, 
    [string] $sqlUser, 
    [string] $sqlPassword,
    [string] $resourceGroupName)

Install-Module -Name SqlServer -Force -Confirm:$false -AllowClobber -Scope CurrentUser
Write-Output "Imported module"
Get-Module SqlServer -ListAvailable | Write-Output
$publicIp = (Invoke-WebRequest http://myexternalip.com/raw).Content -replace "`n"
Write-Output $publicIp

Remove-AzSqlServerFirewallRule -FirewallRuleName create-table-deployment-script -ServerName $serverName -ResourceGroupName $resourceGroupName -Force

Start-Sleep -Seconds 10

New-AzSqlServerFirewallRule -ServerName $serverName -FirewallRuleName create-table-deployment-script -StartIpAddress $publicIp -EndIpAddress $publicIp -ResourceGroupName $resourceGroupName

Start-Sleep -Seconds 120

$fullSqlServerFQDN = "$serverName.database.windows.net"

$sqlParams = @{
    'Database'       = $dbName
    'ServerInstance' = $fullSqlServerFQDN
    'Username'       = $sqlUser
    'Password'       = $sqlPassword
    'Query'          = 'CREATE TABLE dbo.test (id int, name varchar(50));'
}
Invoke-Sqlcmd @sqlParams