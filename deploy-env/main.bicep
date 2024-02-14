param prefixName string
param location string = resourceGroup().location

var environmentName = 'cae-${prefixName}'
var acrPrefixName = 'cr${prefixName}'
var saPrefixName = 'st${prefixName}'


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
    namePrefix: acrPrefixName
  }
}

module sa 'storage.bicep' = {
  name: 'sa'
  params: {
    location:location
    namePrefix: saPrefixName
  }
}
