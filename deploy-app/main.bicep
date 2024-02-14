param environmentName string
param containerAppName string

param containerImage string
param containerPort int
param isExternalIngress bool = true
param location string = resourceGroup().location
param minReplicas int = 0
param transport string = 'auto'
param allowInsecure bool = false
param envs string
param acrName string
param storageAccountName string
param roleDefinitionName string

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: environmentName
}

resource role 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roleDefinitionName
}

var env = json(envs).envs

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
output envs array = env
