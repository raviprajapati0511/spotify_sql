/*
===============================================================================
04_query_optimization.sql
Query Optimization and Indexing

Run this after loading and cleaning the dataset.
Primary target: PostgreSQL 12+

Tip: Run each EXPLAIN ANALYZE block before and after index creation to compare:
- execution time
- scan type, such as Seq Scan vs. Index Scan / Bitmap Index Scan
- rows filtered
===============================================================================
*/

-- ============================================================================
-- Baseline query plans before adding indexes
-- ============================================================================

EXPLAIN ANALYZE
SELECT
    artist,
    track,
    album,
    stream
FROM spotify
WHERE artist = 'The Weeknd'
  AND stream > 1000000000
ORDER BY stream DESC;

EXPLAIN ANALYZE
SELECT
    album,
    COUNT(*) AS total_tracks
FROM spotify
WHERE album_type = 'album'
GROUP BY album
ORDER BY total_tracks DESC;

EXPLAIN ANALYZE
SELECT
    track,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY total_views DESC;

EXPLAIN ANALYZE
SELECT
    artist,
    track,
    stream,
    DENSE_RANK() OVER (
        PARTITION BY artist
        ORDER BY stream DESC
    ) AS stream_rank
FROM spotify;

-- ============================================================================
-- Index creation
-- ============================================================================

-- Speeds equality filtering and grouping by artist.
CREATE INDEX IF NOT EXISTS idx_spotify_artist
ON spotify (artist);

-- Speeds track-level grouping and duplicate / lookup workflows.
CREATE INDEX IF NOT EXISTS idx_spotify_track
ON spotify (track);

-- Speeds album-level grouping and album-specific analysis.
CREATE INDEX IF NOT EXISTS idx_spotify_album
ON spotify (album);

-- Speeds common filters by album type.
CREATE INDEX IF NOT EXISTS idx_spotify_album_type
ON spotify (album_type);

-- Helps queries that filter official videos and then group by track.
CREATE INDEX IF NOT EXISTS idx_spotify_official_video_track
ON spotify (official_video, track);

-- Helps top-stream queries and window functions partitioned by artist.
CREATE INDEX IF NOT EXISTS idx_spotify_artist_stream_desc
ON spotify (artist, stream DESC);

-- Helps comparisons and ordering by platform dominance.
CREATE INDEX IF NOT EXISTS idx_spotify_most_playedon
ON spotify (most_playedon);

-- PostgreSQL-specific: update planner statistics after adding indexes.
ANALYZE spotify;

-- ============================================================================
-- Query plans after indexes
-- ============================================================================

EXPLAIN ANALYZE
SELECT
    artist,
    track,
    album,
    stream
FROM spotify
WHERE artist = 'The Weeknd'
  AND stream > 1000000000
ORDER BY stream DESC;

EXPLAIN ANALYZE
SELECT
    album,
    COUNT(*) AS total_tracks
FROM spotify
WHERE album_type = 'album'
GROUP BY album
ORDER BY total_tracks DESC;

EXPLAIN ANALYZE
SELECT
    track,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY total_views DESC;

EXPLAIN ANALYZE
SELECT
    artist,
    track,
    stream,
    DENSE_RANK() OVER (
        PARTITION BY artist
        ORDER BY stream DESC
    ) AS stream_rank
FROM spotify;

-- ============================================================================
-- Optional validation: inspect created indexes
-- ============================================================================

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'spotify'
ORDER BY indexname;
