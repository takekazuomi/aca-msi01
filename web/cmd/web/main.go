package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	azlog "github.com/Azure/azure-sdk-for-go/sdk/azcore/log"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/storage/azblob"

	"github.com/gorilla/handlers"
	flag "github.com/spf13/pflag"
)

var (
	help bool   = false
	host string = ""
	port int    = 5000

	storageAccountName string
)

const EnvPrefix string = "MSI_"

func init() {
	fmt.Println("init()")
	flag.BoolVarP(&help, "help", "h", false, "show this help message")
	flag.StringVarP(&storageAccountName, "storage-account-name", "n", "", "storage account name")
	flag.StringVar(&host, "host", "", "listening host name")
	flag.IntVarP(&port, "port", "p", 5000, "listening port")
	flag.Parse()
	ApplyEnv(EnvPrefix)
	fmt.Println("end init()")
}

func ApplyEnv(prefix string) []error {
	errs := []error{}
	flag.VisitAll(func(f *flag.Flag) {
		n := fmt.Sprintf("%s%s", prefix, strings.ReplaceAll(strings.ToUpper(f.Name), "-", "_"))
		if val, ok := os.LookupEnv(n); ok {

			switch f.Value.Type() {
			case "bool":
				if _, err := strconv.ParseBool(val); err != nil {
					errs = append(errs, err)
				}
			}
			err := f.Value.Set(val)
			if err != nil {
				errs = append(errs, err)
			}

		}
		f.Usage = fmt.Sprintf("%s [%s]", f.Usage, n)
	})
	return errs
}

func GetCredential() (*azidentity.DefaultAzureCredential, error) {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		return nil, fmt.Errorf("azidentity.NewDefaultAzureCredential is error: %w", err)
	}

	return cred, nil
}

func ListContainer(ctx context.Context, cred *azidentity.DefaultAzureCredential) ([]string, error) {

	serviceClient, err := azblob.NewServiceClient(fmt.Sprintf("https://%v.blob.core.windows.net", storageAccountName), cred, nil)
	if err != nil {
		return nil, err
	}
	pager := serviceClient.ListContainers(nil)

	ret := []string{}
	for pager.NextPage(ctx) {
		resp := pager.PageResponse()

		for _, v := range resp.ContainerItems {
			ret = append(ret, *v.Name)
		}
	}

	return ret, nil
}

func setAzLogging() {
	// Set log to output to the console
	azlog.SetListener(func(_ azlog.Event, msg string) {
		log.Println(msg) // printing log out to the console
	})

	// Includes only requests and responses in credential logs
	azlog.SetEvents(azlog.EventRequest, azlog.EventResponse)
}

func main() {
	if help {
		flag.PrintDefaults()
		os.Exit(0)
	}

	http.HandleFunc("/msicheck", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		cred, err := GetCredential()
		if err != nil {
			m := fmt.Sprintf("GetCredential error: %v", err)
			log.Println(m)
			http.Error(w, m, http.StatusInternalServerError)
		}
		c, err := ListContainer(r.Context(), cred)
		for _, v := range c {
			w.Write([]byte(v))
			w.Write([]byte("\n"))
		}
	})

	addr := fmt.Sprintf("%v:%v", host, port)
	log.Printf("Listen %v\n", addr)
	setAzLogging()

	err := http.ListenAndServe(addr, handlers.LoggingHandler(os.Stdout, http.DefaultServeMux))
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
