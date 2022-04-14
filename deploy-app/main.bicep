param environmentName string
param containerAppName string

param containerImage string
param containerPort int
param isExternalIngress bool = true
param location string = resourceGroup().location
param minReplicas int = 0
param transport string = 'auto'
param allowInsecure bool = false
param env array = []
param acrName string
param storageAccountName string
param roleDefinitionName string

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}

resource role 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: roleDefinitionName
}

module containerApps 'container.bicep' = {
  name: 'containerApps'
  params: {
    location: location
    containerAppName: containerAppName
    containerImage: containerImage
    containerPort: containerPort
    environmentId: environment.id
    isExternalIngress: isExternalIngress
    minReplicas: minReplicas
    transport: transport
    allowInsecure: allowInsecure
    env: env
    acrName: acrName
  }
}

module roleAssignment 'roleAssignment.bicep' = {
  name: 'roleAssignment'
  params: {
    roleDefinitionResourceId: role.id
    containerAppPrincipalId: containerApps.outputs.principalId
    containerAppResourceId: containerApps.outputs.id
    storageAccountName: storageAccountName
  }
}
output fqdn string = containerApps.outputs.fqdn
