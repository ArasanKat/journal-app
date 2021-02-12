package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/arasankat/bobby-womack/authenticate"
	"github.com/arasankat/bobby-womack/controllers"
	"github.com/arasankat/bobby-womack/database"

	"github.com/gorilla/mux"
)

//We can pass values through the context from main with these keys
type key string

const uid string = "UID"

//init Firebase SDK
var firebaseApp = authenticate.InitAuthentication().FIREBASESDK

func main() {

	//Pass Postgres config values to the connect method in the database package
	db, err := database.Connect(os.Getenv("POSTGRES_USER"), os.Getenv("POSTGRES_PW"), "journal", "localhost", "disable", os.Getenv("POSTGRES_PORT"))
	if err != nil {
		log.Fatal(err)
	}

	//Add various controllers here and pass in a valid db connection string for them to interact with
	journalController := controllers.NewJournalController(db)

	//Create new router multiplexer to handle incoming requests
	router := mux.NewRouter()

	//Define routes and which controller methods should handle the route
	router.HandleFunc("/newJournalEntry", journalController.CreateJournalEntry).Methods("POST")
	router.HandleFunc("/journalEntries", journalController.GetAllJournalEntries).Methods("GET")
	router.HandleFunc("/journalEntriesByDate", journalController.GetAllJournalEntriesByDate).Methods("GET")
	//This acts as a middleware interceptor to catch all requests and check to see if the
	//user making the request has a valid token
	router.Use(isAuthenticated)

	//Specify port that server should listen and serve on
	http.ListenAndServe(":4000", router)
}

func isAuthenticated(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		isAuthenticated, UID := authenticate.VerifyToken(req.Context(), firebaseApp, req.Header.Get("ApiToken"))
		if isAuthenticated == true {
			ctx := context.WithValue(context.Background(), uid, UID)
			next.ServeHTTP(w, req.WithContext(ctx))
		} else {

			w.WriteHeader(http.StatusUnauthorized)

		}
	})
}
