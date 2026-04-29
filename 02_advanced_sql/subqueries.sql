
/* ----------------------------------- SUBQUERIES ---------------------------------
-- Subqueries are queries inside a main query (outer query).
-- They make your code more efficient because they can do more in a single query.
-- Makes queries more readable because they can be more self-contained. */


/* ----------- [1] Subqueries within the SELECT clause ------------------------ */
-- Show countries and the difference in their happiness_scores from the average
SELECT
	year, country, happiness_score,
	ROUND(happiness_score - (SELECT AVG(happiness_score) FROM happiness_scores), 2) AS diff_from_avg
FROM happiness_scores;


-- Can you give me a list of our products from most to least expensive,
-- along with how much each product differs from the average unit price.
SELECT
	product_id, product_name, unit_price,
	ROUND((SELECT AVG(unit_price) FROM products), 2) AS avg_unit_price,
	ROUND(unit_price - (SELECT AVG(unit_price) FROM products), 2) AS price_difference
FROM products
WHERE unit_price IS NOT NULL
ORDER BY unit_price DESC;



/* ----------- [2] Subqueries in the FROM clause ------------------------ 

Return each country's happiness score for the year
alongside the country's average happiness score. */
SELECT hs.year, hs.country, hs.happiness_score,
	   country_hs.avg_hs 
FROM happiness_scores hs LEFT JOIN
		(SELECT country, ROUND(AVG(happiness_score), 2) AS avg_hs 
		FROM happiness_scores
		GROUP BY country) AS country_hs
		ON hs.country = country_hs.country
WHERE hs.country = 'United States';



/* ----------- [3] Multiple Subqueries ------------------------ 
Queries can contain multiple subqueries as long as each one has a different alias

Return average happiness score, and the happiness score a point greater
than a country's average happiness score
 */
 SELECT * FROM
 (SELECT hs.year, hs.country, hs.happiness_score,
 		country_hs.avg_hs
 FROM
	(SELECT year, country, happiness_score FROM happiness_scores
	UNION ALL
	SELECT 2024, country, ladder_score FROM happiness_scores_current) AS hs
		LEFT JOIN
			(SELECT country, ROUND(AVG(happiness_score), 2) AS avg_hs
			FROM happiness_scores
			GROUP BY country) AS country_hs -- NB: the avg doesn't capture 2024..to be corrected using CTE
		ON country_hs.country = hs.country)  AS hs_score
WHERE happiness_score > avg_hs + 1
;


-- Find the list of factories, names of the products they produce and the number of products they produce

SELECT fp.factory, fp.product_name, fn.num_products
	FROM
		(SELECT factory, product_name 
				FROM products) AS fp
			LEFT JOIN
		(SELECT factory, COUNT(product_id) AS num_products 
				FROM products
				GROUP BY factory) AS fn
		ON fp.factory = fn.factory
		ORDER BY fp.factory, fp.product_name;



/* ----------- [4] Subqueries in the WHERE and HAVING clauses ------------------------ */

-- Return regions with above average happiness score
SELECT
    region,
    AVG(happiness_score) AS reg_avg_score
FROM happiness_scores
GROUP BY region
HAVING AVG(happiness_score) > (
    SELECT AVG(happiness_score)
    FROM happiness_scores
);


/* ----------- [5] Using ANY vs ALL ------------------------ */
-- Return happiness scores that are greater than ANY/ALL of the current happiness scores

-- * Using ANY: scores that are greater than ANY 2024 scores
SELECT * 
FROM happiness_scores
WHERE happiness_score > ANY(SELECT ladder_score 
							FROM happiness_scores_current)

-- * Using ALL: scores that are greater than ANY 2024 scores
SELECT * 
FROM happiness_scores
WHERE happiness_score > ALL(SELECT ladder_score 
							FROM happiness_scores_current)


/* ----------- [6] Using EXISTS ------------------------ 
-- Provides more specific filtering logic */

-- Only return happiness scores for countries that EXIST in the inflation rates table
SELECT *
FROM happiness_scores h
WHERE EXISTS (
	SELECT i.country_name
	FROM inflation_rates i
	WHERE i.country_name = h.country); -- correlated query (slower, but more readable)

-- Using an INNER JOIN for the same results
SELECT *
FROM happiness_scores h
INNER JOIN
inflation_rates i
ON i.country_name = h.country AND h.year = i.year;


/* Help us identify products that have unit price less than that of all products
from Wicked Choccy's?
Please include which factory is producing them as well */
SELECT *
FROM products
WHERE unit_price < ALL (
    SELECT unit_price
    FROM products
    WHERE factory = 'Wicked Choccy''s')
ORDER BY unit_price;

-- Alternatively
SELECT *
FROM products
WHERE unit_price < (
    SELECT MIN(unit_price)
    FROM products
    WHERE factory = 'Wicked Choccy''s'
);


-- CTEs next in the next file
