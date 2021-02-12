package authenticate

import (
	"context"
	"log"

	firebase "firebase.google.com/go"
)

type Authenticate struct {
	FIREBASESDK *firebase.App
}

func InitAuthentication() *Authenticate {

	app, err := firebase.NewApp(context.Background(), nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	return &Authenticate{
		FIREBASESDK: app,
	}
}

func VerifyToken(ctx context.Context, app *firebase.App, idToken string) (bool, string) {

	//print(idToken)

	client, err := app.Auth(context.Background())
	if err != nil {
		//log.Fatalf("error getting Auth client: %v\n", err)
		log.Printf("error getting Auth client: %v\n", err)
		return false, "CLIENT NOT AUTH"
	}

	token, err := client.VerifyIDToken(ctx, idToken)
	if err != nil {
		//log.Fatalf("error verifying ID token: %v\n", err)
		log.Printf("error verifying ID token: %v\n", err)
		return false, "USER NOT AUTH"
	}

	log.Printf("Verified ID token: %v\n", token)

	return true, token.UID

}
