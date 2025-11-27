package app

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-migrate/migrate/v4"
	"github.com/sirupsen/logrus"

	// migrate tools
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

const (
	defaultAttempts = 20
	defaultTimeout  = time.Second
)

func runMigrations(url string) error {
	if len(url) == 0 {
		return fmt.Errorf("pg URL is not declareted")
	}

	url += "?sslmode=disable"

	var (
		attempts = defaultAttempts
		err      error
		m        *migrate.Migrate
	)

	for attempts > 0 {
		m, err = migrate.New("file://migrations", url)
		if err == nil {
			break
		}

		logrus.WithField("attempts left", attempts).Info("trying to connect to db")
		time.Sleep(defaultTimeout)
		attempts--
	}

	if err != nil {
		return fmt.Errorf("db connection error: %w", err)
	}

	err = m.Up()
	defer func() { _, _ = m.Close() }()
	if err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("migration up error: %w", err)
	}

	if errors.Is(err, migrate.ErrNoChange) {
		logrus.Info("Migrate: no change")
		return nil
	}

	logrus.Info("Migrate: up success")
	return nil
}
