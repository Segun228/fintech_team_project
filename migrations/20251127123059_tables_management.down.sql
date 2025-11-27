-- 1. Удаление индексов
DROP INDEX IF EXISTS idx_exchange_transactions_created;
DROP INDEX IF EXISTS idx_payment_fee_type;
DROP INDEX IF EXISTS idx_payment_fee_settlement_type;
DROP INDEX IF EXISTS idx_legal_entity_name;
DROP INDEX IF EXISTS idx_legal_entity_inn;
DROP INDEX IF EXISTS idx_exchange_rate_currency_to;
DROP INDEX IF EXISTS idx_exchange_rate_currency_from;
DROP INDEX IF EXISTS idx_exchange_rate_current;
DROP INDEX IF EXISTS idx_exchange_rate_pair_date;
DROP INDEX IF EXISTS idx_foreign_account_status;
DROP INDEX IF EXISTS idx_account_status;
DROP INDEX IF EXISTS idx_credit_account_settlement_currency;
DROP INDEX IF EXISTS idx_foreign_account_settlement_currency;
DROP INDEX IF EXISTS idx_account_settlement_currency;
DROP INDEX IF EXISTS idx_credit_transactions_created;
DROP INDEX IF EXISTS idx_payment_transactions_created;
DROP INDEX IF EXISTS idx_credit_transactions_type_created;
DROP INDEX IF EXISTS idx_payment_transactions_type_created;
DROP INDEX IF EXISTS idx_exchange_transactions_account_created;
DROP INDEX IF EXISTS idx_credit_transactions_account_created;
DROP INDEX IF EXISTS idx_payment_transactions_account_created;
DROP INDEX IF EXISTS idx_user_stock_account_stock;
DROP INDEX IF EXISTS idx_stock_transactions_stock_date;
DROP INDEX IF EXISTS idx_stock_prices_price;
DROP INDEX IF EXISTS idx_stock_prices_date;
DROP INDEX IF EXISTS idx_stock_prices_stock_date;
DROP INDEX IF EXISTS idx_savings_created;
DROP INDEX IF EXISTS idx_savings_agreement;
DROP INDEX IF EXISTS idx_savings_currency;
DROP INDEX IF EXISTS idx_savings_main_account;
DROP INDEX IF EXISTS idx_currency_country;
DROP INDEX IF EXISTS idx_currency_ticker;
DROP INDEX IF EXISTS idx_stocks_registered;
DROP INDEX IF EXISTS idx_stocks_type;
DROP INDEX IF EXISTS idx_stocks_ticker;
DROP INDEX IF EXISTS idx_stocktypes_name;
DROP INDEX IF EXISTS idx_fee_account_type;
DROP INDEX IF EXISTS idx_loan_main_account;
DROP INDEX IF EXISTS idx_brokerage_main_account;
DROP INDEX IF EXISTS idx_debit_main_account;
DROP INDEX IF EXISTS idx_transactions_type_date;
DROP INDEX IF EXISTS idx_transactions_type;
DROP INDEX IF EXISTS idx_transactions_date;
DROP INDEX IF EXISTS idx_transactions_recipient_date;
DROP INDEX IF EXISTS idx_transactions_sender_date;
DROP INDEX IF EXISTS idx_individual_name;
DROP INDEX IF EXISTS idx_individual_phone;
DROP INDEX IF EXISTS idx_individual_inn;
DROP INDEX IF EXISTS idx_individual_passport;

-- 2. Удаление транзакционных таблиц
DROP TABLE IF EXISTS SettlementExchangeTransactions;
DROP TABLE IF EXISTS CreditTransactions;
DROP TABLE IF EXISTS SettlementPaymentTransactions;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS UserPaymentFee;
DROP TABLE IF EXISTS StockTransactions;
DROP TABLE IF EXISTS UserStock;

-- 3. Удаление специализированных счетов и вспомогательных таблиц
DROP TABLE IF EXISTS ExchangeRate;
DROP TABLE IF EXISTS EntityPaymentFee;
DROP TABLE IF EXISTS StockPrices;
DROP TABLE IF EXISTS Stocks;
DROP TABLE IF EXISTS StockTransactionTypes;
DROP TABLE IF EXISTS StockTypes;
DROP TABLE IF EXISTS UserCurrency;
DROP TABLE IF EXISTS SavingsAccount;
DROP TABLE IF EXISTS LoanAccount;
DROP TABLE IF EXISTS DebutAccount;
DROP TABLE IF EXISTS BrokerageAccount; 

DROP TABLE IF EXISTS CreditAccount;
DROP TABLE IF EXISTS ForeignCurrencyAccount;
DROP TABLE IF EXISTS SettlementAccount;

-- 4. Удаление основных счетов и сущностей
DROP TABLE IF EXISTS MainAccount;
DROP TABLE IF EXISTS LegalEntity;

-- 5. Удаление справочных таблиц
DROP TABLE IF EXISTS SettlementCurrency;
DROP TABLE IF EXISTS TransactionType;
DROP TABLE IF EXISTS Individual;

-- 6. Удаление ENUM типов
DROP TYPE IF EXISTS resident_status;
DROP TYPE IF EXISTS ACCOUNT_STATUS;