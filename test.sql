---Before we get started, take a moment to familiarize yourself with the database. There are two tables we will be working with: customers and customers_log. To make your life easier we would recommend ordering the customers table by customer_id.
SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers_log;

---Your boss has tasked you with creating a trigger to log anytime someone updates the customers table. There is already a procedure to insert into the customers_log table called log_customers_change(). This function will create a record in customers_log and we want it to fire anytime an UPDATE statement modifies first_name or last_name. Give the trigger an appropriate name. Are there other situations you might suggest creating triggers for as well?
CREATE TRIGGER customer_updated
  BEFORE UPDATE ON customers
  FOR EACH ROW
  EXECUTE PROCEDURE log_customers_change();

  ---Can you confirm your trigger is working as expected? Remember, it should only create a log for changes to first_name and/or last_name. We know what the state of the customers and customers_log tables are from our previous check so we can go directly to testing your trigger.
UPDATE customers
SET first_name = 'Garrett'
WHERE last_name = 'Hall';

SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers_log;

---You suggested to your boss that INSERT statements should also be included (you had also suggested DELETE and TRUNCATE be covered as well, but legal thought this wasn’t needed for some reason). They agreed, but thought that tracking every row for inserts wasn’t necessary — a single record of who did the bulk insert would be enough. Create the trigger to call the log_customers_change procedure once for every statement on INSERT to the customers table. Call it customer_insert.
CREATE TRIGGER customer_insert
  AFTER INSERT ON customers
  FOR EACH STATEMENT
  EXECUTE PROCEDURE log_customers_change();

---Add three names to the customers table in one statement. Is your trigger working as expected and only inserting one row per insert statement, not per record? What would the log look like if you had your trigger fire on every row?
INSERT INTO customers (first_name, last_name, years_old)
VALUES
  ('Jeffrey','Cook',66),
  ('Marie','Arcilla',30),
  ('Nathan','Cooper',72);

SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers_log;

---Your boss has changed their mind again, and now has decided that the conditionals for when a change occurs should be on the trigger and not on the function it calls. In this example, we’ll be using the function override_with_min_age(). The trigger should detect when age is updated to be below 13 and call this function. This function will assume this was a mistake and override the change and set the age to be 13. Name your trigger something appropriately, we called ours customer_min_age. What will happen with the customers and customers_log tables?
CREATE TRIGGER customer_min_age
  BEFORE UPDATE ON customers
  FOR EACH ROW
  WHEN (NEW.years_old < 13)
  EXECUTE PROCEDURE override_with_min_age();

---Let’s test this trigger — two more changes to the customers table have come in. Modify one record to set their age under 13 and another over 13, then check the results in the customers and customers_log table. Note, setting it to exactly 13 would still work, it would just be harder to confirm your trigger was working as expected. What do you expect to happen and why?
UPDATE customers
SET years_old = 12
WHERE last_name = 'Campbell';

UPDATE customers
SET years_old = 24
WHERE last_name = 'Cook';

SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers_log;

---What would happen if you had an update on more columns at once, say modifications to the first_name and years_old in the same query? Try this now then run your check on customers (with the order we have been using) and customers_log.
UPDATE customers
SET years_old = 9,
  first_name = 'Dennis'
WHERE last_name = 'Hall';

SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers_log;

---Though your trigger setting the years_old to never be under 13 is working, a better way to do the same thing would be with a constraint on the column itself. For now, let’s remove the trigger we created to set the minimum age. Ours was called customer_min_age.
DROP TRIGGER IF EXISTS customer_min_age ON customers;

---Then check the status of the triggers after your change.
SELECT *
FROM information_schema.triggers;