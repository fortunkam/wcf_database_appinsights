param ([string] $sqlServerName, 
    [string] $webAppName, 
    [string] $resourceGroupName)

    $existingRules = Get-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName | where FirewallRuleName -Match '^wcf-app-sql-web-.*'

    $existingRules | ForEach-Object {
        Remove-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -FirewallRuleName $_.FirewallRuleName
    }

    Start-Sleep -Seconds 5

    $outboundAddressesString = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName | Select-Object OutboundIpAddresses

    $outboundAddressesString.OutboundIpAddresses.Split(",") | ForEach-Object {
        New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -FirewallRuleName "wcf-app-sql-web-$($_.Trim())" -StartIpAddress $_.Trim() -EndIpAddress $_.Trim()
    }


