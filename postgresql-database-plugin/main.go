package main

import (
	"log"
	"os"

	dbplugin "github.com/hashicorp/vault/sdk/database/dbplugin/v5"
	"github.com/moayadi/newpostgresql"
)

func main() {
	err := Run()
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
}

// Run instantiates a PostgreSQL object, and runs the RPC server for the plugin
func Run() error {
	dbType, err := newpostgresql.New()
	if err != nil {
		return err
	}

	dbplugin.Serve(dbType.(dbplugin.Database))

	return nil
}
