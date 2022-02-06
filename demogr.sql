--CREATING NEW DATABASE

CREATE DATABASE dem;

--CREATING TABLE WITH RAW DATA

CREATE TABLE dem_unchanged
(
    id int not null AUTO_INCREMENT,
    city_code int,
    city varchar(50),
    voiv_code int,
    voivodeship varchar(32),
    age varchar(10),
    sex varchar(10),
    area_type varchar(10),
    population int,
    year varchar(4),
    PRIMARY KEY (id)
);

DROP TABLE dem_unchanged;

-- Loading the data

-- Enable local-infile
-- SET GLOBAL local_infile = 1

-- Relogging
-- mysql --local-infile=1 -u root -p

CREATE TABLE dem_temp
(
    city_code int,
    city varchar(50),
    voiv_code int,
    voivodeship varchar(32),
    age varchar(10),
    sex varchar(10),
    area_type varchar(10),
    population int,
    year varchar(4)
);

--Loading data using load-files.sh

--Selecting 'important' data

SELECT city, year, sum(population) FROM dem_unchanged
WHERE (city like '%m%Wrocław%' or city like '%m%Zabrze%' or city like '%m%Katowice%' or city like '%m%Kraków%' or city like '%m%Warszawa%' or city like '%m%Gdańsk%')
and (age like '%-%' or age like '%+%')
GROUP BY city, year
Order by year, city;

--Creating a target table

CREATE TABLE demog
(
    city varchar(50),
    year varchar(4),
    population int
);

--Inserting data
INSERT INTO demog
(SELECT 
CASE
    WHEN city like '%Warszawa' THEN substr(city, 15) 
    ELSE substr(city,11) 
END city, year, sum(population) population
FROM dem_unchanged
WHERE (city like '%m%Wrocław%' or city like '%m%Zabrze%' or city like '%m%Katowice%' or city like '%m%Kraków%' or city like '%m%Warszawa%' or city like '%m%Gdańsk%')
and (age like '%-%' or age like '%+%')
GROUP BY city, year
Order by year, city);


--Adding primary key (if the primary key was added first then mysql would skip values when adding data)
ALTER TABLE demog
ADD COLUMN id int not null AUTO_INCREMENT PRIMARY KEY FIRST;

--Export

SELECT * FROM demog
INTO OUTFILE '/var/lib/mysql-files/dem.csv'
FIELDS ENCLOSED BY ''
TERMINATED BY ','
LINES TERMINATED BY '\r\n';