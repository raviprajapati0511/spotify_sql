/*
===============================================================================
05_import_kaggle_dataset.sql
Import the real Kaggle Spotify + YouTube dataset into the project table.

Source file expected in this project folder:
    spotify_youtube.csv

Run this after 01_schema_setup.sql and before 02_data_cleaning_eda.sql.

This script uses a staging table because the Kaggle CSV contains extra columns
that are not part of the final analytics table:
Url_spotify, Uri, Key, Duration_ms, Url_youtube, Description, and an index column.
===============================================================================
*/

DROP TABLE IF EXISTS spotify_kaggle_staging;

CREATE TABLE spotify_kaggle_staging (
    source_index TEXT,
    artist TEXT,
    url_spotify TEXT,
    track TEXT,
    album TEXT,
    album_type TEXT,
    uri TEXT,
    danceability TEXT,
    energy TEXT,
    musical_key TEXT,
    loudness TEXT,
    speechiness TEXT,
    acousticness TEXT,
    instrumentalness TEXT,
    liveness TEXT,
    valence TEXT,
    tempo TEXT,
    duration_ms TEXT,
    url_youtube TEXT,
    title TEXT,
    channel TEXT,
    views TEXT,
    likes TEXT,
    comments TEXT,
    description TEXT,
    licensed TEXT,
    official_video TEXT,
    stream TEXT
);

COPY spotify_kaggle_staging (
    source_index,
    artist,
    url_spotify,
    track,
    album,
    album_type,
    uri,
    danceability,
    energy,
    musical_key,
    loudness,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    duration_ms,
    url_youtube,
    title,
    channel,
    views,
    likes,
    comments,
    description,
    licensed,
    official_video,
    stream
)
FROM '/project/spotify_youtube.csv'
WITH (FORMAT csv, HEADER true, QUOTE '"', ESCAPE '"');

-- Replace the built-in demo rows with the real Kaggle data.
TRUNCATE TABLE spotify RESTART IDENTITY;

WITH typed_rows AS (
    SELECT
        NULLIF(TRIM(artist), '') AS artist,
        NULLIF(TRIM(track), '') AS track,
        NULLIF(TRIM(album), '') AS album,
        CASE
            WHEN LOWER(NULLIF(TRIM(album_type), '')) IN ('album', 'single', 'compilation')
                THEN LOWER(NULLIF(TRIM(album_type), ''))
            ELSE NULL
        END AS album_type,
        NULLIF(TRIM(danceability), '')::DOUBLE PRECISION AS danceability,
        NULLIF(TRIM(energy), '')::DOUBLE PRECISION AS energy,
        NULLIF(TRIM(loudness), '')::DOUBLE PRECISION AS loudness,
        NULLIF(TRIM(speechiness), '')::DOUBLE PRECISION AS speechiness,
        NULLIF(TRIM(acousticness), '')::DOUBLE PRECISION AS acousticness,
        NULLIF(TRIM(instrumentalness), '')::DOUBLE PRECISION AS instrumentalness,
        NULLIF(TRIM(liveness), '')::DOUBLE PRECISION AS liveness,
        NULLIF(TRIM(valence), '')::DOUBLE PRECISION AS valence,
        NULLIF(TRIM(tempo), '')::DOUBLE PRECISION AS tempo,
        NULLIF(TRIM(duration_ms), '')::DOUBLE PRECISION / 60000.0 AS duration_min,
        NULLIF(TRIM(title), '') AS title,
        NULLIF(TRIM(channel), '') AS channel,
        CAST(NULLIF(TRIM(views), '')::DOUBLE PRECISION AS BIGINT) AS views,
        CAST(NULLIF(TRIM(likes), '')::DOUBLE PRECISION AS BIGINT) AS likes,
        CAST(NULLIF(TRIM(comments), '')::DOUBLE PRECISION AS BIGINT) AS comments,
        NULLIF(TRIM(licensed), '')::BOOLEAN AS licensed,
        NULLIF(TRIM(official_video), '')::BOOLEAN AS official_video,
        CAST(NULLIF(TRIM(stream), '')::DOUBLE PRECISION AS BIGINT) AS stream
    FROM spotify_kaggle_staging
),
final_rows AS (
    SELECT
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
        CASE
            WHEN energy IS NOT NULL AND liveness IS NOT NULL THEN energy * liveness
            ELSE NULL
        END AS energy_liveness,
        CASE
            WHEN stream IS NOT NULL AND views IS NOT NULL AND stream >= views THEN 'Spotify'
            WHEN stream IS NOT NULL AND views IS NOT NULL AND stream < views THEN 'Youtube'
            WHEN stream IS NOT NULL AND views IS NULL THEN 'Spotify'
            WHEN stream IS NULL AND views IS NOT NULL THEN 'Youtube'
            ELSE NULL
        END AS most_playedon
    FROM typed_rows
)
INSERT INTO spotify (
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
SELECT
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
FROM final_rows;

SELECT
    COUNT(*) AS imported_rows
FROM spotify;

SELECT
    COUNT(*) AS staging_rows
FROM spotify_kaggle_staging;
