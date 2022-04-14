param namePrefix string
param location string

var tmp = '${namePrefix}${uniqueString(resourceGroup().id)}'
var name = length(tmp) > 24 ? substring('${namePrefix}${uniqueString(resourceGroup().id)}', 0, 24) : tmp

resource sa 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity:{
    type:'SystemAssigned'
  }
  properties: {
    defaultToOAuthAuthentication: true
    isLocalUserEnabled: true
    isSftpEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: true
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

output name string = sa.name
output resourceId string = sa.id
