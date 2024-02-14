param roleDefinitionResourceId string
param containerAppPrincipalId string
param containerAppResourceId string
param storageAccountName string

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource storageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerAppResourceId, containerAppPrincipalId, roleDefinitionResourceId)
  scope: sa
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: containerAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

