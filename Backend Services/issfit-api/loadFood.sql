WITH selected AS (
    WITH non_exists AS (
        SELECT normalize(ft.name) AS name, ft.origin
        FROM food_tmp_view ft
        EXCEPT
        SELECT normalize(fp.name) AS name, fp.origin_uuid
        FROM food_product fp
        WHERE fp.origin_uuid IS NOT NULL)
    SELECT MAX(ft.id) AS id, normalize(ft.name) AS name, ft.origin
    FROM food_tmp_view ft, non_exists
    WHERE normalize(ft.name) = non_exists.name AND ft.origin = non_exists.origin
    GROUP BY normalize(ft.name), ft.origin ORDER BY id ASC
)
INSERT INTO food_product(uuid, name, category_uuids, origin_uuid, barcode, fluid, energy, sodium, protein, carb, fat, removed, synchronized, created_date, modified_date)
SELECT uuid_generate_v4() AS uuid, ft.name, ft.categories, ft.origin, ft.barcode, ft.fluid, ft.energy, ft.sodium,
       ft.protein, ft.carb, ft.fat, ft.removed, true, current_timestamp, current_timestamp
FROM food_tmp_view ft
WHERE ft.id IN (SELECT id FROM selected);

WITH selected AS (
    SELECT MAX(ft.id) AS id, normalize(ft.name) AS name, ft.origin
    FROM food_tmp_view ft
    GROUP BY normalize(ft.name), ft.origin ORDER BY id ASC
)
UPDATE food_product fp
     SET category_uuids = f.categories,
         name = f.name,
         barcode = f.barcode,
         fluid = f.fluid,
         energy = f.energy,
         sodium = f.sodium,
         protein = f.protein,
         carb = f.carb,
         fat = f.fat,
         removed = f.removed,
         synchronized = true,
         modified_date = current_timestamp
FROM (SELECT up_ft.* FROM food_tmp_view up_ft ORDER BY up_ft.id asc) AS f
WHERE f.id IN (SELECT id FROM selected)
AND normalize(f.name) = normalize(fp.name)
AND f.origin = fp.origin_uuid
AND (EXTRACT(epoch FROM fp.modified_date) + (('x'||replace(fp.uuid,'-',''))::bit(64)::bigint)/1e20) = (SELECT MAX(EXTRACT(epoch FROM fpp.modified_date) + (('x'||replace(fpp.uuid,'-',''))::bit(64)::bigint)/1e20)
               FROM food_product fpp
               WHERE normalize(f.name) = normalize(fpp.name)
               AND f.origin = fpp.origin_uuid
               GROUP BY normalize(fpp.name), fpp.origin_uuid);

TRUNCATE TABLE food_tmp_table;
