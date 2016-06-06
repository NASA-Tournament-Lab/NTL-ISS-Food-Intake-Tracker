WITH selected AS (
	SELECT ft.name, ft.origin, MAX(ft.id) as id
	FROM food_tmp_view ft 
	LEFT JOIN food_product fp ON ft.name = fp.name AND ft.origin = fp.origin_uuid
	WHERE fp.name is NULL
	GROUP BY ft.name, ft.origin
)
INSERT INTO food_product(uuid, name, category_uuids, origin_uuid, barcode, fluid, energy, sodium, protein, carb, fat, removed, synchronized, created_date, modified_date)
SELECT uuid_generate_v4() AS uuid, ft.name, ft.categories, ft.origin, ft.barcode, ft.fluid, ft.energy, ft.sodium, 
       ft.protein, ft.carb, ft.fat, ft.removed, true, current_timestamp, current_timestamp 
FROM food_tmp_view ft
WHERE ft.id in (SELECT id from selected);
	
WITH selected AS (
	SELECT ft.id
	FROM food_tmp_view ft 
	LEFT JOIN food_product fp ON ft.name = fp.name AND ft.origin = fp.origin_uuid
	WHERE ft.name = fp.name AND ft.origin = fp.origin_uuid
	AND fp.name IS NOT NULL AND ft.origin IS NOT NULL
FOR UPDATE)
UPDATE food_product fp
	 SET category_uuids = f.categories,
	 	 origin_uuid = f.origin,
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
	FROM (SELECT up_ft.*
	 	  FROM food_tmp_view up_ft order by up_ft.id desc) AS f	 	 
WHERE f.id in (SELECT id FROM selected) and f.name = fp.name AND f.origin = fp.origin_uuid;

DELETE FROM food_tmp_table;
