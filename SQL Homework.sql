use sakila;

-- 1a display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the 
--  column Actor Name
SELECT CONCAT (first_name, ' ', last_name) AS 'Actor Name' 
FROM actor;

-- 2a Find ID, first name, last name whom you only know the first name is Joe
-- one condition statement searching for Joe
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b Find all actors whose last name contains the letters GEN
SELECT * 
FROM actor
WHERE last_name
Like '%GEN%';

-- 2c Find all actors whose last names contain LI, and order by last name and first name
SELECT last_name, first_name
FROM actor
WHERE last_name
Like '%LI%';

-- 2d Display country_ID and country columns using IN for Afghanistan, bangladesh, and china
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries 
-- on a description, so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a List the last names of actors and how many actors have that name
SELECT last_name, COUNT(last_name) AS 'Total Count of Last Names'
FROM actor
GROUP BY last_name;

-- 4b List last names of actos whoe have that last name but only for names that shared by at least 2
SELECT last_name, COUNT(last_name) AS 'Total Count of Last Names'
FROM actor
GROUP BY last_name
HAVING count(last_name) >= 2;

-- 4c Change Groucho Williams to Harpo Williams
-- Obtain actor_id
SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = 'Groucho';

UPDATE actor
SET first_name = 'Harpo'
WHERE actor_id = 172;

-- Verify change in table took place
SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = 'Harpo';

-- 4d Change Harpo back to Groucho
UPDATE actor
SET first_name = 'Groucho'
WHERE actor_id = 172;

SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = 'Groucho';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW COLUMNS from sakila.address;
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
--  Use the tables staff and address

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
INNER JOIN payment ON
staff.staff_id = payment.staff_id
WHERE payment_date >= '2005-08-01' AND payment_date <= '2005-08-31'
GROUP BY staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use inner join

SELECT film.title, count(film_actor.actor_id) as "Count Actors Per Film"
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film_actor.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the 
-- inventory system?

SELECT film.title, count(inventory.inventory_id) as "Count of Hunchback Impossible"
FROM film
JOIN inventory ON
film.film_id = inventory.film_id
GROUP BY film.film_id
HAVING title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name. 

SELECT customer.first_name, customer.last_name, sum(payment.amount) as "Total Paid by Customer"
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY last_name;

-- 7a films starting with K and Q have soared. Use subqueries to display the titles of movies starting
-- with the letters of k and Q whose language is english.

SELECT film.title
FROM film
WHERE language_id IN
	(SELECT language.language_id
    FROM language
    WHERE language.name = "English")
AND film.title LIKE "K%" 
OR film.title LIKE "Q%";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
from actor
WHERE actor_id IN
	(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
		(
        SELECT film_id
        FROM film
        WHERE title = "Alone Trip"
        )
	);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names
-- and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
JOIN address ON 
customer.address_id = address.address_id
JOIN city ON 
address.city_id = city.city_id
JOIN country ON
city.country_id = country.country_id
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT film.title, category.name
FROM film
JOIN film_category ON 
film.film_id = film_category.film_id
JOIN category ON 
film_category.category_id = category.category_id
WHERE name = "Family";

-- 7e. Display the most frequently rented movies in descending order.

SELECT count(rental.rental_id), film.title as "Most Frequently Rented"
FROM film
JOIN inventory ON
film.film_id = inventory.film_id
JOIN rental ON
inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY COUNT(rental.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, sum(payment.amount) as "Revenue Per Store"
FROM staff
JOIN payment ON
staff.staff_id = payment.staff_id
JOIN store ON
staff.store_id = store.store_id
GROUP BY store.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address ON
store.address_id = address.address_id
JOIN city ON
address.city_id = city.city_id
JOIN country ON
city.country_id = country.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, sum(payment.amount) AS "Total Revenue"
FROM category
JOIN film_category ON
category.category_id = film_category.category_id
JOIN inventory ON
film_category.film_id = inventory.film_id
JOIN rental ON
inventory.inventory_id = rental.inventory_id
JOIN payment ON
rental.rental_id = payment.payment_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres
-- by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_5_Genres AS 
SELECT category.name, sum(payment.amount) AS "Total Revenue"
FROM category
JOIN film_category ON
category.category_id = film_category.category_id
JOIN inventory ON
film_category.film_id = inventory.film_id
JOIN rental ON
inventory.inventory_id = rental.inventory_id
JOIN payment ON
rental.rental_id = payment.payment_id
GROUP BY category.name
ORDER BY 2 DESC;


-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Top_5_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top_5_Genres;

