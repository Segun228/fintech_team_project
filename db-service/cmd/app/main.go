package main

import (
	"github.com/Segun228/fintech_team_project/db-service/internal/app"
)

const configPath = "./configs/config.yml"

func main() {
	app.Run(configPath)
}
