param prefix string
param resourceGroupLocation string = resourceGroup().location

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${prefix}-workspace'
  location: resourceGroupLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${prefix}-app-insights'
  location: resourceGroupLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
