/* In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. 
The report will be generated using a combination of views, CTEs, and temporary tables.*/

/*Step 1: Create a View
First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).*/

USE sakila;

DROP VIEW IF EXISTS rental_information;

CREATE VIEW rental_information AS
SELECT  
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS total_rental
FROM customer c
LEFT JOIN rental r 
    ON r.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_rental DESC;

/*Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.*/

DROP TEMPORARY TABLE IF EXISTS temp_customer_payment;

CREATE TEMPORARY TABLE temp_payment_table AS
SELECT  
    r.customer_id,
    r.first_name,
    r.last_name,
    r.email,
    COUNT(p.payment_id) AS number_payments,
    IFNULL(SUM(p.amount),0) AS total_payment
FROM rental_information r
LEFT JOIN payment p
    ON r.customer_id = p.customer_id
GROUP BY 
    r.customer_id, r.first_name, r.last_name, r.email
ORDER BY total_payment DESC;

SELECT * FROM temp_payment_table;


/*Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.*/

WITH customer_summary_report AS (
    SELECT 	r.customer_id,
			r.first_name,
			r.last_name,
			r.email,
			r.total_rental,
            tp.total_payment            
    FROM rental_information r
    JOIN temp_payment_table tp
        ON r.customer_id = tp.customer_id  
)
SELECT  
		CONCAT(first_name, " ", last_name) AS customer_name,
        email,
        total_rental,
        total_payment
FROM customer_summary_report
ORDER BY total_payment DESC;



/*Next, using the CTE, create the query to generate the final customer summary report, which should include: 
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/

WITH final_customer_report AS (
    SELECT  
        r.customer_id,
        r.first_name,
        r.last_name,
        r.email,
        r.total_rental,
        tp.total_payment,
        CASE 
            WHEN r.total_rental > 0 
            THEN ROUND(tp.total_payment / r.total_rental, 2)
            ELSE 0
        END AS avg_payment_per_rental
    FROM rental_information r
    JOIN payment_table tp
        ON r.customer_id = tp.customer_id  
)
SELECT  *
FROM final_customer_report
ORDER BY avg_payment_per_rental DESC;

