param prefixName string
param location string = resourceGroup().location

//var environmentName = 'env-${prefixName}-${uniqueString(resourceGroup().id)}'
var environmentName = 'acaenv-${prefixName}'

module environment './environment.bicep' = {
  name: 'environment'
  params: {
    location: location
    environmentName: environmentName
  }
}

module acr 'acr.bicep' = {
  name: 'acr'
  params: {
    location: location
    namePrefix: prefixName
  }
}
module sa 'storage.bicep' = {
  name: 'sa'
  params: {
    location:location
    namePrefix: prefixName
  }
}
