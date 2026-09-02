# Advanced SQL Project: Spotify & YouTube Dataset Analysis

This project is a complete, runnable SQL analysis workflow for a Spotify and YouTube music dataset. It includes schema creation, sample data ingestion, data cleaning, exploratory analysis, business queries, and query optimization.

## Files

Run the files in this order:

1. `01_schema_setup.sql`
2. `02_data_cleaning_eda.sql`
3. `03_business_queries.sql`
4. `04_query_optimization.sql`

## Database Target

The scripts target PostgreSQL 12+.

Most queries are also compatible with MySQL 8+, but these PostgreSQL-specific details may need adjustment:

- `BIGINT GENERATED ALWAYS AS IDENTITY` can be replaced with `BIGINT AUTO_INCREMENT`.
- `DELETE ... USING` can be rewritten as a MySQL `DELETE` with a joined derived table.
- `pg_indexes` is PostgreSQL-specific metadata.

## Dataset Details

The `spotify` table models tracks with Spotify audio attributes, YouTube engagement metrics, licensing fields, and platform popularity indicators.

The project uses a structured tabular dataset where each row represents one music track and its related Spotify and YouTube metrics.

## Data Structure

The dataset is stored in one main table named `spotify`.

Column groups:

- `artist`, `track`, `album`, `album_type`
- `danceability`, `energy`, `loudness`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `valence`, `tempo`, `duration_min`
- `title`, `channel`
- `views`, `likes`, `comments`
- `licensed`, `official_video`
- `stream`, `energy_liveness`, `most_playedon`

The setup script also adds a surrogate primary key, `spotify_id`, so duplicate source rows can be loaded and cleaned safely.

Expected CSV column order:

```csv
artist,track,album,album_type,danceability,energy,loudness,speechiness,acousticness,instrumentalness,liveness,valence,tempo,duration_min,title,channel,views,likes,comments,licensed,official_video,stream,energy_liveness,most_playedon
```

Example rows:

```csv
artist,track,album,album_type,danceability,energy,loudness,speechiness,acousticness,instrumentalness,liveness,valence,tempo,duration_min,title,channel,views,likes,comments,licensed,official_video,stream,energy_liveness,most_playedon
The Weeknd,Blinding Lights,After Hours,album,0.514,0.730,-5.934,0.0598,0.00146,0.000095,0.0897,0.334,171.005,3.33,The Weeknd - Blinding Lights,TheWeekndVEVO,760000000,9500000,420000,true,true,3900000000,0.065481,Spotify
Dua Lipa,Levitating,Future Nostalgia,album,0.702,0.825,-3.787,0.0601,0.00883,0.000000,0.0674,0.915,102.977,3.38,Dua Lipa - Levitating,Dua Lipa,900000000,7800000,250000,true,true,1800000000,0.055605,Spotify
Ed Sheeran,Shape of You,Divide,album,0.825,0.652,-3.183,0.0802,0.5810,0.000000,0.0931,0.931,95.977,3.89,Ed Sheeran - Shape of You,Ed Sheeran,6100000000,32000000,1200000,true,true,3600000000,0.060701,Youtube
Billie Eilish,Lovely,Lovely,single,0.351,0.296,-10.109,0.0333,0.9340,0.000000,0.0950,0.120,115.284,3.34,"Billie Eilish, Khalid - lovely",BillieEilishVEVO,2000000000,18000000,550000,true,true,2200000000,0.028120,Spotify
```

Data type examples:

- Text values use `VARCHAR`, for example `artist = 'The Weeknd'` and `album_type = 'album'`.
- Large count values use `BIGINT`, for example `views = 6100000000` and `stream = 3900000000`.
- Audio features use `FLOAT`, for example `danceability = 0.514` and `tempo = 171.005`.
- True/false fields use `BOOLEAN`, for example `licensed = true` and `official_video = true`.

## Schema Design

`01_schema_setup.sql` creates one table named `spotify` with:

- `VARCHAR` columns for text fields.
- `BIGINT` columns for large count metrics such as views, likes, comments, and streams.
- `FLOAT` columns for audio features and calculated measures.
- `BOOLEAN` columns for license and official-video flags.
- A primary key on `spotify_id`.
- Check constraints for album type, audio feature ranges, non-negative counts, non-negative duration, and platform values.

## Sample Data

The setup script inserts a small representative dataset with popular artists and tracks. It intentionally includes:

- A duplicate row.
- A zero-duration track.
- A row with a missing artist.

These records are included so the cleaning script can demonstrate realistic data quality handling.

## Setup Instructions

Create a PostgreSQL database:

```bash
createdb spotify_sql_project
```

Run the project scripts:

```bash
psql -d spotify_sql_project -f 01_schema_setup.sql
psql -d spotify_sql_project -f 02_data_cleaning_eda.sql
psql -d spotify_sql_project -f 03_business_queries.sql
psql -d spotify_sql_project -f 04_query_optimization.sql
```

You can also run each file manually in pgAdmin, DBeaver, DataGrip, or another SQL client.

## Business Questions Covered

This project covers cleaning, EDA, aggregation, filtering, sorting, grouping, CTEs, window functions, and performance optimization.

Easy / Beginner questions:

1. Tracks with more than 1 billion streams.
2. Albums and their total number of tracks.
3. Total comments for official videos.
4. Tracks released as singles.
5. Total tracks by each artist.

SQL concepts covered: `SELECT`, `WHERE`, `ORDER BY`, `COUNT`, `SUM`, `GROUP BY`, and boolean filtering.

Medium / Intermediate questions:

6. Average danceability by album.
7. Top 5 tracks by energy.
8. Total views and likes for official videos by track.
9. Total views by album.
10. Tracks streamed more on Spotify than played on YouTube.

SQL concepts covered: `AVG`, `CAST`, `ROUND`, `LIMIT`, aggregate comparisons, grouped calculations, and `HAVING`.

Advanced questions:

11. Top 3 most-streamed tracks for each artist using `DENSE_RANK()`.
12. Tracks with liveness above the dataset average.
13. Album-level energy range using a CTE.

SQL concepts covered: common table expressions, subqueries, `DENSE_RANK()`, `PARTITION BY`, ranking logic, `MAX`, `MIN`, and derived metrics.

EDA questions included in `02_data_cleaning_eda.sql`:

- How many valid track rows are in the dataset?
- How many unique tracks are available?
- How many unique artists are represented?
- What album types exist in the dataset?
- How many YouTube channels are represented?
- What is the distribution of tracks by album type?
- Which artists have the highest total Spotify streams?
- What are the minimum, maximum, and average values for streams and views?

Data cleaning operations covered:

- Finding rows with `NULL` values.
- Removing rows with missing analytic fields.
- Removing zero-duration tracks.
- Trimming text fields.
- Normalizing album type and platform names.
- Removing duplicate rows with `ROW_NUMBER()`.
- Recalculating `energy_liveness` when needed.

## Query Optimization

`04_query_optimization.sql` demonstrates performance tuning with `EXPLAIN ANALYZE`.

It creates indexes on high-frequency filtering and grouping columns:

- `artist`
- `track`
- `album`
- `album_type`
- `(official_video, track)`
- `(artist, stream DESC)`
- `most_playedon`

For a very small sample dataset, PostgreSQL may still choose sequential scans because reading the whole table can be cheaper than using an index. With larger real datasets, the indexed plans should become more useful.

## Loading a Larger CSV Dataset

If you have a real CSV file with the same columns, create the table with `01_schema_setup.sql`, then load data before running the cleaning script.

Example PostgreSQL import:

```sql
\copy spotify (
    artist,
    track,
    album,
    album_type,
    danceability,
    energy,
    loudness,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    duration_min,
    title,
    channel,
    views,
    likes,
    comments,
    licensed,
    official_video,
    stream,
    energy_liveness,
    most_playedon
)
FROM 'spotify_youtube.csv'
WITH (FORMAT csv, HEADER true);
```

After importing, run:

```bash
psql -d spotify_sql_project -f 02_data_cleaning_eda.sql
psql -d spotify_sql_project -f 03_business_queries.sql
psql -d spotify_sql_project -f 04_query_optimization.sql
```
