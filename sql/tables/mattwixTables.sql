CREATE TABLE StockTypes (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL
);

CREATE TABLE Stocks (
    id SERIAL PRIMARY KEY,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_type INT NOT NULL,
    ticker VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (stock_type) REFERENCES StockTypes(id)
);

CREATE TABLE SettlementCurrency (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE SavingsAccount (
    account_number SERIAL PRIMARY KEY,
    bic VARCHAR(11) UNIQUE NOT NULL,
    agreement_num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    bet INT,
    amount INT,
    FOREIGN KEY (currency_id) REFERENCES Currency(id),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(account_number)
);

CREATE TABLE UserStock (
    id SERIAL PRIMARY KEY,
    transact_id INT NOT NULL,
    brock_acc_num INT NOT NULL,
    FOREIGN KEY (transact_id) REFERENCES StockTransactions(id),
    FOREIGN KEY (brock_acc_num) REFERENCES BrokerageAccount(account_number)
);

CREATE TABLE StockPrices (
    id SERIAL PRIMARY KEY,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    price NUMERIC(20, 4) NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES Stocks(id)
);

CREATE TABLE StockTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    operation_type_id INT NOT NULL,
    value NUMERIC(20, 4) NOT NULL,
    stock_price_id INT,
    FOREIGN KEY (stock_id) REFERENCES Stocks(id),
    FOREIGN KEY (account_id) REFERENCES SavingsAccount(id),
    FOREIGN KEY (operation_type_id) REFERENCES StockTransactionTypes(id),
    FOREIGN KEY (stock_price_id) REFERENCES StockPrices(id)
);

CREATE TABLE StockTransactionTypes (
    id SERIAL PRIMARY KEY,
    operation_name VARCHAR(255) NOT NULL
);