CREATE OR REPLACE FUNCTION savings_account_transaction()
RETURN TRIGGER AS $$
DECLARE savings_sender_id INT;
		savings_recipient_id INT;
BEGIN
	SELECT sa.account_number INTO savings_sender_id
	FROM SavingsAccount sa
	WHERE ma.main_account_num = (
		SELECT id FROM MainAccount WHERE NEW.sender_acc = id
	);

	SELECT sa.account_number INTO savings_recipient_id
	FROM SavingsAccount sa
	WHERE ma.main_account_num = (
		SELECT id FROM MainAccount WHERE NEW.recipient_acc = id
	);

	IF savings_sender_id IS NOT NULL THEN
		IF (SELECT amount FROM SavingsAccount WHERE account_number=savings_sender_id)<NEW.amount THEN
			RAISE EXCEPTION 'Недостаточно средств на сберегательном счете (ID: %)', savings_sender_id;
		END IF;

		UPDATE SavingsAccount
		SET amount = amount-NEW.amount
		WHERE account_number = savings_sender_id;
	END IF;

	IF savings_recipient_id IS NOT NULL THEN
        UPDATE SavingsAccount 
        SET amount = amount + NEW.amount
        WHERE account_number = savings_recipient_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_savings_transactions
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION savings_account_transaction();

CREATE OR REPLACE FUNCTION debit_account_transaction()
RETURNS TRIGGER AS $$
DECLARE 
    debit_sender_id INT;
    debit_recipient_id INT;
    sender_balance INT;
BEGIN
    SELECT da.id, da.amount INTO debit_sender_id, sender_balance
    FROM DebutAccount da
    WHERE da.main_account_num = NEW.sender_acc;

    SELECT da.id INTO debit_recipient_id
    FROM DebutAccount da
    WHERE da.main_account_num = NEW.recipient_acc;

    IF debit_sender_id IS NOT NULL THEN
        IF sender_balance < NEW.amount THEN
            RAISE EXCEPTION 'Недостаточно средств на дебетовом счете (ID: %). Баланс: %', 
                           debit_sender_id, sender_balance;
        END IF;
        
        UPDATE DebutAccount
        SET amount = amount - NEW.amount
        WHERE id = debit_sender_id;
    END IF;

    IF debit_recipient_id IS NOT NULL THEN
        UPDATE DebutAccount 
        SET amount = amount + NEW.amount
        WHERE id = debit_recipient_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_debit_transactions
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION debit_account_transaction();

CREATE OR REPLACE FUNCTION suspicious_activity() 
RETURNS TRIGGER AS $$
DECLARE 
    transactions_count INTEGER;
    individual_id INTEGER;
BEGIN 
    SELECT ma.user_id INTO individual_id
    FROM MainAccount ma
    WHERE ma.id = NEW.sender_acc;
    
    IF individual_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    SELECT COUNT(*) INTO transactions_count
    FROM Transactions t
    JOIN MainAccount ma ON t.sender_acc = ma.id
    WHERE ma.user_id = individual_id
      AND t.date_transaction >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
      AND t.date_transaction <= CURRENT_TIMESTAMP;
    
    IF transactions_count > 20 THEN
        RAISE EXCEPTION 'Замечена подозрительная активность. Пользователь % совершил % транзакций за 24 часа', 
                       individual_id, transactions_count;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_suspicious_activity
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION suspicious_activity();

CREATE OR REPLACE FUNCTION get_cashback()
RETURN TRIGGER$$
DECLARE client_id INT;
    monthly_spent DECIMAL;
    cashback_amount DECIMAL;
    cashback_percent DECIMAL;
BEGIN
    SELECT ma.user_id INTO client_id
    FROM MainAccount ma
    WHERE ma.id = NEW.sender_acc;
    
    IF client_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    SELECT COALESCE(SUM(t.amount), 0) INTO monthly_spent
    FROM Transactions t
    JOIN DebutAccount da ON t.sender_acc = da.main_account_num
    JOIN MainAccount ma ON da.main_account_num = ma.id
    WHERE ma.user_id = client_id
      AND EXTRACT(MONTH FROM t.date_transaction) = EXTRACT(MONTH FROM CURRENT_TIMESTAMP)
      AND EXTRACT(YEAR FROM t.date_transaction) = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
      AND t.type_id = 2;  -- пусть type_id=2 это покупки
    
    cashback_percent := CASE
        WHEN monthly_spent >= 100000 THEN 0.15
        WHEN monthly_spent >= 50000 THEN 0.10
        WHEN monthly_spent >= 30000 THEN 0.05
        ELSE 0.0                                
    END;
    
    cashback_amount := NEW.amount * cashback_percent;
    
    IF cashback_amount > 0 THEN
        UPDATE DebutAccount 
        SET amount = amount + cashback_amount
        WHERE id = (
            SELECT da.id 
            FROM DebutAccount da
            JOIN MainAccount ma ON da.main_account_num = ma.id
            WHERE ma.user_id = client_id
            ORDER BY da.created_at DESC
            LIMIT 1
        );
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cashback
AFTER INSERT ON Transactions
FOR EACH ROW
WHERE (NEW.type_id = 2)
EXECUTE FUNCTION get_cashback();
		
