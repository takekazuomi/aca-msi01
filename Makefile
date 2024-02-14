PREFIX_NAME				?= acamsi
RESOURCE_GROUP				= $(PREFIX_NAME)-rg
LOCATION				= eastus2
#CONTAINERAPPS_NAME			= ca-$(PREFIX_NAME)
ENVIRONMENT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].name' -o tsv)
CONTAINERAPPS_ID			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/containerApps --query '[0].id' -o tsv)
ACR_NAME				?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.ContainerRegistry/registries --query '[0].name' -o tsv)
#ACR_PASSWORD				?= $(shell az acr credential show --name $(ACR_NAME) --query passwords[0].value)
STORAGE_ACCOUNT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.Storage/storageAccounts --query '[0].name' -o tsv)
STORAGE_ACCOUNT_CONTRIBUTOR_ROLE	?= $(shell az role definition list --query '[?roleName == `Storage Account Contributor`].name' -o tsv)

help:			## show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

acr-login:		## acr login
	az acr login --name $(ACR_NAME)

up:			## up service on azue
up: create-rg provision deploy

create-rg:		## create resouce group
	az group create \
	--name $(RESOURCE_GROUP) \
	--location "$(LOCATION)" \
	-o table

deploy-environment:
provision:		## deploy azure conteiner environment
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-env/main.bicep \
	-p \
	prefixName=$(PREFIX_NAME) \
	-o table

deploy-apps:
deploy:	package		## deploy msi check apps to azure conteiner
	env STORAGE_ACCOUNT_NAME=$(STORAGE_ACCOUNT_NAME) \
	pkl eval -f json web/envs.pkl > web/envs.json
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-app/main.bicep \
	-p \
	containerAppName=msicheck \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=$(ACR_NAME).azurecr.io/msicheck:latest \
	containerPort=5000 \
	acrName=$(ACR_NAME) \
	storageAccountName=$(STORAGE_ACCOUNT_NAME) \
	roleDefinitionName=$(STORAGE_ACCOUNT_CONTRIBUTOR_ROLE) \
	envs=@web/envs.json \
	-o table

pulish:
package: acr-login	## buid image and push to acr
	cd web; $(MAKE) publish KO_DOCKER_REPO=$(ACR_NAME).azurecr.io

env-list:		## show azure conteiner environment name
	@echo $(ENVIRONMENT_NAME)

show-endpoint:		## show endpoint
	az rest -u https://management.azure.com$(CONTAINERAPPS_ID)?api-version=2023-05-01 | \
	jq -r '.properties.latestRevisionFqdn'

acr-list:		## list acr repository
	az acr manifest list-metadata -r $(ACR_NAME) -n msicheck -o table

clean:			## clean
	az group delete \
	--name $(RESOURCE_GROUP)
