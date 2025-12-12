-- CRUD-скрипты для всех 26 таблиц (PostgreSQL)

--------------------------------------------------------------------------------
-- 1. Individual (Физическое лицо)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO Individual (first_name, surname, patronymic, INN, passport_series, passport_nums, phone_num, password)
VALUES ('[Имя]', '[Фамилия]', '[Отчество]', '[ИНН]', [Серия_Паспорта], [Номер_Паспорта], '[Номер_Телефона]', '[Пароль]');

-- READ (R)
SELECT id, first_name, surname, patronymic, INN, passport_series, passport_nums, phone_num, created_at
FROM Individual
WHERE id = [id];

-- UPDATE (U)
UPDATE Individual
SET first_name = '[новое_Имя]', surname = '[новая_Фамилия]', patronymic = '[новое_Отчество]',
    INN = '[новый_ИНН]', passport_series = [новая_Серия], passport_nums = [новый_Номер],
    phone_num = '[новый_Номер_Телефона]', password = '[новый_Пароль]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM Individual WHERE id = [id];


--------------------------------------------------------------------------------
-- 2. TransactionType (Тип транзакции)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO TransactionType (name)
VALUES ('[Название_Типа]');

-- READ (R)
SELECT * FROM TransactionType WHERE id = [id];

-- UPDATE (U)
UPDATE TransactionType
SET name = '[новое_Название_Типа]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM TransactionType WHERE id = [id];


--------------------------------------------------------------------------------
-- 3. SettlementCurrency (Валюта расчетов)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO SettlementCurrency (ticker, country)
VALUES ('[Тикер]', '[Страна]');

-- READ (R)
SELECT * FROM SettlementCurrency WHERE id = [id];

-- UPDATE (U)
UPDATE SettlementCurrency
SET ticker = '[новый_Тикер]', country = '[новая_Страна]', updated_at = CURRENT_TIMESTAMP
WHERE id = [id];

-- DELETE (D)
DELETE FROM SettlementCurrency WHERE id = [id];


--------------------------------------------------------------------------------
-- 4. StockTypes (Типы акций)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO StockTypes (type_name)
VALUES ('[Название_Типа_Акции]');

-- READ (R)
SELECT * FROM StockTypes WHERE id = [id];

-- UPDATE (U)
UPDATE StockTypes
SET type_name = '[новое_Название_Типа_Акции]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM StockTypes WHERE id = [id];


--------------------------------------------------------------------------------
-- 5. LegalEntity (Юридическое лицо)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO LegalEntity (name, INN, owner_id)
VALUES ('[Название_Юрлица]', '[ИНН]', [id_владельца_Individual]);

-- READ (R)
SELECT * FROM LegalEntity WHERE id = [id];

-- UPDATE (U)
UPDATE LegalEntity
SET name = '[новое_Название]', INN = '[новый_ИНН]', owner_id = [новый_id_владельца]
WHERE id = [id];

-- DELETE (D)
DELETE FROM LegalEntity WHERE id = [id];


--------------------------------------------------------------------------------
-- 6. MainAccount (Основной счет Физ. лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO MainAccount (user_id, BIC, agreement_num)
VALUES ([id_пользователя], '[БИК]', [Номер_Договора]);

-- READ (R)
SELECT * FROM MainAccount WHERE id = [id];

-- UPDATE (U)
UPDATE MainAccount
SET user_id = [новый_id_пользователя], BIC = '[новый_БИК]', agreement_num = [новый_Номер_Договора]
WHERE id = [id];

-- DELETE (D)
DELETE FROM MainAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 7. Stocks (Акции)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO Stocks (stock_type, ticker)
VALUES ([id_типа_акции], '[Тикер_Акции]');

-- READ (R)
SELECT * FROM Stocks WHERE id = [id];

-- UPDATE (U)
UPDATE Stocks
SET stock_type = [новый_id_типа_акции], ticker = '[новый_Тикер_Акции]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM Stocks WHERE id = [id];


--------------------------------------------------------------------------------
-- 8. StockPrices (Цены акций)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO StockPrices (stock_id, price)
VALUES ([id_акции], [Цена]);

-- READ (R)
SELECT * FROM StockPrices WHERE id = [id];

-- UPDATE (U)
UPDATE StockPrices
SET stock_id = [новый_id_акции], price = [новая_Цена], updated_at = CURRENT_TIMESTAMP
WHERE id = [id];

-- DELETE (D)
DELETE FROM StockPrices WHERE id = [id];


--------------------------------------------------------------------------------
-- 9. StockTransactionTypes (Типы операций с акциями)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO StockTransactionTypes (operation_name)
VALUES ('[Название_Операции]');

-- READ (R)
SELECT * FROM StockTransactionTypes WHERE id = [id];

-- UPDATE (U)
UPDATE StockTransactionTypes
SET operation_name = '[новое_Название_Операции]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM StockTransactionTypes WHERE id = [id];


--------------------------------------------------------------------------------
-- 10. UserCurrency (Валюта пользователя)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO UserCurrency (ticker, country)
VALUES ('[Тикер]', '[Страна]');

-- READ (R)
SELECT * FROM UserCurrency WHERE id = [id];

-- UPDATE (U)
UPDATE UserCurrency
SET ticker = '[новый_Тикер]', country = '[новая_Страна]', updated_at = CURRENT_TIMESTAMP
WHERE id = [id];

-- DELETE (D)
DELETE FROM UserCurrency WHERE id = [id];


--------------------------------------------------------------------------------
-- 11. EntityPaymentFee (Комиссия Юридического лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO EntityPaymentFee (settlement_id, ratio, absolute, type_id)
VALUES ([id_юрлица], [Коэффициент], [Абсолютная_Сумма], [id_типа_транзакции]);

-- READ (R)
SELECT * FROM EntityPaymentFee WHERE id = [id];

-- UPDATE (U)
UPDATE EntityPaymentFee
SET settlement_id = [новый_id_юрлица], ratio = [новый_Коэффициент],
    absolute = [новая_Абсолютная_Сумма], type_id = [новый_id_типа_транзакции]
WHERE id = [id];

-- DELETE (D)
DELETE FROM EntityPaymentFee WHERE id = [id];


--------------------------------------------------------------------------------
-- 12. DebutAccount (Дебетовый счет)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO DebutAccount (BIC, agreement_num, main_account_num, currency_id, card_num, card_validity, CVV, amount)
VALUES ('[БИК]', [Номер_Договора], [id_основного_счета], [id_валюты], '[Номер_Карты]', [Срок_Действия], [CVV], [Сумма]);

-- READ (R)
SELECT * FROM DebutAccount WHERE id = [id];

-- UPDATE (U)
UPDATE DebutAccount
SET BIC = '[новый_БИК]', agreement_num = [новый_Номер_Договора], main_account_num = [новый_id_основного_счета],
    currency_id = [новый_id_валюты], card_num = '[новый_Номер_Карты]', card_validity = [новый_Срок_Действия],
    CVV = [новый_CVV], amount = [новая_Сумма]
WHERE id = [id];

-- DELETE (D)
DELETE FROM DebutAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 13. BrokerageAccount (Брокерский счет)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO BrokerageAccount (BIC, agreement_num, main_account_num, depository, tax_resident_status, depot_account_num)
VALUES ('[БИК]', [Номер_Договора], [id_основного_счета], '[Депозитарий]', '[resident/non-resident]', [Номер_Депо_Счета]);

-- READ (R)
SELECT * FROM BrokerageAccount WHERE id = [id];

-- UPDATE (U)
UPDATE BrokerageAccount
SET BIC = '[новый_БИК]', agreement_num = [новый_Номер_Договора], main_account_num = [новый_id_основного_счета],
    depository = '[новый_Депозитарий]', tax_resident_status = '[новый_Статус]', depot_account_num = [новый_Номер_Депо_Счета]
WHERE id = [id];

-- DELETE (D)
DELETE FROM BrokerageAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 14. LoanAccount (Кредитный счет)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO LoanAccount (BIC, agreement_num, main_account_num, currency_id, card_num, card_validity, CVV, bet, repayment_period, limit_amount)
VALUES ('[БИК]', [Номер_Договора], [id_основного_счета], [id_валюты], '[Номер_Карты]', [Срок_Действия], [CVV], [Ставка], [Срок_Погашения], [Лимит]);

-- READ (R)
SELECT * FROM LoanAccount WHERE id = [id];

-- UPDATE (U)
UPDATE LoanAccount
SET BIC = '[новый_БИК]', agreement_num = [новый_Номер_Договора], main_account_num = [новый_id_основного_счета],
    currency_id = [новый_id_валюты], card_num = '[новый_Номер_Карты]', card_validity = [новый_Срок_Действия],
    CVV = [новый_CVV], bet = [новая_Ставка], repayment_period = [новый_Срок_Погашения], limit_amount = [новый_Лимит]
WHERE id = [id];

-- DELETE (D)
DELETE FROM LoanAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 15. SavingsAccount (Сберегательный счет)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO SavingsAccount (bic, agreement_num, main_account_num, currency_id, bet, amount)
VALUES ('[БИК]', [Номер_Договора], [id_основного_счета], [id_валюты], [Ставка], [Сумма]);

-- READ (R)
SELECT * FROM SavingsAccount WHERE id = [id];

-- UPDATE (U)
UPDATE SavingsAccount
SET bic = '[новый_БИК]', agreement_num = [новый_Номер_Договора], main_account_num = [новый_id_основного_счета],
    currency_id = [новый_id_валюты], bet = [новая_Ставка], amount = [новая_Сумма]
WHERE id = [id];

-- DELETE (D)
DELETE FROM SavingsAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 16. SettlementAccount (Расчетный счет Юр. лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO SettlementAccount (settlement_id, currency_id, balance, status)
VALUES ([id_юрлица], [id_валюты], [Баланс], '[active/frozen/closed]');

-- READ (R)
SELECT * FROM SettlementAccount WHERE id = [id];

-- UPDATE (U)
UPDATE SettlementAccount
SET settlement_id = [новый_id_юрлица], currency_id = [новый_id_валюты],
    balance = [новый_Баланс], status = '[новый_Статус]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM SettlementAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 17. ForeignCurrencyAccount (Валютный счет Юр. лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO ForeignCurrencyAccount (settlement_id, currency_id, balance, status)
VALUES ([id_юрлица], [id_валюты], [Баланс], '[active/frozen/closed]');

-- READ (R)
SELECT * FROM ForeignCurrencyAccount WHERE id = [id];

-- UPDATE (U)
UPDATE ForeignCurrencyAccount
SET settlement_id = [новый_id_юрлица], currency_id = [новый_id_валюты],
    balance = [новый_Баланс], status = '[новый_Статус]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM ForeignCurrencyAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 18. CreditAccount (Кредитный счет Юр. лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO CreditAccount (settlement_id, currency_id, balance, status)
VALUES ([id_юрлица], [id_валюты], [Баланс], '[active/frozen/closed]');

-- READ (R)
SELECT * FROM CreditAccount WHERE id = [id];

-- UPDATE (U)
UPDATE CreditAccount
SET settlement_id = [новый_id_юрлица], currency_id = [новый_id_валюты],
    balance = [новый_Баланс], status = '[новый_Статус]'
WHERE id = [id];

-- DELETE (D)
DELETE FROM CreditAccount WHERE id = [id];


--------------------------------------------------------------------------------
-- 19. UserPaymentFee (Комиссия Физ. лица)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO UserPaymentFee (trans_type, account_id, ratio, absolute)
VALUES ([id_типа_транзакции], [id_основного_счета], [Коэффициент], [Абсолютная_Сумма]);

-- READ (R)
SELECT * FROM UserPaymentFee WHERE id = [id];

-- UPDATE (U)
UPDATE UserPaymentFee
SET trans_type = [новый_id_типа_транзакции], account_id = [новый_id_основного_счета],
    ratio = [новый_Коэффициент], absolute = [новая_Абсолютная_Сумма]
WHERE id = [id];

-- DELETE (D)
DELETE FROM UserPaymentFee WHERE id = [id];


--------------------------------------------------------------------------------
-- 20. Transactions (Транзакции Физ. лиц)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO Transactions (recipient_acc, sender_acc, type_id, currency, comission_id, amount)
VALUES ([id_получателя], [id_отправителя], [id_типа], '[Валюта]', [id_комиссии], [Сумма]);

-- READ (R)
SELECT * FROM Transactions WHERE id = [id];

-- UPDATE (U)
UPDATE Transactions
SET recipient_acc = [новый_id_получателя], sender_acc = [новый_id_отправителя],
    type_id = [новый_id_типа], currency = '[новая_Валюта]', comission_id = [новый_id_комиссии],
    amount = [новая_Сумма]
WHERE id = [id];

-- DELETE (D)
DELETE FROM Transactions WHERE id = [id];


--------------------------------------------------------------------------------
-- 21. SettlementPaymentTransactions (Платежные транзакции Юр. лиц)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO SettlementPaymentTransactions (fee_id, account_id, primary_amount, type_id)
VALUES ([id_комиссии_юрлица], [id_расчетного_счета], [Сумма], [id_типа_транзакции]);

-- READ (R)
SELECT * FROM SettlementPaymentTransactions WHERE id = [id];

-- UPDATE (U)
UPDATE SettlementPaymentTransactions
SET fee_id = [новый_id_комиссии_юрлица], account_id = [новый_id_расчетного_счета],
    primary_amount = [новая_Сумма], type_id = [новый_id_типа_транзакции]
WHERE id = [id];

-- DELETE (D)
DELETE FROM SettlementPaymentTransactions WHERE id = [id];


--------------------------------------------------------------------------------
-- 22. CreditTransactions (Кредитные транзакции Юр. лиц)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO CreditTransactions (fee_id, account_id, primary_amount, type_id)
VALUES ([id_комиссии_юрлица], [id_кредитного_счета], [Сумма], [id_типа_транзакции]);

-- READ (R)
SELECT * FROM CreditTransactions WHERE id = [id];

-- UPDATE (U)
UPDATE CreditTransactions
SET fee_id = [новый_id_комиссии_юрлица], account_id = [новый_id_кредитного_счета],
    primary_amount = [новая_Сумма], type_id = [новый_id_типа_транзакции]
WHERE id = [id];

-- DELETE (D)
DELETE FROM CreditTransactions WHERE id = [id];


--------------------------------------------------------------------------------
-- 23. ExchangeRate (Курс обмена валют)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO ExchangeRate (settlement_id, ratio, currency_from, currency_to, is_current)
VALUES ([id_юрлица], [Коэффициент], [id_валюты_от], [id_валюты_к], [TRUE/FALSE]);

-- READ (R)
SELECT * FROM ExchangeRate WHERE id = [id];

-- UPDATE (U)
UPDATE ExchangeRate
SET settlement_id = [новый_id_юрлица], ratio = [новый_Коэффициент],
    currency_from = [новый_id_валюты_от], currency_to = [новый_id_валюты_к],
    is_current = [новое_TRUE/FALSE], updated_at = CURRENT_TIMESTAMP
WHERE id = [id];

-- DELETE (D)
DELETE FROM ExchangeRate WHERE id = [id];


--------------------------------------------------------------------------------
-- 24. SettlementExchangeTransactions (Обменные транзакции Юр. лиц)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO SettlementExchangeTransactions (fee_id, rate_id, account_id, primary_amount, type_id)
VALUES ([id_комиссии_юрлица], [id_курса], [id_валютного_счета], [Сумма], [id_типа_транзакции]);

-- READ (R)
SELECT * FROM SettlementExchangeTransactions WHERE id = [id];

-- UPDATE (U)
UPDATE SettlementExchangeTransactions
SET fee_id = [новый_id_комиссии_юрлица], rate_id = [новый_id_курса], account_id = [новый_id_валютного_счета],
    primary_amount = [новая_Сумма], type_id = [новый_id_типа_транзакции]
WHERE id = [id];

-- DELETE (D)
DELETE FROM SettlementExchangeTransactions WHERE id = [id];


--------------------------------------------------------------------------------
-- 25. StockTransactions (Транзакции с акциями)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO StockTransactions (stock_id, account_id, operation_type_id, value, stock_price_id)
VALUES ([id_акции], [id_сберегательного_счета], [id_типа_операции], [Объем], [id_цены_акции]);

-- READ (R)
SELECT * FROM StockTransactions WHERE id = [id];

-- UPDATE (U)
UPDATE StockTransactions
SET stock_id = [новый_id_акции], account_id = [новый_id_сберегательного_счета],
    operation_type_id = [новый_id_типа_операции], value = [новый_Объем], stock_price_id = [новый_id_цены_акции]
WHERE id = [id];

-- DELETE (D)
DELETE FROM StockTransactions WHERE id = [id];


--------------------------------------------------------------------------------
-- 26. UserStock (Владение акциями)
--------------------------------------------------------------------------------

-- CREATE (C)
INSERT INTO UserStock (transact_id, brock_acc_num)
VALUES ([id_транзакции_акции], [id_брокерского_счета]);

-- READ (R)
SELECT * FROM UserStock WHERE id = [id];

-- UPDATE (U)
UPDATE UserStock
SET transact_id = [новый_id_транзакции_акции], brock_acc_num = [новый_id_брокерского_счета]
WHERE id = [id];

-- DELETE (D)
DELETE FROM UserStock WHERE id = [id];