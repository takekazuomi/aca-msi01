param namePrefix string
param location string

var name = '${namePrefix}${uniqueString(resourceGroup().id)}'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output name string = name


