CREATE TABLE ridestest AS SELECT * FROM rides LIMIT 1000;

ALTER TABLE ridestest ADD COLUMN pickup geometry(Point, 4326);
ALTER TABLE ridestest ADD COLUMN dropoff geometry(Point, 4326);

UPDATE ridestest SET pickup = ST_SetSRID(ST_MakePoint("Pickup_longitude", "Pickup_latitude"), 4326);
UPDATE ridestest SET dropoff = ST_SetSRID(ST_MakePoint("Dropoff_longitude", "Dropoff_latitude"), 4326);

