CREATE TABLE Individual (
	user_id SERIAL PRIMARY KEY ,
	first_name VARCHAR(255) NOT NULL,
	surname VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255),
    INN INT UNIQUE,
    passport_series INT NOT NULL,
    passport_nums INT NOT NULL,
    phone_num INT NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (passport_series, passport_nums)
);

CREATE TABLE MainAccount (
    account_number SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    BIC INT NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Individual(user_id)
);

CREATE TABLE Transactions (
    transaction_id SERIAL PRIMARY KEY,
    recipient_acc INT NOT NULL,
    sender_acc INT NOT NULL,
    type_id INT NOT NULL,
    date_transaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    currency VARCHAR(20) NOT NULL,
    comission_id INT,
    amount INT NOT NULL CHECK (amount > 0),
    CHECK (sender_acc != recipient_acc),
    FOREIGN KEY (recipient_acc) REFERENCES MainAccount(account_number),
    FOREIGN KEY (sender_acc) REFERENCES MainAccount(account_number),
    FOREIGN KEY (type_id) REFERENCES TransactionType(id),
    FOREIGN KEY (comission_id) REFERENCES UserPaymentFee(id)
);

CREATE TABLE UserPaymentFee (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trans_type INT NOT NULL,
    account_id INT NOT NULL,
    ratio NUMERIC CHECK (ratio >= 0),
    absolute NUMERIC CHECK (absolute >= 0),
    CHECK (ratio > 0 OR absolute > 0),
    FOREIGN KEY (trans_type) REFERENCES TransactionType(id),
    FOREIGN KEY (account_id) REFERENCES MainAccount(account_number)
);

CREATE TABLE DebutAccount (
    account_number SERIAL PRIMARY KEY,
    BIC INT NOT NULL,
    agreement_num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    card_num INT NOT NULL UNIQUE,
    card_validity INT NOT NULL,
    CVV INT NOT NULL,
    amount INT DEFAULT 0 CHECK (amount >= 0),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(account_number),
    FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
);

CREATE TYPE resident_status AS ENUM ('resident', 'non-resident');
CREATE TABLE BickerageAccount (
    account_number SERIAL PRIMARY KEY,
    BIC INT NOT NULL,
    agreement_num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    depository VARCHAR(100) NOT NULL,
    tax_resident_status resident_status NOT NULL,
    depot_account_num INT NOT NULL UNIQUE,
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(account_number)
);

CREATE TABLE LoanAccount (
    account_number SERIAL PRIMARY KEY,
    BIC INT NOT NULL,
    agreement_num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    card_num INT NOT NULL UNIQUE,
    card_validity INT NOT NULL,
    CVV INT NOT NULL,
    bet INT NOT NULL CHECK (bet >= 0),
    repayment_period INT NOT NULL CHECK (repayment_period > 0),
    limit_amount INT NOT NULL CHECK (limit_amount > 0),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(account_number),
    FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
);
