package models

type Journal struct {
	Content     string  `json:"content"`
	DateCreated string  `json:"date_created"`
	Score       float32 `json:"score"`
	Magnitude   float32 `json:"magnitude"`
	UID         string  `json:"uid"`
}
