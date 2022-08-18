// Add sql server and database
param prefix string
param resourceGroupLocation string = resourceGroup().location
param scriptUri string = 'https://raw.githubusercontent.com/fortunkam/wcf_database_appinsights/main/env/setup_database.sql'

var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

var contributorRoleDefinitionResourceId = resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)

@secure()
param sqlPassword string
param sqlUser string = 'mfadmin'
param utcValue string = utcNow()
param userIPAddress string



resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${prefix}-script-identity'
  location: resourceGroupLocation  
}

resource scriptIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${prefix}-script-identity', contributorRoleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: contributorRoleDefinitionResourceId
    principalId: scriptIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource sqlserver 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: '${prefix}-server'
  location: resourceGroupLocation
  properties: {
    administratorLogin: sqlUser
    administratorLoginPassword: sqlPassword
    version: '12.0'
    restrictOutboundNetworkAccess: 'Disabled'
    publicNetworkAccess: 'Enabled'
  }
}

resource userIPAddressFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  name: '${prefix}-user-ip-address-firewall-rule'
  parent: sqlserver
  properties: {
    endIpAddress: userIPAddress
    startIpAddress: userIPAddress
  }
}

resource sqldatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${prefix}-db'
  parent: sqlserver
  location: resourceGroupLocation
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}


resource createDatabaseTable 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${prefix}-create-db-table'
  location: resourceGroupLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentity.id}': {}
    }
  }
  dependsOn: [scriptIdentityRoleAssignment]
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '6.4'
    scriptContent: loadTextContent('./deploy_database.ps1')
    arguments: '-dbName \'${sqldatabase.name}\' -serverName \'${sqlserver.name}\' -sqlUser \'${sqlUser}\' -sqlPassword \'${sqlPassword}\' -resourceGroupName \'${resourceGroup().name}\' -scriptUri \'${scriptUri}\''
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output sqlServerName string = sqlserver.name
output sqlDatabaseName string = sqldatabase.name


