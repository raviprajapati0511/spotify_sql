/*
===============================================================================
03_business_queries.sql
13 SQL Business Problems: Easy, Medium, and Advanced

Run this after:
1. 01_schema_setup.sql
2. 02_data_cleaning_eda.sql
===============================================================================
*/

-- ============================================================================
-- Easy / Beginner
-- ============================================================================

-- 1. Retrieve all tracks with more than 1,000,000,000 streams.
SELECT
    artist,
    track,
    album,
    stream
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC;

-- 2. List all albums along with their respective total number of tracks.
SELECT
    album,
    COUNT(*) AS total_tracks
FROM spotify
GROUP BY album
ORDER BY total_tracks DESC, album;

-- 3. Find the total number of comments for tracks where official_video = TRUE.
SELECT
    SUM(comments) AS total_official_video_comments
FROM spotify
WHERE official_video = TRUE;

-- 4. Retrieve all tracks that belong to the album type single.
SELECT
    artist,
    track,
    album,
    album_type
FROM spotify
WHERE album_type = 'single'
ORDER BY artist, track;

-- 5. Count the total number of tracks by each artist.
SELECT
    artist,
    COUNT(*) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY total_tracks DESC, artist;

-- ============================================================================
-- Medium / Intermediate
-- ============================================================================

-- 6. Calculate the average danceability of tracks in each album.
SELECT
    album,
    ROUND(CAST(AVG(danceability) AS DECIMAL(10, 4)), 4) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

-- 7. Find the top 5 tracks with the highest energy values.
-- Energy is stored as FLOAT, but CAST keeps the pattern safe for imported
-- datasets where the column may arrive from staging as a numeric-compatible type.
SELECT
    artist,
    track,
    album,
    CAST(energy AS DECIMAL(10, 6)) AS energy_numeric
FROM spotify
WHERE energy IS NOT NULL
ORDER BY energy_numeric DESC, stream DESC
LIMIT 5;

-- 8. List all tracks with total views and likes where official_video = TRUE.
-- Grouping handles duplicate uploads or repeated track rows across channels.
SELECT
    track,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY total_views DESC;

-- 9. For each album, calculate the total views of all associated tracks.
SELECT
    album,
    SUM(views) AS total_album_views
FROM spotify
GROUP BY album
ORDER BY total_album_views DESC;

-- 10. Retrieve track names that have been streamed more on Spotify than played
-- on YouTube. The comparison uses aggregate streams vs. aggregate views.
SELECT
    track,
    SUM(stream) AS total_spotify_streams,
    SUM(views) AS total_youtube_views
FROM spotify
GROUP BY track
HAVING SUM(stream) > SUM(views)
ORDER BY total_spotify_streams DESC;

-- ============================================================================
-- Advanced
-- ============================================================================

-- 11. Find the top 3 most-streamed tracks for each artist using DENSE_RANK().
-- DENSE_RANK keeps ties in the same rank without leaving gaps.
WITH ranked_tracks AS (
    SELECT
        artist,
        track,
        album,
        stream,
        DENSE_RANK() OVER (
            PARTITION BY artist
            ORDER BY stream DESC
        ) AS stream_rank
    FROM spotify
)
SELECT
    artist,
    track,
    album,
    stream,
    stream_rank
FROM ranked_tracks
WHERE stream_rank <= 3
ORDER BY artist, stream_rank, track;

-- 12. Find tracks where the liveness score is higher than the dataset average.
SELECT
    artist,
    track,
    album,
    liveness
FROM spotify
WHERE liveness > (
    SELECT AVG(liveness)
    FROM spotify
)
ORDER BY liveness DESC;

-- 13. Use a CTE to calculate the difference between the highest and lowest
-- energy values for tracks in each album.
WITH album_energy_range AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY album
)
SELECT
    album,
    highest_energy,
    lowest_energy,
    highest_energy - lowest_energy AS energy_difference
FROM album_energy_range
ORDER BY energy_difference DESC, album;
