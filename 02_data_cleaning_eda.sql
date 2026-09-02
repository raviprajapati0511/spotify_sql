/*
===============================================================================
02_data_cleaning_eda.sql
Data Cleaning and Exploratory Data Analysis

Run this after 01_schema_setup.sql.
===============================================================================
*/

-- 1. Inspect rows with NULL values before cleaning.
SELECT *
FROM spotify
WHERE artist IS NULL
   OR track IS NULL
   OR album IS NULL
   OR album_type IS NULL
   OR danceability IS NULL
   OR energy IS NULL
   OR loudness IS NULL
   OR speechiness IS NULL
   OR acousticness IS NULL
   OR instrumentalness IS NULL
   OR liveness IS NULL
   OR valence IS NULL
   OR tempo IS NULL
   OR duration_min IS NULL
   OR title IS NULL
   OR channel IS NULL
   OR views IS NULL
   OR likes IS NULL
   OR comments IS NULL
   OR licensed IS NULL
   OR official_video IS NULL
   OR stream IS NULL
   OR energy_liveness IS NULL
   OR most_playedon IS NULL;

-- 2. Remove rows with missing analytic values.
DELETE FROM spotify
WHERE artist IS NULL
   OR track IS NULL
   OR album IS NULL
   OR album_type IS NULL
   OR danceability IS NULL
   OR energy IS NULL
   OR loudness IS NULL
   OR speechiness IS NULL
   OR acousticness IS NULL
   OR instrumentalness IS NULL
   OR liveness IS NULL
   OR valence IS NULL
   OR tempo IS NULL
   OR duration_min IS NULL
   OR title IS NULL
   OR channel IS NULL
   OR views IS NULL
   OR likes IS NULL
   OR comments IS NULL
   OR licensed IS NULL
   OR official_video IS NULL
   OR stream IS NULL
   OR energy_liveness IS NULL
   OR most_playedon IS NULL;

-- 3. Remove zero-duration tracks because they cannot represent valid audio plays.
DELETE FROM spotify
WHERE duration_min = 0;

-- 4. Normalize common text fields to avoid grouping differences from whitespace.
UPDATE spotify
SET
    artist = TRIM(artist),
    track = TRIM(track),
    album = TRIM(album),
    album_type = LOWER(TRIM(album_type)),
    title = TRIM(title),
    channel = TRIM(channel),
    most_playedon = CASE
        WHEN LOWER(TRIM(most_playedon)) = 'youtube' THEN 'Youtube'
        WHEN LOWER(TRIM(most_playedon)) = 'spotify' THEN 'Spotify'
        ELSE TRIM(most_playedon)
    END;

-- 5. Remove duplicate rows while keeping the earliest inserted spotify_id.
-- The surrogate primary key is intentionally excluded from the duplicate match.
WITH duplicate_rows AS (
    SELECT
        spotify_id,
        ROW_NUMBER() OVER (
            PARTITION BY
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
            ORDER BY spotify_id
        ) AS row_number_in_group
    FROM spotify
)
DELETE FROM spotify s
USING duplicate_rows d
WHERE s.spotify_id = d.spotify_id
  AND d.row_number_in_group > 1;

-- 6. Recalculate energy_liveness if it is missing or stale.
UPDATE spotify
SET energy_liveness = energy * liveness
WHERE energy IS NOT NULL
  AND liveness IS NOT NULL
  AND (
      energy_liveness IS NULL
      OR ABS(energy_liveness - (energy * liveness)) > 0.000001
  );

-- =========================
-- Exploratory Data Analysis
-- =========================

-- Total valid track rows.
SELECT COUNT(*) AS total_track_rows
FROM spotify;

-- Total distinct tracks.
SELECT COUNT(DISTINCT track) AS total_unique_tracks
FROM spotify;

-- Total artists.
SELECT COUNT(DISTINCT artist) AS total_artists
FROM spotify;

-- Unique album types.
SELECT DISTINCT album_type
FROM spotify
ORDER BY album_type;

-- Unique YouTube channels represented in the dataset.
SELECT COUNT(DISTINCT channel) AS total_channels
FROM spotify;

-- Album type distribution.
SELECT
    album_type,
    COUNT(*) AS track_count
FROM spotify
GROUP BY album_type
ORDER BY track_count DESC, album_type;

-- Top artists by total Spotify streams.
SELECT
    artist,
    SUM(stream) AS total_streams
FROM spotify
GROUP BY artist
ORDER BY total_streams DESC;

-- Summary statistics for core popularity metrics.
SELECT
    MIN(stream) AS min_streams,
    MAX(stream) AS max_streams,
    AVG(stream) AS avg_streams,
    MIN(views) AS min_views,
    MAX(views) AS max_views,
    AVG(views) AS avg_views
FROM spotify;
