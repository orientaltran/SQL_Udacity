/*-------------SQL PROJECT1------------------------*/
/* Drop VIEW if it already exists */
Drop view if exists forestation;

----1.Creating a view called “Forestation”
/* Create VIEW  */
CREATE VIEW forestation AS
    SELECT
        r.region,
        l.year           AS lands_year,
        f.forest_area_sqkm,
        l.total_area_sq_mi,
        r.income_group,
        l.country_name   AS lands_country_name,
        f.country_name   AS forests_country_name,
        r.country_name   AS regions_country_name,
        f.country_code   AS forests_country_code,
        l.country_code   AS lands_country_code,
        r.country_code   AS regions_country_code,
        f.year           AS forests_year,
        ( f.forest_area_sqkm / 2.59 ) / l.total_area_sq_mi * 100 AS percent_forest_area
    FROM
        forest_area   f
        INNER JOIN land_area     l ON f.country_code = l.country_code
                                  AND f.year = l.year
        INNER JOIN regions       r ON l.country_code = r.country_code;
/* End Create VIEW  */

----1.GLOBAL SITUATION---------------------------------------------------------------------------------
/* The query below results in the total forest area in sq km in the year 1990 */
/* Get country_name is World and have year 2016 or 1990 */
SELECT
    *
FROM
    forest_area
WHERE
    country_name = 'World'
    AND ( year = 2016
          OR year = 1990 );
-- country_code	country_name	year	forest_area_sqkm
-- WLD	        World	        2016	39958245.9
-- WLD	        World	        1990	41282694.9
-- The above query yielded the result of 41282694.9 square kilometers for the year 1990.
-- The above query yielded the result of 39958245.9 square kilometers for the year 2016.

/* Get difference */
SELECT
    curr.forest_area_sqkm - prev.forest_area_sqkm AS difference
FROM
    forest_area AS curr JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990'
                                          AND curr.country_name = 'World'
                                              AND prev.country_name = 'World' );
-- difference
-- -1324449

/* Get percent_forest_area */
SELECT
    100.0 * ( curr.forest_area_sqkm - prev.forest_area_sqkm ) / prev.forest_area_sqkm AS percent_forest_area
FROM
    forest_area AS curr JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990'
                                          AND curr.country_name = 'World'
                                              AND prev.country_name = 'World' );
-- percentage
-- -3.20824258980244

/* Get total_area_sqkm */
SELECT
    regions_country_name,
    ( total_area_sq_mi * 2.59 ) AS total_area_sqkm
FROM
    forestation
WHERE
    lands_year = 2016
ORDER BY
    total_area_sqkm;
-- Peru  1279999.9891

/* 2.	REGIONAL OUTLOOK */-------------------------------------------------------------------------------------------
/* Get the percent of the total land area of the world designated as forest was: */
SELECT
    percent_forest_area
FROM
    forestation
WHERE
    lands_year = 2016
    AND lands_country_name = 'World';
-- 31.3755709643095

/* Get all data with year 1990 and country is Workd */
SELECT
    *
FROM
    forestation
WHERE
    lands_year = 1990
    AND lands_country_name = 'World';
-- 32.4222035575689

/* Get region_forest_1990 and region_area_1990 */
SELECT
    round(CAST((region_forest_1990 / region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990,
    round(CAST((region_forest_2016 / region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016,
    region
FROM
    (
        SELECT
            SUM(a.forest_area_sqkm) region_forest_1990,
            SUM(a.total_area_sq_mi) region_area_1990,
            a.region,
            SUM(b.forest_area_sqkm) region_forest_2016,
            SUM(b.total_area_sq_mi) region_area_2016
        FROM
            forestation   a,
            forestation   b
        WHERE
            a.lands_year = '1990'
            AND a.lands_country_name != 'World'
            AND b.lands_year = '2016'
            AND b.lands_country_name != 'World'
            AND a.region = b.region
        GROUP BY
            a.region
    ) region_percent
ORDER BY
    forest_percent_1990 DESC;
-- forest_percent_1990 forest_percent_2016 region
-- 51.03               46.16               Latin America & Caribbean
-- 37.28               38.04               Europe & Central Asia
-- 35.65               36.04               North America
-- 30.67               28.79               Sub-Saharan Africa
-- 25.78               26.36               East Asia & Pacific
-- 16.51               17.51               South Asia
-- 1.78                2.07                Middle East & North Africa

/* 3.	COUNTRY-LEVEL DETAIL */-------------------------------------------------------------------------------------------
SELECT
    curr.country_name,
    curr.forest_area_sqkm - prev.forest_area_sqkm AS difference
FROM
    forest_area AS curr
JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990' )
                                    AND curr.country_name = prev.country_name
ORDER
    by difference desc;
-- China         527229.062
-- United States 79200
--There is one particularly bright spot in the data at the country level, China. This country actually increased in forest area from 1990 to 2016 by 527229.06.

SELECT
    curr.country_name,
    100.0 * ( curr.forest_area_sqkm - prev.forest_area_sqkm ) / prev.forest_area_sqkm AS percentage
FROM
    forest_area AS curr
JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990' )
                                    AND curr.country_name = prev.country_name
ORDER
    by percentage desc;
-- Iceland           213.664588870028
-- French Polynesia  181.818181818182
-- China and United States are of course very large countries in total land area, so when we look at the largest percent change in forest area from 1990 to 2016,
-- we aren’t surprised to find a much smaller country listed at the top. Iceland increased in forest area by 213.66% from 1990 to 2016. 

SELECT
    curr.country_name,
    curr.forest_area_sqkm - prev.forest_area_sqkm AS difference
FROM
    forest_area AS curr
JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990' )
                                    AND curr.country_name = prev.country_name
ORDER
    by difference;
-- Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016
-- Brazil    -541510
-- Indonesia -282193.9844
-- Myanmar   -107234.0039
-- Nigeria   -106506.00098
-- Tanzania  -102320

SELECT
    curr.country_name,
    100.0 * ( curr.forest_area_sqkm - prev.forest_area_sqkm ) / prev.forest_area_sqkm AS percentage
FROM
    forest_area AS curr
JOIN forest_area as prev ON ( curr.year = '2016'
                                      AND prev.year = '1990' )
                                    AND curr.country_name = prev.country_name
ORDER
    by percentage;
-- Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016
-- Togo        -75.4452559270073
-- Nigeria     -61.7999309388418
-- Uganda      -59.1286034729531
-- Mauritania  -46.7469879518072
-- Honduras    -45.0344149459194


SELECT DISTINCT
    ( quartiles ),
    COUNT(lands_country_name) OVER(
        PARTITION BY quartiles
    )
FROM
    (
        SELECT
            lands_country_name,
            CASE
                WHEN percent_forest_area <= 25 THEN
                    '0-25%'
                WHEN percent_forest_area <= 75
                     AND percent_forest_area > 50 THEN
                    '50-75%'
                WHEN percent_forest_area <= 50
                     AND percent_forest_area > 25 THEN
                    '25-50%'
                ELSE
                    '75-100%'
            END AS quartiles
        FROM
            forestation
        WHERE
            percent_forest_area IS NOT NULL
            AND lands_year = 2016
    ) quart;
--Count of Countries Grouped by Forestation Percent Quartiles, 2016
-- quartiles count
-- 0-25%     85
-- 25-50%    73
-- 50-75%    38
-- 75-100%   9

SELECT
    lands_country_name,
    percent_forest_area
FROM
    forestation
WHERE
    percent_forest_area > 75
    AND lands_year = 2016;
-- Top Quartile Countries, 2016
-- lands_country_name    percent_forest_area
-- American Samoa        87.5000875000875
-- Micronesia, Fed. Sts. 91.8572390715248
-- Gabon                 90.0376418700565
-- Guyana                83.9014489110682
-- Lao PDR               82.1082317640861
-- Palau                 87.6068085491204
-- Solomon Islands       77.8635177945066
-- Suriname              98.2576939676578
-- Seychelles            88.4111367385789
