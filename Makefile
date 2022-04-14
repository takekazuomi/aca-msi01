PREFIX_NAME				= acamsi
RESOURCE_GROUP				= $(PREFIX_NAME)-rg
LOCATION				= canadacentral
CONTAINERAPPS_NAME			= aca-$(PREFIX_NAME)
ENVIRONMENT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].name' -o tsv)
CONTAINERAPPS_ID			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/containerApps --query '[0].id' -o tsv)
ACR_NAME				?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.ContainerRegistry/registries --query '[0].name' -o tsv)
ACR_PASSWORD				?= $(shell az acr credential show --name $(ACR_NAME) --query passwords[0].value)
STORAGE_ACCOUNT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.Storage/storageAccounts --query '[0].name' -o tsv)
STORAGE_ACCOUNT_CONTRIBUTOR_ROLE	?= $(shell az role definition list --query '[?roleName == `Storage Account Contributor`].name' -o tsv)

help:			## show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

setup: 			## initial setup. only for first time
setup: setup-azcli acr-login

setup-azcli:
	-az extension remove -n containerapp -o none
	az extension add --name containerapp

acr-login:		## acr login
	az acr login --name $(ACR_NAME)
	@echo $(ACR_PASSWORD) | docker login -u $(ACR_NAME) --password-stdin $(ACR_NAME).azurecr.io

create-rg:		## create resouce group
	az group create \
	--name $(RESOURCE_GROUP) \
	--location "$(LOCATION)"

deploy-environment:	## deploy environment
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-env/main.bicep \
	-p \
	prefixName=$(PREFIX_NAME) \
	-o table

deploy-apps:		## deploy msi check app
	envsubst < web/env.json.template > web/env.json
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-app/main.bicep \
	-p \
	containerAppName=msicheck \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=$(ACR_NAME).azurecr.io/msicheck:latest \
	containerPort=5000 \
	acrName=$(ACR_NAME) \
	storageAccountName=$(STORAGE_ACCOUNT_NAME) \
	roleDefinitionName=$(STORAGE_ACCOUNT_CONTRIBUTOR_ROLE) \
	env=@web/env.json

acr-push:		## buid image and push to acr
	cd web; $(MAKE) push IMAGE_NAME=$(ACR_NAME).azurecr.io/msicheck

env-list:		## show environment_name
	@echo $(ENVIRONMENT_NAME)

show-endpoint:		## show endpoint
	az rest -u https://management.azure.com$(CONTAINERAPPS_ID)?api-version=2022-01-01-preview | \
	jq -r '.properties.latestRevisionFqdn'

clean:			## clean
	az group delete \
	--name $(RESOURCE_GROUP)

