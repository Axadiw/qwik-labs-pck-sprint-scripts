#!/bin/bash

#SELECT
#FROM
#WHERE

#BIGQUERY
#TRUE
#TRUE

#GROUP BY
#COUNT
#AS
#ORDER BY

PROJECT_NAME=$1
BUCKET_NAME=<fill>

gsutil mb gs://$BUCKET_NAME
bq query -q --headless --use_legacy_sql=true --format csv "SELECT start_station_name, COUNT(*) AS num FROM [bigquery-public-data.london_bicycles.cycle_hire] GROUP BY start_station_name ORDER BY num DESC;" > start_station_data.csv
bq query -q --headless --use_legacy_sql=true --format csv "SELECT end_station_name, COUNT(*) AS num FROM [bigquery-public-data.london_bicycles.cycle_hire] GROUP BY end_station_name ORDER BY num DESC;" > end_station_data.csv

gsutil cp start_station_data.csv gs://$BUCKET_NAME/
gsutil cp end_station_data.csv gs://$BUCKET_NAME/