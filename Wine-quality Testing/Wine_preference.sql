-- Create the database

CREATE DATABASE IF NOT EXISTS wine_preference;
USE wine_preference;
DROP TABLE IF EXISTS Winery;
CREATE TABLE Winery (
    wineryID INT AUTO_INCREMENT PRIMARY KEY,
    winery VARCHAR(50),
    region VARCHAR(50)
);

DROP TABLE IF EXISTS Wine;
SHOW CREATE TABLE Wine;
CREATE TABLE Wine (
    wineID INT AUTO_INCREMENT PRIMARY KEY,
    wineryID INT,
    wine VARCHAR(50),
    year VARCHAR (50),
    type VARCHAR(50),
    body VARCHAR(50),
    acidity FLOAT,
    price FLOAT,
    num_reviews INT,
    FOREIGN KEY (wineryID) REFERENCES Winery(wineryID)
);

DROP TABLE IF EXISTS Rating;
CREATE TABLE Rating (
    ratingID INT AUTO_INCREMENT PRIMARY KEY,
    wineID INT,
    wine VARCHAR(50),  
    rating FLOAT,
    FOREIGN KEY (wineID) REFERENCES Wine(wineID)
);


SELECT COUNT(*) FROM Winery;
SELECT COUNT(*) FROM Wine;
SELECT COUNT(*) FROM Rating;

-- Find the Most Expensive Wines
SELECT wine, winery, price
FROM Wine
JOIN Winery ON Wine.wineryID = Winery.wineryID
ORDER BY price DESC
LIMIT 10;

-- Top 20 Most Expensive Wine Regions

SELECT wi.region, AVG(w.price) AS avg_price
FROM Wine w
JOIN Winery wi ON w.wineryID = wi.wineryID
GROUP BY wi.region
ORDER BY avg_price DESC
LIMIT 20;


-- Highest-Rated Wines Based on Consumer Reviews (hows the highest-rated wines, filtering for those with at least 50 reviews.)
SELECT w.wine, w.year, w.type, AVG(r.rating) AS avg_rating, COUNT(r.rating) AS num_reviews
FROM Wine w
JOIN Rating r ON w.wineID = r.wineID
GROUP BY w.wine, w.year, w.type
ORDER BY avg_rating DESC, num_reviews DESC
LIMIT 10;

-- Find Wines from a Specific Region

SELECT w.wine, w.year, w.type, w.price, wi.winery
FROM Wine w
JOIN Winery wi ON w.wineryID = wi.wineryID
-- WHERE wi.region = 'Rioja'
-- SELECT DISTINCT region FROM Winery;
WHERE wi.region IN ('Rioja', 'Rias Baixas', 'Penedes')
ORDER BY w.price DESC;

-- Compare Wine Prices Across Regions

SELECT wi.region, AVG(w.price) AS avg_price, MIN(w.price) AS min_price, MAX(w.price) AS max_price
FROM Wine w
JOIN Winery wi ON w.wineryID = wi.wineryID
GROUP BY wi.region
ORDER BY avg_price DESC;

-- Lowest and highest rating
SELECT MIN(rating) AS min_rating, MAX(rating) AS max_rating FROM Rating;


-- ADVANCE QUERY: Finding Price vs. Rating Correlation. Does spending more on wine mean better ratings? 
-- This query checks the average rating for different price ranges:
SELECT 
    CASE 
        WHEN w.price < 50 THEN 'Budget (<50€)'
        WHEN w.price BETWEEN 50 AND 200 THEN 'Mid-Range (50-200€)'
        ELSE 'Premium (>200€)'
    END AS price_category,
    AVG(r.rating) AS avg_rating
FROM Wine w
JOIN Rating r ON w.wineID = r.wineID
GROUP BY price_category
ORDER BY avg_rating DESC;

-- Instead of a simple average, calculating weighted average, giving more influence to wines 
-- with more reviews.
SELECT 
    CASE 
        WHEN w.price < 50 THEN 'Budget (<50€)'
        WHEN w.price BETWEEN 50 AND 200 THEN 'Mid-Range (50-200€)'
        ELSE 'Premium (>200€)'
    END AS price_category,
    SUM(r.rating * w.num_reviews) / SUM(w.num_reviews) AS weighted_avg_rating
FROM Wine w
JOIN Rating r ON w.wineID = r.wineID
WHERE w.num_reviews > 50
GROUP BY price_category
ORDER BY weighted_avg_rating DESC;


