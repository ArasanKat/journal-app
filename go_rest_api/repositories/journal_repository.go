package repositories

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/arasankat/bobby-womack/models"
)

func CreateJournalEntry(db *sql.DB, content string, dateCreated string, score float32, magnitude float32, uid string) string {

	query := `insert into journal_entries (content, date_created, score, magnitude, uid) values 
						($1,$2,$3,$4, $5)`
	res, err := db.Exec(query, content, dateCreated, score, magnitude, uid)
	if err != nil {
		panic(err)
	}

	fmt.Println("Succesfully Added Journal Entry")
	fmt.Println(res)

	return query
}

func GetAllJournalEntries(db *sql.DB, uid string) []models.Journal {

	var journalEntry models.Journal
	query := `SELECT content, date_created, score, magnitude, uid FROM journal_entries WHERE uid=$1`
	res, err := db.Query(query, uid)

	if err != nil {
		panic(err)
	}

	var journalEntries []models.Journal
	for res.Next() {
		err := res.Scan(&journalEntry.Content, &journalEntry.DateCreated, &journalEntry.Score, &journalEntry.Magnitude, &journalEntry.UID)
		if err != nil {
			log.Fatal(err)
		}

		journalEntries = append(journalEntries, models.Journal{Content: journalEntry.Content, DateCreated: journalEntry.DateCreated, Score: journalEntry.Score, Magnitude: journalEntry.Magnitude, UID: journalEntry.UID})
	}

	fmt.Println("Succesfully Returned All Journal Entries")
	fmt.Println(journalEntries)

	return journalEntries
}

func GetAllJournalEntriesByDate(db *sql.DB, date string, uid string) []models.Journal {

	var journalEntry models.Journal
	query := `SELECT content, date_created, score, magnitude, uid FROM journal_entries WHERE uid=$1 AND DATE(date_created)=$2`
	res, err := db.Query(query, uid, date)

	if err != nil {
		panic(err)
	}

	var journalEntries []models.Journal
	for res.Next() {
		err := res.Scan(&journalEntry.Content, &journalEntry.DateCreated, &journalEntry.Score, &journalEntry.Magnitude, &journalEntry.UID)
		if err != nil {
			log.Fatal(err)
		}

		journalEntries = append(journalEntries, models.Journal{Content: journalEntry.Content, DateCreated: journalEntry.DateCreated, Score: journalEntry.Score, Magnitude: journalEntry.Magnitude, UID: journalEntry.UID})
	}

	fmt.Println("Succesfully Returned All Journal Entries From " + date)

	return journalEntries
}
