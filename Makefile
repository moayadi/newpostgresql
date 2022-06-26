GOARCH = amd64

UNAME = $(shell uname -s)

ifndef OS
	ifeq ($(UNAME), Linux)
		OS = linux
	else ifeq ($(UNAME), Darwin)
		OS = darwin
	endif
endif

.DEFAULT_GOAL := all

all: fmt build start

build:
	GO111MODULE=on GOOS=$(OS) GOARCH="$(GOARCH)" go build -o plugins/postgres-new postgresql-database-plugin/main.go

start:
	./vault server -dev -dev-root-token-id=root -log-level=trace -dev-plugin-dir=./plugins &


register:
	./vault write sys/plugins/catalog/database/postgres-new sha256=$SHA256 command=postgres-new

enable:
	./vault secrets enable database
	./vault write database/config/postgresql \
     plugin_name=postgres-new \
     connection_url="postgresql://{{username}}:{{password}}@localhost:5431,localhost:5432/postgres?sslmode=disable" \
     allowed_roles=readonly \
     username="postgres" \
     password="secretpass"
 
 disable:
	./vault secrets disable database

kill:
	pkill -f vault



deploy:
	./vault write awsnew/sts/s3-readonly ttl=60m

clean:
	rm -f ./vault/plugins/awsnew

fmt:
	go fmt $$(go list ./...)

register:
	export SHA256=$(sha256sum ./vault/plugins/awsnew | cut -d ' ' -f1)
	echo $SHA256
	vault plugin register -sha256=$SHA256 secret new

.PHONY: build clean fmt start enable
