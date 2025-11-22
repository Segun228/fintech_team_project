package app

import (
	"github.com/Segun228/fintech_team_project/db-service/internal/config"
	"github.com/Segun228/fintech_team_project/db-service/pkg/postgres"
	"github.com/sirupsen/logrus"
)

func Run(configPath string) {
	cfg, err := config.NewConfig(configPath)
	if err != nil {
		logrus.WithField("error", err).Fatal("unable to load config")
	}

	logrus.Info("initiating postgres...")
	pg, err := postgres.New(cfg.Postgres.Url)
	if err != nil {
		logrus.WithField("error", err).Fatal("failed to provide new postgres connection")
	}
	defer pg.Close()

	if err := runMigrations(cfg.Postgres.Url); err != nil {
		logrus.WithField("error", err).Fatal("failed to run migrations")
	}
}
