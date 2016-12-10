WITH selected AS (
    WITH non_exists AS (
            SELECT normalize(ft.full_name) AS full_name
            FROM user_tmp_table ft
            EXCEPT
            SELECT normalize(fp.full_name) AS full_name
            FROM nasa_user fp)
    SELECT MAX(ft.id) AS id, normalize(ft.full_name) AS full_name
    FROM user_tmp_table ft, non_exists
    WHERE normalize(ft.full_name) = non_exists.full_name
    GROUP BY normalize(ft.full_name) ORDER BY id asc
)
INSERT INTO nasa_user(uuid, full_name, admin, fluid, energy, sodium, protein, carb, fat, packets_per_day, use_last_filter, weight, synchronized, created_date, modified_date)
SELECT uuid_generate_v4() AS uuid, full_name, admin, fluid, energy, sodium, protein, carb, fat, packets_per_day, use_last_filter, weight, true, current_timestamp, current_timestamp 
FROM user_tmp_table ft
WHERE ft.id in (SELECT id from selected);

WITH selected AS (
    SELECT MAX(ft.id) AS id, normalize(ft.full_name) AS full_name
    FROM user_tmp_table ft
    GROUP BY normalize(ft.full_name) ORDER BY id asc
)
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
FROM (SELECT up_ft.* FROM user_tmp_table up_ft order by up_ft.id desc) AS f
WHERE f.id in (SELECT id FROM selected) and normalize(f.full_name) = normalize(fp.full_name);

