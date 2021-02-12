package controllers

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	language "cloud.google.com/go/language/apiv1"
	"github.com/arasankat/bobby-womack/models"
	"github.com/arasankat/bobby-womack/repositories"
	languagepb "google.golang.org/genproto/googleapis/cloud/language/v1"
)

type JournalController struct {
	DB *sql.DB
}

var ctx = context.Background()
var client, ctxErr = language.NewClient(ctx)

func NewJournalController(db *sql.DB) *JournalController {
	return &JournalController{
		DB: db,
	}
}

func (jc *JournalController) CreateJournalEntry(w http.ResponseWriter, req *http.Request) {

	//incoming http request's body must be read
	decoder := json.NewDecoder(req.Body)

	var journalEntry models.Journal

	//Once the values of the request body is read it must be decoded and stored in the journalEntry variable
	//If unsuccesful the error will be assigned to err
	err := decoder.Decode(&journalEntry)
	if err != nil {
		panic(err)
	}

	//score, magnitude := analyze(journalEntry.Content)
	score, magnitude := analyzeSentiment(context.Background(), client, journalEntry.Content)

	UID := req.Context().Value("UID").(string)

	journalEntry.Score = score
	journalEntry.Magnitude = magnitude

	//Pass the request body values down to the Repo layer
	repositories.CreateJournalEntry(jc.DB, journalEntry.Content, journalEntry.DateCreated, journalEntry.Score, journalEntry.Magnitude, UID)

	journalEntryJson, err := json.Marshal(journalEntry)
	if err != nil {
		panic(err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(journalEntryJson)

}

func (jc *JournalController) GetAllJournalEntries(w http.ResponseWriter, req *http.Request) {

	UID := req.Context().Value("UID").(string)

	//Pass the request body values down to the Repo layer
	journalEntries := repositories.GetAllJournalEntries(jc.DB, UID)

	journalEntriesJSON, err := json.Marshal(journalEntries)
	if err != nil {
		panic(err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(journalEntriesJSON)
}

func (jc *JournalController) GetAllJournalEntriesByDate(w http.ResponseWriter, req *http.Request) {

	//get query param from url
	date := req.URL.Query()["date"]

	UID := req.Context().Value("UID").(string)

	//Pass the request body values down to the Repo layer
	journalEntries := repositories.GetAllJournalEntriesByDate(jc.DB, date[0], UID)

	journalEntriesJSON, err := json.Marshal(journalEntries)
	if err != nil {
		panic(err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(journalEntriesJSON)
}

func analyzeSentiment(ctx context.Context, client *language.Client, content string) (float32, float32) {
	res, err := client.AnalyzeSentiment(ctx, &languagepb.AnalyzeSentimentRequest{
		Document: &languagepb.Document{
			Source: &languagepb.Document_Content{
				Content: content,
			},
			Type: languagepb.Document_PLAIN_TEXT,
		},
	})

	if err != nil {
		log.Fatal(err)
	}

	score := res.GetDocumentSentiment().Score
	magnitude := res.GetDocumentSentiment().Magnitude

	return score, magnitude
}
