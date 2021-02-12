package models

type ScoreChart struct {
	DateCreated string  `json:"date_created"`
	Score       float32 `json:"score"`
	Magnitude   float32 `json:"magnitude"`
}
