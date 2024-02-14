---
title: Azure Container Apps MSI Sample code
---

## Abstract

Access [Azure Storage](https://learn.microsoft.com/en-us/azure/storage/) from [Azure ContainerApps(ACA)](https://learn.microsoft.com/ja-jp/azure/container-apps/overview) using a [system-managed identities for Azure resources](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview).


1. Create resource group. `make create-rg`
2. Deploy ACA Environmanet. `make deploy-environment`
3. Upload some date to storage. you can find storage account in created resource group.
4. Deploy ACA App with MSI. `make deploy-apps`

## bootstrap

This sample requires the following tools to be installed:

- How to install [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
- How to install [ko build](https://ko.build/install/).
- How to install [pkl](https://pkl-lang.org/main/current/pkl-cli/index.html#installation).

Installing azure cli is a little complicated, so we recommend you refer to the [link](Installing azure cli is a little complicated, so we recommend you refer to the link.).

```sh
# ko build
$ go install github.com/google/ko@latest
$ ko version
v0.15.1
# pkl
$ curl -L -o pkl https://github.com/apple/pkl/releases/download/0.25.2/pkl-linux-amd64
chmod +x pkl
./pkl --version
Pkl 0.25.2 (Linux 5.15.0-1050-aws, native)
```

After this move pkl to your local bin directory. Ex: `mv ./pkl ~/.local/bin`

## directory structure

```
.
├── deploy-app  # Azure Container Apps deploy scripts
├── deploy-env  # Azure Container Environment deploy scripts
└── web         # web server Go source
    └── cmd
        └── msicheck
```

## howto execute

quick start

1. az login
2. make up

or step by step

1. az login
2. make create-rg
3. make provision
4. make deploy

Note: If you want to deploy with a different resource group name, set the environment variable PREFIX_NAME. I recommend writing the configuration in .envrc.local.
