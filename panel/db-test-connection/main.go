package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	log.Print("starting server...")

	dbConn, err := connectTCPSocket()

	if err != nil {
		log.Fatalf("could not create db connection: %v", err)
	}

	defer dbConn.Close()

	http.HandleFunc("/test", testDBConnection(dbConn))

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("listening on port %s", port)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func testDBConnection(dbConn *sql.DB) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {

		name := os.Getenv("NAME")
		if name == "" {
			name = "World"
		}

		fmt.Fprintf(w, "Hello %s!\n", name)

		stmt, err := dbConn.Prepare("SELECT * FROM panel")
		if err != nil {
			panic(err)
		}

		// Execute the statement.
		rows, err := stmt.Query()
		if err != nil {
			panic(err)
		}

		// Iterate over the rows.
		for rows.Next() {
			// Scan the row into a struct.
			// var user struct {
			// 	ID   int
			// 	Name string
			// }
			var all interface{}
			// err := rows.Scan(&user.ID, &user.Name)
			err := rows.Scan(&all)

			if err != nil {
				panic(err)
			}

			// Do something with the user.
			fmt.Println(all)
		}
	}
}

// connectTCPSocket initializes a TCP connection pool for a Cloud SQL
// instance of MySQL.
func connectTCPSocket() (*sql.DB, error) {
	mustGetenv := func(k string) string {
		v := os.Getenv(k)
		if v == "" {
			log.Fatalf("Fatal Error in main.go: %s environment variable not set.", k)
		}
		return v
	}
	// Note: Saving credentials in environment variables is convenient, but not
	// secure - consider a more secure solution such as
	// Cloud Secret Manager (https://cloud.google.com/secret-manager) to help
	// keep secrets safe.
	var (
		dbUser    = mustGetenv("DB_USER")       // e.g. 'my-db-user'
		dbPwd     = mustGetenv("DB_PASS")       // e.g. 'my-db-password'
		dbName    = mustGetenv("DB_NAME")       // e.g. 'my-database'
		dbPort    = mustGetenv("DB_PORT")       // e.g. '3306'
		dbTCPHost = mustGetenv("INSTANCE_HOST") // e.g. '127.0.0.1' ('172.17.0.1' if deployed to GAE Flex)
	)

	dbURI := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true",
		dbUser, dbPwd, dbTCPHost, dbPort, dbName)

	// dbPool is the pool of database connections.
	dbPool, err := sql.Open("mysql", dbURI)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %w", err)
	}

	// ...

	return dbPool, nil
}
