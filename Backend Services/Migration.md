# Instructions

1- Backup the database

```bash
$ pg_dump -h $IP -p 56283 -U pl_fit_db -W -Fc -f pl_fit.bak pl_fit 
```

2- Copy database files to `/tmp`

$ cp "NTL-ISS-Food-Intake-Tracker-master/Backend Services/issfit-api/database"/* /tmp

3- Create new Database

```bash
$ sudo su - postgres
$ createdb pl_fit_new
$ psql -d pl_fit_new -f /tmp/database_schema.sql
$ psql -d pl_fit_new -f /tmp/static_data.sql
$ psql -d pl_fit_new

pl_fit_new=# DROP INDEX public.food_product_name_origin_idx;
pl_fit_new=# \q

$ exit
```

4- Execute migration script

Change the **host**, **port** and **password** to match test and production environments (the example below if for Topcoder's VM).

```bash
$ cd "NTL-ISS-Food-Intake-Tracker-master/Backend Services"
$ ./db_migration.py --database=pl_fit --host=172.31.29.196 --port=56283 --user=pl_fit_db --password=CHANGEME
```

5- Rename databases

```bash
$ sudo su - postgres
$ psql -d pl_fit

pl_fit=# ALTER DATABASE pl_fit RENAME TO pl_fit_old;
pl_fit=# \q

$ psql -d pl_fit_new

pl_fit_new=# ALTER DATABASE pl_fit_new RENAME TO pl_fit;
pl_fit_new=# \q
```
