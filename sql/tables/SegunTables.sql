CREATE TABLE IF NOT EXISTS TransactionType (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name VARCHAR(200) NOT NULL 
);

CREATE TABLE IF NOT EXISTS SettlementPaymentTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES SettlementAccount(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);

CREATE TYPE ACCOUNT_STATUS AS ENUM ('active', 'frozen', 'closed');

CREATE TABLE IF NOT EXISTS SettlementAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE
        ON UPDATE SET NULL,
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS ForeignCurrencyAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE
        ON UPDATE SET NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active',
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);

CREATE TABLE IF NOT EXISTS LegalEntity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500) NOT NULL UNIQUE,
    INN VARCHAR(12) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    owner_id INT NOT NULL,    
    CONSTRAINT fk_owner_id
        FOREIGN KEY (owner_id) REFERENCES Individual(id)
        ON DELETE CASCADE
        ON UPDATE SET NULL
);

CREATE TABLE IF NOT EXISTS CreditAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE
        ON UPDATE SET NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active',
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);


CREATE TABLE IF NOT EXISTS CreditTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES CreditAccount(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);

CREATE TABLE IF NOT EXISTS EntityPaymentFee (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    ratio DECIMAL(15, 5) NOT NULL DEFAULT 0,
    absolute DECIMAL(15,2) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE CASCADE
        ON UPDATE SET NULL,
);

CREATE TABLE IF NOT EXISTS ExchangeRate (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    settlement_id INT NOT NULL,    
    ratio DECIMAL(15, 5) NOT NULL DEFAULT 0,
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    currency_from INT NOT NULL,    
    CONSTRAINT money_pairs 
        CHECK (currency_from != currency_to),
    CONSTRAINT fk_currency_from
        FOREIGN KEY (currency_from) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    is_current BOOLEAN DEFAULT FALSE,
    currency_to INT NOT NULL,    
    CONSTRAINT fk_currency_to
        FOREIGN KEY (currency_to) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);

CREATE TABLE IF NOT EXISTS SettlementExchangeTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    rate_id INT NOT NULL,    
    CONSTRAINT fk_rate_id 
        FOREIGN KEY (rate_id) REFERENCES ExchangeRate(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES ForeignCurrencyAccount(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
);

CREATE TABLE IF NOT EXISTS SettlementCurrency (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ticker VARCHAR(50) NOT NULL,
    country VARCHAR(200) NOT NULL
);


CREATE INDEX CONCURRENTLY idx_payment_transactions_account_created 
ON SettlementPaymentTransactions(account_id, created_at DESC);

CREATE INDEX CONCURRENTLY idx_credit_transactions_account_created 
ON CreditTransactions(account_id, created_at DESC);

CREATE INDEX CONCURRENTLY idx_exchange_transactions_account_created 
ON SettlementExchangeTransactions(account_id, created_at DESC);


CREATE INDEX CONCURRENTLY idx_payment_transactions_type_created 
ON SettlementPaymentTransactions(type_id, created_at);

CREATE INDEX CONCURRENTLY idx_credit_transactions_type_created 
ON CreditTransactions(type_id, created_at);


CREATE INDEX CONCURRENTLY idx_payment_transactions_created 
ON SettlementPaymentTransactions(created_at);

CREATE INDEX CONCURRENTLY idx_credit_transactions_created 
ON CreditTransactions(created_at);



CREATE INDEX CONCURRENTLY idx_account_settlement_currency 
ON SettlementAccount(settlement_id, currency_id);

CREATE INDEX CONCURRENTLY idx_foreign_account_settlement_currency 
ON ForeignCurrencyAccount(settlement_id, currency_id);

CREATE INDEX CONCURRENTLY idx_credit_account_settlement_currency 
ON CreditAccount(settlement_id, currency_id);


CREATE INDEX CONCURRENTLY idx_account_status 
ON SettlementAccount(status) 
WHERE status != 'active';

CREATE INDEX CONCURRENTLY idx_foreign_account_status 
ON ForeignCurrencyAccount(status) 
WHERE status != 'active';



CREATE INDEX CONCURRENTLY idx_exchange_rate_pair_date 
ON ExchangeRate(currency_from, currency_to, created_at DESC);


CREATE UNIQUE INDEX CONCURRENTLY idx_exchange_rate_current 
ON ExchangeRate(currency_from, currency_to) 
WHERE is_current = TRUE;


CREATE INDEX CONCURRENTLY idx_exchange_rate_currency_from 
ON ExchangeRate(currency_from, created_at DESC);

CREATE INDEX CONCURRENTLY idx_exchange_rate_currency_to 
ON ExchangeRate(currency_to, created_at DESC);


CREATE INDEX CONCURRENTLY idx_legal_entity_inn 
ON LegalEntity(INN);

CREATE INDEX CONCURRENTLY idx_legal_entity_name 
ON LegalEntity(name);


CREATE INDEX CONCURRENTLY idx_payment_fee_settlement_type 
ON EntityPaymentFee(settlement_id, type_id);


CREATE INDEX CONCURRENTLY idx_payment_fee_type 
ON EntityPaymentFee(type_id);


CREATE INDEX CONCURRENTLY idx_exchange_transactions_created 
ON SettlementExchangeTransactions(created_at);