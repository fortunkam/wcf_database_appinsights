targetScope = 'subscription'

param prefix string = 'wcf-app'
param resourceGroupLocation string = deployment().location

@secure()
param sqlPassword string
param sqlUser string = 'mfadmin'
param userIPAddress string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name : '${prefix}-rg'
  location : resourceGroupLocation
}

module sql 'sql.bicep' = {
  name: '${prefix}-sql-deploy'
  scope: rg
  params: {
    prefix:  '${prefix}-sql'
    resourceGroupLocation: resourceGroupLocation
    sqlPassword: sqlPassword
    sqlUser: sqlUser
    userIPAddress: userIPAddress
  }
}

module logging 'logging.bicep' = {
  name: '${prefix}-logging-deploy'
  scope: rg
  params: {
    prefix:  '${prefix}-logging'
    resourceGroupLocation: resourceGroupLocation
  }
}
module app 'app.bicep' = {
  name: '${prefix}-app-deploy'
  scope: rg
  params: {
    prefix:  '${prefix}-app'
    resourceGroupLocation: resourceGroupLocation
    appInsightsInstrumentionKey: logging.outputs.instrumentationKey
    sqlServerName: sql.outputs.sqlServerName
    sqlDatabaseName: sql.outputs.sqlDatabaseName
    sqlUser: sqlUser
    sqlPassword: sqlPassword
  }
}


