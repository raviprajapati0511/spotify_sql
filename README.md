# Advanced SQL Project: Spotify & YouTube Dataset Analysis

This is a complete SQL portfolio project built around a real Spotify and YouTube music dataset. The project creates a PostgreSQL database table, imports the Kaggle CSV dataset, cleans the data, performs exploratory data analysis, answers business questions, and demonstrates query optimization with indexes and `EXPLAIN ANALYZE`.

The project is designed to run end-to-end from this folder:

```text
C:\Users\rajma\OneDrive\Desktop\spotify_sql
```

## Project Goal

The goal of this project is to analyze music performance across Spotify and YouTube using SQL.

The analysis answers questions such as:

- Which tracks have more than 1 billion Spotify streams?
- Which artists and albums have the most tracks?
- How do YouTube views, likes, and comments compare for official videos?
- Which tracks perform better on Spotify than YouTube?
- What are the top 3 most-streamed tracks for every artist?
- Which tracks have above-average liveness?
- How can indexes improve query performance?

## Dataset Source

The real dataset used in this project is from Kaggle:

```text
Spotify and Youtube by Salvatore Rastelli
```

Dataset URL:

```text
https://www.kaggle.com/datasets/salvatorerastelli/spotify-and-youtube
```

Local CSV file used by this project:

```text
spotify_youtube.csv
```

The CSV file should be placed here:

```text
C:\Users\rajma\OneDrive\Desktop\spotify_sql\spotify_youtube.csv
```

How to get the dataset:

1. Open https://www.kaggle.com/datasets/salvatorerastelli/spotify-and-youtube
2. Sign in to Kaggle.
3. Click `Download`.
4. Extract the downloaded ZIP file.
5. Copy the CSV file into this project folder.
6. Rename the file to `spotify_youtube.csv` if the name is different.

## Prerequisites

Recommended setup:

- Docker Desktop
- PostgreSQL Docker image `postgres:16`
- PowerShell
- The downloaded Kaggle CSV file named `spotify_youtube.csv`

Alternative setup:

- Local PostgreSQL 12+
- `psql` command-line tool
- The downloaded Kaggle CSV file named `spotify_youtube.csv`

## Project Files

Run the SQL files in this order:

1. `01_schema_setup.sql`
2. `05_import_kaggle_dataset.sql`
3. `02_data_cleaning_eda.sql`
4. `03_business_queries.sql`
5. `04_query_optimization.sql`

File purpose:

| File | Purpose |
| --- | --- |
| `01_schema_setup.sql` | Drops and recreates the final `spotify` table, adds constraints, and inserts small demo rows. |
| `05_import_kaggle_dataset.sql` | Creates a staging table, imports `spotify_youtube.csv`, transforms columns, and loads real data into `spotify`. |
| `02_data_cleaning_eda.sql` | Cleans NULL rows, removes zero-duration tracks, trims text, removes duplicates, recalculates `energy_liveness`, and runs EDA queries. |
| `03_business_queries.sql` | Contains 13 Easy, Medium, and Advanced SQL business questions. |
| `04_query_optimization.sql` | Runs `EXPLAIN ANALYZE`, creates indexes, runs `ANALYZE`, and compares query plans. |
| `spotify_youtube.csv` | Real Kaggle dataset file. This file is large and is imported through the staging script. |

## Database Used

Primary database:

```text
PostgreSQL 12+
```

The project has been tested using PostgreSQL inside Docker.

Current Docker database details:

```text
Container: spotify_sql_postgres
Host: localhost
Port: 5432
Database: spotify_sql_project
Username: postgres
Password: postgres
```

## Dataset Structure

The original Kaggle CSV contains extra columns that are useful in the raw dataset but not needed in the final SQL analysis table.

Raw Kaggle CSV header:

```csv
,Artist,Url_spotify,Track,Album,Album_type,Uri,Danceability,Energy,Key,Loudness,Speechiness,Acousticness,Instrumentalness,Liveness,Valence,Tempo,Duration_ms,Url_youtube,Title,Channel,Views,Likes,Comments,Description,Licensed,official_video,Stream
```

The project imports this raw file into a staging table named:

```text
spotify_kaggle_staging
```

Then it transforms the data into the final table:

```text
spotify
```

Final table columns:

```csv
spotify_id,artist,track,album,album_type,danceability,energy,loudness,speechiness,acousticness,instrumentalness,liveness,valence,tempo,duration_min,title,channel,views,likes,comments,licensed,official_video,stream,energy_liveness,most_playedon
```

## Final Table Schema

| Column | Type | Meaning |
| --- | --- | --- |
| `spotify_id` | `BIGINT` | Auto-generated primary key. |
| `artist` | `VARCHAR(255)` | Artist name. |
| `track` | `VARCHAR(255)` | Track or song name. |
| `album` | `VARCHAR(255)` | Album name. |
| `album_type` | `VARCHAR(50)` | Album category such as `album`, `single`, or `compilation`. |
| `danceability` | `FLOAT` | Spotify audio score from 0 to 1. |
| `energy` | `FLOAT` | Spotify audio energy score from 0 to 1. |
| `loudness` | `FLOAT` | Loudness value in decibels. |
| `speechiness` | `FLOAT` | Spotify speechiness score from 0 to 1. |
| `acousticness` | `FLOAT` | Spotify acousticness score from 0 to 1. |
| `instrumentalness` | `FLOAT` | Spotify instrumentalness score from 0 to 1. |
| `liveness` | `FLOAT` | Spotify liveness score from 0 to 1. |
| `valence` | `FLOAT` | Musical positivity score from 0 to 1. |
| `tempo` | `FLOAT` | Track tempo in beats per minute. |
| `duration_min` | `FLOAT` | Track duration in minutes, converted from `Duration_ms`. |
| `title` | `VARCHAR(255)` | YouTube video title. |
| `channel` | `VARCHAR(255)` | YouTube channel name. |
| `views` | `BIGINT` | YouTube view count. |
| `likes` | `BIGINT` | YouTube like count. |
| `comments` | `BIGINT` | YouTube comment count. |
| `licensed` | `BOOLEAN` | Whether the YouTube video is licensed. |
| `official_video` | `BOOLEAN` | Whether the YouTube video is official. |
| `stream` | `BIGINT` | Spotify stream count. |
| `energy_liveness` | `FLOAT` | Calculated value: `energy * liveness`. |
| `most_playedon` | `VARCHAR(50)` | Calculated platform label: `Spotify` or `Youtube`. |

## Example Final Data

Example rows after transformation:

```csv
artist,track,album,album_type,danceability,energy,loudness,speechiness,acousticness,instrumentalness,liveness,valence,tempo,duration_min,title,channel,views,likes,comments,licensed,official_video,stream,energy_liveness,most_playedon
The Weeknd,Blinding Lights,After Hours,album,0.514,0.730,-5.934,0.0598,0.00146,0.000095,0.0897,0.334,171.005,3.33,The Weeknd - Blinding Lights,TheWeekndVEVO,760000000,9500000,420000,true,true,3900000000,0.065481,Spotify
Dua Lipa,Levitating,Future Nostalgia,album,0.702,0.825,-3.787,0.0601,0.00883,0.000000,0.0674,0.915,102.977,3.38,Dua Lipa - Levitating,Dua Lipa,900000000,7800000,250000,true,true,1800000000,0.055605,Spotify
Ed Sheeran,Shape of You,Divide,album,0.825,0.652,-3.183,0.0802,0.5810,0.000000,0.0931,0.931,95.977,3.89,Ed Sheeran - Shape of You,Ed Sheeran,6100000000,32000000,1200000,true,true,3600000000,0.060701,Youtube
```

## Data Transformation

`05_import_kaggle_dataset.sql` performs these transformations:

- Loads the Kaggle CSV into `spotify_kaggle_staging`.
- Removes unused raw fields such as URLs, URI, description, and musical key.
- Converts text values into final SQL data types.
- Converts `Duration_ms` into `duration_min`.
- Calculates `energy_liveness` as `energy * liveness`.
- Calculates `most_playedon` by comparing Spotify streams against YouTube views.
- Replaces demo rows from `01_schema_setup.sql` with real Kaggle rows.

## Data Cleaning

`02_data_cleaning_eda.sql` performs these cleaning steps:

- Counts rows with missing values.
- Shows a small sample of rows with NULL values.
- Removes rows with missing analytic fields.
- Removes zero-duration tracks.
- Trims whitespace from text columns.
- Normalizes `album_type` to lowercase.
- Normalizes platform names to `Spotify` or `Youtube`.
- Removes duplicate rows using `ROW_NUMBER()`.
- Recalculates `energy_liveness` if needed.

In the latest real-data run:

```text
Imported rows: 20,718
Rows removed during cleaning: 1,169
Final clean rows: 19,549
```

## EDA Covered

The EDA section answers:

- How many valid rows are in the dataset?
- How many unique tracks are available?
- How many artists are represented?
- What album types exist?
- How many YouTube channels are represented?
- What is the distribution of tracks by album type?
- Which artists have the highest total Spotify streams?
- What are the minimum, maximum, and average values for streams and views?

Latest cleaned dataset summary:

```text
Clean rows: 19,549
Artists: 2,040
Tracks: 16,866
Albums: 11,381
Album rows: 14,148
Single rows: 4,689
Compilation rows: 712
Indexes created: 8
```

## Business Questions Covered

`03_business_queries.sql` contains 13 SQL business problems.

Easy / Beginner:

1. Retrieve all tracks with more than 1,000,000,000 streams.
2. List all albums along with their respective total number of tracks.
3. Find the total number of comments for tracks where `official_video = TRUE`.
4. Retrieve all tracks that belong to the album type `single`.
5. Count the total number of tracks by each artist.

Medium / Intermediate:

6. Calculate the average danceability of tracks in each album.
7. Find the top 5 tracks with the highest energy values.
8. List all tracks with their total views and likes where `official_video = TRUE`.
9. For each album, calculate the total views of all associated tracks.
10. Retrieve track names that have been streamed more on Spotify than played on YouTube.

Advanced:

11. Find the top 3 most-streamed tracks for each artist using `DENSE_RANK()`.
12. Find tracks where the liveness score is higher than the average liveness score of all tracks.
13. Use a CTE to calculate the difference between the highest and lowest energy values for tracks in each album.

SQL concepts covered:

- `SELECT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `HAVING`
- `COUNT`
- `SUM`
- `AVG`
- `MIN`
- `MAX`
- `CAST`
- `ROUND`
- `LIMIT`
- Subqueries
- Common table expressions
- Window functions
- `DENSE_RANK()`
- `PARTITION BY`

## Query Optimization Covered

`04_query_optimization.sql` demonstrates:

- Baseline query performance with `EXPLAIN ANALYZE`.
- Index creation on high-frequency columns.
- Planner statistics refresh with `ANALYZE`.
- Post-index query plan comparison.

Indexes created:

| Index | Column(s) | Purpose |
| --- | --- | --- |
| `idx_spotify_artist` | `artist` | Speeds artist filtering and grouping. |
| `idx_spotify_track` | `track` | Speeds track grouping and lookup. |
| `idx_spotify_album` | `album` | Speeds album-level aggregation. |
| `idx_spotify_album_type` | `album_type` | Speeds album type filtering. |
| `idx_spotify_official_video_track` | `official_video, track` | Speeds official-video grouped queries. |
| `idx_spotify_artist_stream_desc` | `artist, stream DESC` | Speeds top streamed tracks per artist. |
| `idx_spotify_most_playedon` | `most_playedon` | Speeds platform-based filtering. |
| `spotify_pkey` | `spotify_id` | Primary key index. |

## How to Run With Docker

Docker is the easiest way to run this project because PostgreSQL does not need to be installed directly on Windows.

Start Docker Desktop first.

From PowerShell, go to the project folder:

```powershell
cd C:\Users\rajma\OneDrive\Desktop\spotify_sql
```

If the container already exists, start it:

```powershell
docker start spotify_sql_postgres
```

If the container does not exist, create it:

```powershell
docker run --name spotify_sql_postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=spotify_sql_project -p 5432:5432 -v "${PWD}:/project" -d postgres:16
```

Check that PostgreSQL is ready:

```powershell
docker exec spotify_sql_postgres pg_isready -U postgres -d spotify_sql_project
```

Run the full project:

```powershell
docker exec spotify_sql_postgres psql -U postgres -d spotify_sql_project -v ON_ERROR_STOP=1 -f /project/01_schema_setup.sql
docker exec spotify_sql_postgres psql -U postgres -d spotify_sql_project -v ON_ERROR_STOP=1 -f /project/05_import_kaggle_dataset.sql
docker exec spotify_sql_postgres psql -U postgres -d spotify_sql_project -v ON_ERROR_STOP=1 -f /project/02_data_cleaning_eda.sql
docker exec spotify_sql_postgres psql -U postgres -d spotify_sql_project -v ON_ERROR_STOP=1 -f /project/03_business_queries.sql
docker exec spotify_sql_postgres psql -U postgres -d spotify_sql_project -v ON_ERROR_STOP=1 -f /project/04_query_optimization.sql
```

Open the database shell:

```powershell
docker exec -it spotify_sql_postgres psql -U postgres -d spotify_sql_project
```

Stop the container when finished:

```powershell
docker stop spotify_sql_postgres
```

Start it again later:

```powershell
docker start spotify_sql_postgres
```

## How to Run With Local PostgreSQL

If PostgreSQL is installed locally, create a database:

```bash
createdb spotify_sql_project
```

Place `spotify_youtube.csv` in the project folder.

Important: `05_import_kaggle_dataset.sql` uses this Docker path:

```sql
FROM '/project/spotify_youtube.csv'
```

If running locally, change it to your local full path:

```sql
FROM 'C:/Users/rajma/OneDrive/Desktop/spotify_sql/spotify_youtube.csv'
```

Then run:

```bash
psql -d spotify_sql_project -f 01_schema_setup.sql
psql -d spotify_sql_project -f 05_import_kaggle_dataset.sql
psql -d spotify_sql_project -f 02_data_cleaning_eda.sql
psql -d spotify_sql_project -f 03_business_queries.sql
psql -d spotify_sql_project -f 04_query_optimization.sql
```

## Verification Queries

After running all scripts, verify the final table:

```sql
SELECT
    COUNT(*) AS clean_rows,
    COUNT(DISTINCT artist) AS artists,
    COUNT(DISTINCT track) AS tracks,
    COUNT(DISTINCT album) AS albums
FROM spotify;
```

Expected latest result:

```text
clean_rows | artists | tracks | albums
19549      | 2040    | 16866  | 11381
```

Check album type distribution:

```sql
SELECT
    album_type,
    COUNT(*) AS rows
FROM spotify
GROUP BY album_type
ORDER BY rows DESC;
```

Expected latest result:

```text
album_type  | rows
album       | 14148
single      | 4689
compilation | 712
```

Check indexes:

```sql
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'spotify'
ORDER BY indexname;
```

## Notes About Output Size

Some business queries return many rows because the real dataset has thousands of tracks. If you only want a preview, add `LIMIT 20` to the end of large `SELECT` queries while exploring.

Example:

```sql
SELECT
    artist,
    track,
    album,
    stream
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC
LIMIT 20;
```

## Troubleshooting

If Docker says the container is not running:

```powershell
docker start spotify_sql_postgres
```

If Docker says the container already exists:

```powershell
docker start spotify_sql_postgres
```

If you want to recreate the container completely:

```powershell
docker rm -f spotify_sql_postgres
docker run --name spotify_sql_postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=spotify_sql_project -p 5432:5432 -v "${PWD}:/project" -d postgres:16
```

If the import fails because the CSV is missing, confirm this file exists:

```text
C:\Users\rajma\OneDrive\Desktop\spotify_sql\spotify_youtube.csv
```

If local PostgreSQL cannot find the CSV, use the full Windows path in `05_import_kaggle_dataset.sql`.

## Final Project Status

This project has been run successfully end-to-end with the real Kaggle dataset using Docker PostgreSQL.

Latest successful run:

```text
01_schema_setup.sql          OK
05_import_kaggle_dataset.sql OK
02_data_cleaning_eda.sql     OK
03_business_queries.sql      OK
04_query_optimization.sql    OK
```

Final cleaned database:

```text
Rows:    19,549
Artists: 2,040
Tracks:  16,866
Albums:  11,381
Indexes: 8
```
