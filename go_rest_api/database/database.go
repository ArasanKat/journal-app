package database

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq" // here
)

func Connect(user, password, dbname, host, sslmode, port string) (*sql.DB, error) {
	connStr := fmt.Sprintf("user=%s password=%s dbname=%s host=%s sslmode=%s port=%s",
		user, password, dbname, host, sslmode, port)
	//open connection to our Postgres db using the connection string
	return sql.Open("postgres", connStr)
}
