-- переводы человека
SELECT T.*, I.first_name, I.surname
FROM Transactions T
JOIN MainAccount MA ON T.sender_acc = MA.id OR T.recipient_acc = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE I.id = 123;


-- переводы за сегодня
SELECT T.*, I1.first_name as sender_fname, I1.surname as sender_lname,
    I2.first_name as recipient_fname, I2.surname as recipient_lname
FROM Transactions T
JOIN MainAccount MA1 ON T.sender_acc = MA1.id
JOIN Individual I1 ON MA1.user_id = I1.id
JOIN MainAccount MA2 ON T.recipient_acc = MA2.id
JOIN Individual I2 ON MA2.user_id = I2.id
WHERE DATE(T.date_transaction) = CURRENT_DATE;


-- кто больше всех переводит

SELECT I.id, I.first_name, I.surname, COUNT(*) as transfer_count, SUM(T.amount) as total_sent
FROM Transactions T
JOIN MainAccount MA ON T.sender_acc = MA.id
JOIN Individual I ON MA.user_id = I.id
GROUP BY I.id, I.first_name, I.surname
ORDER BY total_sent DESC
LIMIT 10;


-- средний разм переводов по типам
SELECT TT.name as transaction_type, 
    COUNT(*) as count,
    AVG(T.amount) as avg_amount,
    MIN(T.amount) as min_amount,
    MAX(T.amount) as max_amount
FROM Transactions T
JOIN TransactionType TT ON T.type_id = TT.id
GROUP BY TT.name
ORDER BY count DESC;