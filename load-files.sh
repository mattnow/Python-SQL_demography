#Main loading script
yr=2008
for f in /tmp/*.csv
do
echo "Loading file $f"

mysql --local-infile=1 -u root -p'XXX' 2>/dev/null <<EOF #XXX database password

USE dem
LOAD DATA LOCAL INFILE '$f'
INTO TABLE dem_temp
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(city_code,city,voiv_code,voivodeship,age,sex,area_type,population,year);

UPDATE dem_temp
SET year = $yr;

INSERT INTO dem_unchanged
SELECT * FROM dem_temp;

TRUNCATE TABLE dem_temp;
EOF
echo "OK $f & $yr"
((yr=yr+1))
done;

#Adding primary key to the database and dropping table dem_temp
mysql -u root -p'XXX' 2>/dev/null <<EOF
use dem
ALTER TABLE dem_unchanged
ADD COLUMN id int not null AUTO_INCREMENT PRIMARY KEY FIRST;

DROP TABLE dem_temp;
EOF