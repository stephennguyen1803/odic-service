package main

import (
	"database/sql"
	"flag"
	"fmt"

	_ "github.com/alexbrainman/odbc"
)

func main() {
	// Define the command line arguments
	dsn := flag.String("dsn", "YourDataSourceName", "Data Source Name")
	dbType := flag.String("dbtype", "oracle", "Database type (oracle or postgres)")
	user := flag.String("user", "", "The user to connect as")
	password := flag.String("password", "", "The password to connect with")

	// Parse the command line arguments
	flag.Parse()

	// Construct the connection string
	connStr := fmt.Sprintf("DSN=%s;UID=%s;PWD=%s", *dsn, *user, *password)

	// Open the database connection
	db, err := sql.Open("odbc", connStr)
	if err != nil {
		fmt.Println("Error connecting to the database: ", err)
		return
	}

	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		fmt.Println("Error pinging the database: ", err)
		return
	}

	var query string
	// Construct the connection string and query based on the database type
	if *dbType == "oracle" {
		query = "SELECT version FROM v$instance"
	} else if *dbType == "postgres" {
		query = "SELECT version()"
	} else {
		fmt.Println("Unsupported database type")
		return
	}

	// fmt.Println("Successfully connected to the database!")
	// Execute the query to get the database version
	var version string
	err = db.QueryRow(query).Scan(&version)
	if err != nil {
		fmt.Println("Error executing query:", err)
		return
	}

	fmt.Println("Database version:", version)
}
