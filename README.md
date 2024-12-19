# MOVIE_RENTAL_SHOP_DATA_ANALYSIS_SQL_PROJECT

**Overview**

This repository contains SQL scripts designed to analyze data from a rental movie business database. The project focuses on answering key business questions, providing insights into customer behavior, inventory management, revenue generation, and operational efficiency. It utilizes various SQL techniques to extract and analyze data from a relational database.

**Project Objectives**

* Explore the database schema and understand the relationships between tables.

* Analyze rental patterns, customer activity, and revenue streams.

* Provide actionable insights for marketing, inventory management, and business operations.

* Answer specific business questions using SQL queries.

**Database Schema**

The database contains the following tables:

* CUSTOMER: Customer details such as name, email, and activity status.

* RENTAL: Records of movie rentals.

* INVENTORY: Inventory information for each store.

* FILM: Movie details including title, rating, rental rate, and special features.

* FILM_CATEGORY: Categories associated with films.

* PAYMENT: Payment transactions.

* STAFF: Staff information.

* LANGUAGE: Languages available for films.

**Features and Queries**

1. Customer Insights

Extract customer details for marketing:

**SELECT first_name, last_name, email FROM CUSTOMER;*

2. Rental Rate Analysis

Count movies with a rental rate of $0.99:

**SELECT COUNT(*) AS CHEAPEST_RENTALS FROM film WHERE rental_rate = 0.99;*

Group movies by rental rate:

**SELECT rental_rate, COUNT(*) AS total_numb_of_movies FROM film GROUP BY rental_rate;*

3. Movie Popularity and Revenue

Identify the most rented movies:

**SELECT film.title, COUNT(rental.rental_id) AS POPULARITY FROM rental
LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film ON inventory.film_id = film.film_id
GROUP BY film.title ORDER BY POPULARITY DESC;*

Calculate revenue per film (top 10):

**SELECT RENTAL_ID_TRANSACTIONS.TITLE, SUM(P.AMOUNT) AS GROSS_REVENUE
FROM (
  SELECT R.RENTAL_ID, F.FILM_ID, F.TITLE
  FROM RENTAL AS R
  LEFT JOIN INVENTORY AS INV ON R.INVENTORY_ID = INV.INVENTORY_ID
  LEFT JOIN FILM AS F ON INV.FILM_ID = F.FILM_ID
) AS RENTAL_ID_TRANSACTIONS
LEFT JOIN PAYMENT AS P ON RENTAL_ID_TRANSACTIONS.RENTAL_ID = P.RENTAL_ID
GROUP BY RENTAL_ID_TRANSACTIONS.TITLE ORDER BY GROSS_REVENUE DESC LIMIT 10;*

4. Customer Loyalty and Activity

Reward customers with over 30 rentals:

**SELECT LOYAL_CUSTOMERS.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, C.EMAIL
FROM (
  SELECT CUSTOMER_ID, COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
  FROM RENTAL
  GROUP BY CUSTOMER_ID HAVING NUMBER_OF_RENTALS >= 30
) AS LOYAL_CUSTOMERS
LEFT JOIN CUSTOMER AS C ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID;*

5. Store-Specific Analysis

Determine which store generates the most revenue:

**SELECT S.STORE_ID, SUM(P.AMOUNT) AS STORE_REVENUE
FROM PAYMENT AS P
LEFT JOIN STAFF AS S ON P.STAFF_ID = S.STAFF_ID
GROUP BY S.STORE_ID ORDER BY STORE_REVENUE DESC;*

List titles and descriptions of movies available in Store 2:

**SELECT DISTINCT FILM.TITLE, FILM.DESCRIPTION
FROM FILM
INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID
WHERE INVENTORY.STORE_ID = 2;*

6. Special Features

Identify films with behind-the-scenes features:

**SELECT TITLE, SPECIAL_FEATURES FROM FILM WHERE SPECIAL_FEATURES LIKE '%Behind the Scenes%';*

7. Rental Trends

Analyze rentals per month:

**SELECT MONTHNAME(RENTAL_DATE) AS MONTH_NAME, EXTRACT(YEAR FROM RENTAL_DATE) AS YEAR_NUMBER, COUNT(rental_id) AS NUMBER_RENTALS
FROM rental GROUP BY EXTRACT(YEAR FROM RENTAL_DATE), MONTHNAME(RENTAL_DATE)
ORDER BY NUMBER_RENTALS DESC;*

