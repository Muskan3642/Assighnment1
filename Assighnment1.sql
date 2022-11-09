
-- table creation--
create table bank1(Account_No int primary key auto_increment, Acc_Name varchar(30) not null, Balance numeric(10,2));

-- bank_update1 table creation --
create table bank_udpate (Account_No int not null ,
Acc_Name varchar(30) not null,
changed_id timestamp,
before_Bal numeric(10,2) not null,
after_Bal numeric(10,2) not null,
Actions varchar(10) null,
Transaction_amt int null);

-- trigger for after_bank_update(debit) update on bank_account --
delimiter $$
create trigger after_bank_update after update on bank_account for each row
begin
if(new.Balance<old.Balance) then
	insert into bank_udpate(Account_No , Acc_Name , changed_id , before_Bal , after_Bal, Actions, Transaction_amt ) 
	values(old.Account_No, old.Acc_Name, now(), old.Balance , new.Balance, 'Debit',-(old.Balance-new.Balance));
end IF;
end $$

-- trigger for after_bank_update2 (credit) update on bank1 --
delimiter $$
create trigger after_bank_update1 after update on bank_account for each row
begin
if(new.Balance>old.Balance) then
	insert into bank_udpate(Account_No , Acc_Name , changed_id , before_Bal , after_Bal, Actions ,Transaction_amt) 
	values(old.Account_No, old.Acc_Name, now(), old.Balance , new.Balance, 'Credit',+(new.Balance-old.Balance));
end IF;
end $$

-- update statemnt bank1 table --
update bank_account set Balance = (Balance-500) where Account_No = 1111;
update bank_account set Balance = (Balance+1000) where Account_No = 2222;
update bank_account set Balance = (Balance-1500) where Account_No = 3333;
update bank_account set Balance = (Balance+2000) where Account_No = 4444;

-- dropping the both the triggers --
drop trigger after_bank_update;
drop trigger after_bank_update1;


-- CREATE PROCEDURE HOURLY_SUM -- 
DELIMITER //
CREATE PROCEDURE HOURLY_SUM (IN Account_No INT, OUT WTotal numeric(10,2), OUT DTotal numeric(10,2))
BEGIN
    SELECT sum(Transaction_amt) INTO WTotal FROM test.bank_udpate
	WHERE Actions = 'Debit' AND Account_No=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
    
    SELECT sum(Transaction_amt) INTO DTotal FROM test.bank_udpate
	WHERE Actions = 'Credit' AND Account_No=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
END //

-- DROP THE PROCEDURE --
DROP PROCEDURE HOURLY_SUM;

-- CALLING THE PROCEDURE --
CALL HOURLY_SUM(1111, @WTotal, @DTotal);

-- DISPLAYING THE CALLED PROCEDURE --
SELECT @WTotal, @DTotal;

-- CREAETING EVENT TO CALL PROCEDURE HOURLY--
CREATE EVENT MyEvent
    ON SCHEDULE EVERY 1 HOUR
    DO
      CALL HOURLY_SUM(1, @WTotal, @DTotal);

-- DROP THR EVENT --
DROP EVENT MyEvent;