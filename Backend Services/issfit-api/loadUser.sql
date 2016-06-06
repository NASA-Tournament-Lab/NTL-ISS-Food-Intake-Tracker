WITH selected AS (
	SELECT ft.full_name, MAX(ft.id) as id
	FROM user_tmp_table ft 
	LEFT JOIN nasa_user fp ON ft.full_name = fp.full_name
	WHERE fp.full_name is NULL
	GROUP BY ft.full_name
)
INSERT INTO nasa_user(uuid, full_name, admin, fluid, energy, sodium, protein, carb, fat, packets_per_day, use_last_filter, weight, synchronized, created_date, modified_date)
SELECT uuid_generate_v4() AS uuid, full_name, admin, fluid, energy, sodium, protein, carb, fat, packets_per_day, use_last_filter, weight, true, current_timestamp, current_timestamp 
FROM user_tmp_table ft
WHERE ft.id in (SELECT id from selected);
	
WITH selected AS (
	SELECT id
	FROM user_tmp_table ft 
	LEFT JOIN nasa_user fp ON ft.full_name = fp.full_name
	WHERE ft.full_name = fp.full_name AND fp.full_name IS NOT NULL
FOR UPDATE)
UPDATE nasa_user fp
	 SET full_name = f.full_name, 
	 	 admin = f.admin, 
	 	 fluid = f.fluid, 
	 	 energy = f.energy, 
	 	 sodium = f.sodium, 
	 	 protein = f.protein, 
	 	 carb = f.carb, 
	 	 fat = f.fat, 
	 	 packets_per_day = f.packets_per_day, 
	 	 use_last_filter = f.use_last_filter, 
	 	 weight = f.weight,
	 	 synchronized = true,
	 	 modified_date = current_timestamp
	FROM (SELECT up_ft.*
	 	  FROM user_tmp_table up_ft order by up_ft.id desc) AS f	 	 
WHERE f.id in (SELECT id FROM selected) and f.full_name = fp.full_name;

DELETE FROM user_tmp_table;
