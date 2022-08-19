param prefix string
param resourceGroupLocation string = resourceGroup().location
param sqlServerName string 
param sqlDatabaseName string
@secure()
param sqlPassword string
param sqlUser string
param scriptIdentityId string

param appInsightsInstrumentionKey string

var sqlConnectionString = 'Server=tcp:${sqlServerName}.database.windows.net,1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlUser};Password=${sqlPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${prefix}-appplan'
  location: resourceGroupLocation
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  kind: 'app'
}

resource webApplication 'Microsoft.Web/sites@2021-03-01' = {
  name: '${prefix}-site'
  location: resourceGroupLocation
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentionKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsightsInstrumentionKey}'
        }
      ]
      connectionStrings: [
        {
          name: 'PeopleDatabaseConnectionString'
          connectionString: sqlConnectionString
          type: 'SQLAzure'
        }
      ]
    }
  }
  kind: 'app'
}

resource createWebFirewallRules 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${prefix}-create-web-firewall-rules'
  location: resourceGroupLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '6.4'
    scriptContent: loadTextContent('./add_webapp_outboundip_to_sql.ps1')
    arguments: '-sqlServerName \'${sqlServerName}\' -webAppName \'${webApplication.name}\' -resourceGroupName \'${resourceGroup().name}\''
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}



