-- ================================================
-- dæmi 3 liður 1 part b: Finding the Third Largest Kingdom
-- ================================================

WITH kingdom_areas AS (
    SELECT
        k.gid AS kingdom_id,
        k.name,
        greyjoy.get_kingdom_size(k.gid) AS area_km2
    FROM atlas.kingdoms k
)
SELECT kingdom_id, name, area_km2
FROM kingdom_areas
ORDER BY area_km2 DESC
LIMIT 1 OFFSET 2;  -- Retrieves the third largest kingdom




-- ================================================
-- dæmi 3 liður 2: Finding the Rarest Location Type Outside The Seven Kingdoms
-- ================================================

-- Step 1: skilgreina konungsríkin 7
WITH seven_kingdoms AS (
    SELECT gid, geog::geometry AS geog_geom
    FROM atlas.kingdoms
    WHERE name IN (
                   'The North',
                   'The Vale',
                   'The Riverlands',
                   'The Westerlands',
                   'The Reach',
                   'The Stormlands',
                   'Dorne'
        )
),

-- Step 2: Find Locations Outside The Seven Kingdoms
     locations_outside AS (
         SELECT l.*, l.geog::geometry AS geog_geom
         FROM atlas.locations l
     ),

-- Step 3: Count Location Types Outside The Seven Kingdoms
     type_counts AS (
         SELECT
             l.type,
             COUNT(*) AS type_count
         FROM locations_outside l
         WHERE NOT EXISTS (
             SELECT 1
             FROM seven_kingdoms sk
             WHERE ST_Contains(sk.geog_geom, l.geog_geom)
         )
         GROUP BY l.type
     ),

-- Step 4: Identify the Rarest Location Type(s)
     rarest_type AS (
         SELECT type
         FROM type_counts
         WHERE type_count = (SELECT MIN(type_count) FROM type_counts)
     )

-- Step 5: Retrieve Locations of the Rarest Type
SELECT
    l.type,
    l.name AS location_name
FROM locations_outside l
         JOIN rarest_type rt ON l.type = rt.type
WHERE NOT EXISTS (
    SELECT 1
    FROM seven_kingdoms sk
    WHERE ST_Contains(sk.geog_geom, l.geog_geom)
)
ORDER BY l.name;