package config

import (
	"fmt"
	"strings"

	"github.com/spf13/viper"
)

type (
	Config struct {
		Postgres PGConfig `mapstructure:"postgres"`
	}

	PGConfig struct {
		Url            string `mapstructure:"url"`
		MigrationsPath string `mapstructure:"migrations_path"`
	}
)

func NewConfig(path string) (*Config, error) {
	viper.SetConfigFile(path)

	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var cfg Config

	if err := viper.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("failed to unmarshal config: %w", err)
	}

	return &cfg, nil
}
