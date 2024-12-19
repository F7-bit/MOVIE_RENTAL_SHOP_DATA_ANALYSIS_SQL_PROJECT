-- This project is designed to analyze the operations of a rental movies business, offering actionable insights to improve its performance--
	
-- Key steps include:

-- Exploratory Data Analysis (EDA): Understanding the database schema and exploring the data.
-- Ad-Hoc Business Questions: Addressing critical questions, such as:
-- Expanding the movie collection.
-- Fetching customer emails for marketing campaigns.
-- Tracking and managing inventory effectively.

USE MAVENMOVIES;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT * FROM RENTAL;

SELECT CUSTOMER_ID, RENTAL_DATE
FROM RENTAL;

SELECT * FROM INVENTORY;

SELECT * FROM FILM;

SELECT * FROM CUSTOMER;

-- Provide customers' first names, last names, and email addresses to the marketing team.--

SELECT first_name,last_name,email
FROM CUSTOMER;

-- Determine the number of movies with a rental rate of $0.99.--

SELECT count(*) as CHEAPEST_RENTALS
FROM film
WHERE rental_rate = 0.99;

-- Analyze the rental rates and determine the number of movies in each rental category.--

select rental_rate,count(*) as total_numb_of_movies
from film
group by rental_rate;

-- Find the rating category with the most films --

SELECT RATING,COUNT(*) AS RATING_CATEGORY_COUNT
FROM FILM
GROUP BY RATING
ORDER BY RATING_CATEGORY_COUNT DESC;

-- Find the most prevalent rating in each store --

SELECT I.store_id,F.rating,COUNT(F.rating) AS TOTAL_FILMS
FROM inventory AS I LEFT JOIN
	film AS F
ON I.film_id = F.film_id
GROUP BY I.store_id,F.rating
ORDER BY TOTAL_FILMS DESC;

-- List of films with their Name, Category, and Language--

SELECT F.TITLE, LANG.NAME AS LANGUAGE_NAME,C.NAME AS CATEGORY_NAME
FROM FILM AS F LEFT JOIN LANGUAGE AS LANG
ON F.LANGUAGE_ID = LANG.LANGUAGE_ID
LEFT JOIN film_category AS FC
ON F.FILM_ID = FC.FILM_ID
LEFT JOIN CATEGORY AS C
ON FC.CATEGORY_ID = C.CATEGORY_ID;

--  Count how many times each movie has been rented --

SELECT film.title,count(rental.rental_id) as POPULARITY
FROM rental LEFT JOIN inventory
			ON RENTAL.inventory_id = inventory.inventory_id
			LEFT JOIN  film
            on inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY POPULARITY DESC;

-- Top 10 films by revenue --

SELECT RENTAL_ID_TRANSACTIONS.TITLE,sum(P.AMOUNT) AS GROSS_REVENUE
FROM(SELECT R.RENTAL_ID,F.FILM_ID,F.TITLE
FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
			ON R.INVENTORY_ID = INV.INVENTORY_ID
            LEFT JOIN FILM AS F
            ON INV.FILM_ID = F.FILM_ID) AS RENTAL_ID_TRANSACTIONS
            LEFT JOIN PAYMENT AS P
            ON RENTAL_ID_TRANSACTIONS.RENTAL_ID = P.RENTAL_ID
GROUP BY RENTAL_ID_TRANSACTIONS.TITLE
ORDER BY GROSS_REVENUE DESC
LIMIT 10;

-- Customer with the highest spending --

SELECT payment.customer_id,customer.first_name,customer.last_name,SUM(payment.amount) AS TOTAL_SPENDS
FROM PAYMENT LEFT JOIN customer
             ON PAYMENT.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY TOTAL_SPENDS DESC
LIMIT 1;

-- Which store has brought the most revenue --

SELECT S.STORE_ID,SUM(P.AMOUNT) AS STORE_REVENUE
FROM PAYMENT AS P LEFT JOIN STAFF AS S
             ON P.STAFF_ID = S.STAFF_ID
GROUP BY S.STORE_ID
ORDER BY STORE_REVENUE DESC;

-- How many rentals do we have for each month --

SELECT monthname(RENTAL_DATE) AS MONTH_NAME,extract(YEAR FROM RENTAL_DATE) AS YEAR_NUMBER,COUNT(rental_id) AS NUMBER_RENTALS
FROM rental
GROUP BY EXTRACT(YEAR FROM RENTAL_DATE),MONTHNAME(RENTAL_DATE)
ORDER BY NUMBER_RENTALS DESC;

-- Identify and reward customers who have rented a minimum of 30 times, including their phone number and email ID --

SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTALS >= 30
ORDER BY CUSTOMER_ID;

SELECT LOYAL_CUSTOMERS.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL
FROM(SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTALS >= 30
ORDER BY CUSTOMER_ID) as LOYAL_CUSTOMERS LEFT JOIN CUSTOMER AS C
      ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID
      LEFT JOIN ADDRESS AS AD
      ON C.ADDRESS_ID = AD.ADDRESS_ID;

SELECT DISTINCT RENTAL_DURATION
FROM FILM;

-- Retrieve all payment records for the first 100 customers, ordered by customer ID --

SELECT 
    CUSTOMER_ID, RENTAL_ID, AMOUNT, PAYMENT_DATE
FROM
    PAYMENT
WHERE
    CUSTOMER_ID < 101;

-- Retrieve payment records over $5 for the first 100 customers (ordered by customer ID), since January 1, 2006--

SELECT 
    CUSTOMER_ID, RENTAL_ID, AMOUNT, PAYMENT_DATE
FROM
    PAYMENT
WHERE
    CUSTOMER_ID < 101 AND AMOUNT > 5
        AND PAYMENT_DATE > '2006-01-01';

-- Retrieve all payment records from the first 100 customers, along with payments over $5 from any customer--

SELECT 
    CUSTOMER_ID, RENTAL_ID, AMOUNT, PAYMENT_DATE
FROM
    PAYMENT
WHERE
    AMOUNT > 5 OR CUSTOMER_ID = 42
        OR CUSTOMER_ID = 53
        OR CUSTOMER_ID = 60
        OR CUSTOMER_ID = 75;

SELECT 
    CUSTOMER_ID, RENTAL_ID, AMOUNT, PAYMENT_DATE
FROM
    PAYMENT
WHERE
    AMOUNT > 5
        AND CUSTOMER_ID IN (42 , 53, 60, 75);

-- Retrieve a list of films that include a 'Behind the Scenes' special feature --

SELECT 
    TITLE, SPECIAL_FEATURES
FROM
    FILM
WHERE
    SPECIAL_FEATURES LIKE '%Behind the Scenes%';


-- Retrieve unique movie ratings along with the count of movies for each rating --

SELECT 
    RATING, COUNT(FILM_ID) AS NUMBER_OF_FILMS
FROM
    FILM
GROUP BY RATING;

-- Retrieve a count of titles, grouped by rental duration--

SELECT 
    RENTAL_DURATION, COUNT(FILM_ID) AS NUMBER_OF_FILMS
FROM
    FILM
GROUP BY RENTAL_DURATION;


SELECT 
    RATING, RENTAL_DURATION, COUNT(FILM_ID) AS NUMBER_OF_FILMS
FROM
    FILM
GROUP BY RATING , RENTAL_DURATION;

-- Retrieve movie ratings, the count of movies for each rating, average movie length, and compare with rental duration --

SELECT RATING,
	COUNT(FILM_ID)  AS COUNT_OF_FILMS,
    MIN(LENGTH) AS SHORTEST_FILM,
    MAX(LENGTH) AS LONGEST_FILM,
    AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
    AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;

-- Retrieve the count of films, along with the average, minimum, and maximum rental rates, grouped by replacement cost --

SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- Retrieve a list of customer IDs who have rented fewer than 15 times in total --

SELECT 
    CUSTOMER_ID, COUNT(*) AS TOTAL_RENTALS
FROM
    RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- Retrieve a list of all film titles, along with their lengths and rental rates, sorted from longest to shortest --

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- Categorize movies as per length --

SELECT title,length,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

-- Categorize movies to recommend based on various age groups and demographics --

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;

-- Retrieve a list of the first and last names of all customers, along with their store and activity status (e.g., 'store 1 active', 'store 1 inactive', 'store 2 active', or 'store 2 inactive')--

SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;

-- Retrieve a list of all films in inventory, including the film title, description, associated store_id, and inventory_id --

SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION 
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- -- Retrieve the first name, last name, and the count of movies for each actor --

SELECT * FROM FILM_ACTOR;
SELECT * FROM ACTOR;

SELECT 
    ACTOR.ACTOR_ID,
    ACTOR.FIRST_NAME,
    ACTOR.LAST_NAME,
    COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM
    ACTOR
        LEFT JOIN
    FILM_ACTOR ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
GROUP BY ACTOR.ACTOR_ID;

-- Retrieve a list of all film titles, along with the count of actors associated with each title
-- The investor is interested in understanding the number of actors listed for each film in our inventory. --

SELECT 
    FILM.TITLE, COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTORS
FROM
    FILM
        LEFT JOIN
    FILM_ACTOR ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY FILM.TITLE;
    
-- -- Retrieve a list of all actors, along with the titles of the films they appear in
-- This will help customers find out which films their favorite actors are featured in.--
    
SELECT 
    ACTOR.FIRST_NAME, ACTOR.LAST_NAME, FILM.TITLE
FROM
    ACTOR
        INNER JOIN
    FILM_ACTOR ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
        INNER JOIN
    FILM ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY ACTOR.LAST_NAME , ACTOR.FIRST_NAME;

-- The Manager from Store 2 is working on expanding our film collection there.
-- Retrieve a list of distinct film titles and their descriptions currently available in the inventory at Store 2--

SELECT DISTINCT
    FILM.TITLE, FILM.DESCRIPTION
FROM
    FILM
        INNER JOIN
    INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID
        AND INVENTORY.STORE_ID = 2;

-- Retrieve a unified list of all staff and advisor names, including a column indicating their role as either 'Staff' or 'Advisor'--
-- This will be used to prepare for an upcoming meeting by identifying and categorizing all attendees.--

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;

(SELECT FIRST_NAME,
		LAST_NAME,
        'ADVISORS' AS DESIGNATION
FROM ADVISOR

UNION

SELECT FIRST_NAME,
		LAST_NAME,
        'STAFF MEMBER' AS DESIGNATION
FROM STAFF);
