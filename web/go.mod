module msicheck

go 1.21

require (
	github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.2
	github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.5.1
	github.com/Azure/azure-sdk-for-go/sdk/storage/azblob v1.3.0
	github.com/gorilla/handlers v1.5.2
)

require github.com/golang-jwt/jwt/v5 v5.2.0 // indirect

require (
	github.com/Azure/azure-sdk-for-go/sdk/internal v1.5.2 // indirect
	github.com/AzureAD/microsoft-authentication-library-for-go v1.2.1 // indirect
	github.com/felixge/httpsnoop v1.0.4 // indirect
	github.com/golang-jwt/jwt v3.2.2+incompatible // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/kylelemons/godebug v1.1.0 // indirect
	github.com/pkg/browser v0.0.0-20240102092130-5ac0b6a4141c // indirect
	github.com/spf13/pflag v1.0.5
	golang.org/x/crypto v0.19.0 // indirect
	golang.org/x/net v0.21.0 // indirect
	golang.org/x/sys v0.17.0 // indirect
	golang.org/x/text v0.14.0 // indirect
)

// https://github.com/Azure/azure-sdk-for-go/issues/17472#issuecomment-1092926620
replace (
	github.com/Azure/azure-sdk-for-go/sdk/azcore v0.23.0 => github.com/Azure/azure-sdk-for-go/sdk/azcore v0.22.0
	github.com/Azure/azure-sdk-for-go/sdk/azidentity v0.14.0 => github.com/Azure/azure-sdk-for-go/sdk/azidentity v0.13.0
	github.com/Azure/azure-sdk-for-go/sdk/internal v0.9.2 => github.com/Azure/azure-sdk-for-go/sdk/internal v0.9.1
)
