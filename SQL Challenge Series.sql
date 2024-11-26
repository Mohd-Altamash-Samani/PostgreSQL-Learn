-- Level 1 Questions

-- Q1: Who is the senior-most employee based on levels?

SELECT 
    first_name, 
    last_name, 
    title, 
    levels
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most invoices?

SELECT 
    billing_country, 
    COUNT(billing_country) AS billing_count
FROM invoice
GROUP BY billing_country
ORDER BY billing_count DESC;

-- Q3: What are the top 3 values of total invoice amounts? 

SELECT 
    total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the best customers?
/* We want to identify the city with the highest sum of invoice totals. */

SELECT 
    billing_city, 
    SUM(total) AS total
FROM invoice
GROUP BY billing_city
ORDER BY total DESC
LIMIT 1;

-- Q5: Who is the best customer? 
/* Identify the customer who has spent the most money. */

SELECT 
    c.customer_id, 
    first_name, 
    last_name, 
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- Level 2 Questions

-- Q1: List the email, first name, last name, and genre of all Rock music listeners. 

SELECT DISTINCT 
    c.first_name, 
    c.last_name, 
    c.email
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock';

-- Q2: Which artists have written the most Rock music? 
/* Return the artist name and total track count for the top 10 rock artists. */

SELECT 
    a.artist_id, 
    a.name, 
    COUNT(a.artist_id) AS track_count
FROM artist a
JOIN album al ON al.artist_id = a.artist_id
JOIN track t ON t.album_id = al.album_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY track_count DESC
LIMIT 10;

-- Q3: List all track names with a song length longer than the average. 
/* Return the name and length, ordered by length (longest first). */

SELECT 
    t.name, 
    t.milliseconds
FROM track t
WHERE t.milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY t.milliseconds DESC;

-- Q4: How much has each customer spent on artists? 
/* Return the customer name, artist name, and total spent. */

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;


-- Level 3 Questions

-- Q1: Find the customer who spent the most on the artist with the highest sales. 
/* Identify the best-selling artist and their top customer. */

WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_id, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_id, bsa.artist_name
ORDER BY amount_spent DESC;

-- Q2: Determine the most popular music genre in each country. 
/*  List each country with its top genre. */

WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT * 
FROM popular_genre 
WHERE RowNo = 1;

-- Q3: Find the customer who spent the most on music in each country. 
/* Return the country, customer name, and total spending. */

WITH customer_with_country AS (
    SELECT 
        customer.customer_id, 
        first_name, 
        last_name, 
        billing_country, 
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
)
SELECT * 
FROM customer_with_country 
WHERE RowNo = 1;
