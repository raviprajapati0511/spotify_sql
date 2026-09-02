/*
===============================================================================
01_schema_setup.sql
Spotify & YouTube Advanced SQL Project

Primary target: PostgreSQL 12+
MySQL 8+ note: replace "GENERATED ALWAYS AS IDENTITY" with
"AUTO_INCREMENT" for the spotify_id column if running in MySQL.

This script creates the spotify table and inserts a small sample dataset that
includes clean rows plus a few intentionally dirty rows for 02_data_cleaning_eda.sql.
===============================================================================
*/

DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify (
    spotify_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),

    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,

    title VARCHAR(255),
    channel VARCHAR(255),
    views BIGINT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_playedon VARCHAR(50),

    CONSTRAINT chk_album_type
        CHECK (
            album_type IS NULL
            OR LOWER(album_type) IN ('album', 'single', 'compilation')
        ),
    CONSTRAINT chk_audio_features_range
        CHECK (
            (danceability IS NULL OR danceability BETWEEN 0 AND 1)
            AND (energy IS NULL OR energy BETWEEN 0 AND 1)
            AND (speechiness IS NULL OR speechiness BETWEEN 0 AND 1)
            AND (acousticness IS NULL OR acousticness BETWEEN 0 AND 1)
            AND (instrumentalness IS NULL OR instrumentalness BETWEEN 0 AND 1)
            AND (liveness IS NULL OR liveness BETWEEN 0 AND 1)
            AND (valence IS NULL OR valence BETWEEN 0 AND 1)
        ),
    CONSTRAINT chk_duration_non_negative
        CHECK (duration_min IS NULL OR duration_min >= 0),
    CONSTRAINT chk_tempo_non_negative
        CHECK (tempo IS NULL OR tempo >= 0),
    CONSTRAINT chk_engagement_non_negative
        CHECK (
            (views IS NULL OR views >= 0)
            AND (likes IS NULL OR likes >= 0)
            AND (comments IS NULL OR comments >= 0)
            AND (stream IS NULL OR stream >= 0)
        ),
    CONSTRAINT chk_most_playedon
        CHECK (
            most_playedon IS NULL
            OR most_playedon IN ('Spotify', 'Youtube', 'YouTube')
        )
);

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
VALUES
('The Weeknd', 'Blinding Lights', 'After Hours', 'album', 0.514, 0.730, -5.934, 0.0598, 0.00146, 0.000095, 0.0897, 0.334, 171.005, 3.33, 'The Weeknd - Blinding Lights', 'TheWeekndVEVO', 760000000, 9500000, 420000, TRUE, TRUE, 3900000000, 0.065481, 'Spotify'),
('The Weeknd', 'Save Your Tears', 'After Hours', 'album', 0.680, 0.826, -5.487, 0.0309, 0.0212, 0.000012, 0.5430, 0.644, 118.051, 3.58, 'The Weeknd - Save Your Tears', 'TheWeekndVEVO', 1200000000, 8800000, 310000, TRUE, TRUE, 2100000000, 0.448518, 'Spotify'),
('The Weeknd', 'Blinding Lights', 'After Hours', 'album', 0.514, 0.730, -5.934, 0.0598, 0.00146, 0.000095, 0.0897, 0.334, 171.005, 3.33, 'The Weeknd - Blinding Lights', 'TheWeekndVEVO', 760000000, 9500000, 420000, TRUE, TRUE, 3900000000, 0.065481, 'Spotify'),
('Dua Lipa', 'Levitating', 'Future Nostalgia', 'album', 0.702, 0.825, -3.787, 0.0601, 0.00883, 0.000000, 0.0674, 0.915, 102.977, 3.38, 'Dua Lipa - Levitating', 'Dua Lipa', 900000000, 7800000, 250000, TRUE, TRUE, 1800000000, 0.055605, 'Spotify'),
('Dua Lipa', 'Physical', 'Future Nostalgia', 'album', 0.647, 0.844, -3.756, 0.0457, 0.0137, 0.000658, 0.1020, 0.746, 146.967, 3.23, 'Dua Lipa - Physical', 'Dua Lipa', 420000000, 3900000, 118000, TRUE, TRUE, 620000000, 0.086088, 'Spotify'),
('Ed Sheeran', 'Shape of You', 'Divide', 'album', 0.825, 0.652, -3.183, 0.0802, 0.5810, 0.000000, 0.0931, 0.931, 95.977, 3.89, 'Ed Sheeran - Shape of You', 'Ed Sheeran', 6100000000, 32000000, 1200000, TRUE, TRUE, 3600000000, 0.060701, 'Youtube'),
('Ed Sheeran', 'Perfect', 'Divide', 'album', 0.599, 0.448, -6.312, 0.0232, 0.1630, 0.000000, 0.1060, 0.168, 95.050, 4.39, 'Ed Sheeran - Perfect', 'Ed Sheeran', 3600000000, 21000000, 800000, TRUE, TRUE, 2800000000, 0.047488, 'Youtube'),
('Bad Bunny', 'Tití Me Preguntó', 'Un Verano Sin Ti', 'album', 0.650, 0.715, -5.198, 0.2530, 0.0993, 0.000291, 0.1260, 0.187, 106.672, 4.06, 'Bad Bunny - Titi Me Pregunto', 'Bad Bunny', 950000000, 6700000, 210000, TRUE, TRUE, 1500000000, 0.090090, 'Spotify'),
('Bad Bunny', 'Moscow Mule', 'Un Verano Sin Ti', 'album', 0.804, 0.674, -5.453, 0.0333, 0.2940, 0.000001, 0.1150, 0.292, 99.968, 4.09, 'Bad Bunny - Moscow Mule', 'Bad Bunny', 620000000, 5100000, 160000, TRUE, TRUE, 1300000000, 0.077510, 'Spotify'),
('Billie Eilish', 'bad guy', 'WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?', 'album', 0.701, 0.425, -10.965, 0.3750, 0.3280, 0.130000, 0.1000, 0.562, 135.128, 3.24, 'Billie Eilish - bad guy', 'BillieEilishVEVO', 1300000000, 12000000, 330000, TRUE, TRUE, 2500000000, 0.042500, 'Spotify'),
('Billie Eilish', 'Lovely', 'Lovely', 'single', 0.351, 0.296, -10.109, 0.0333, 0.9340, 0.000000, 0.0950, 0.120, 115.284, 3.34, 'Billie Eilish, Khalid - lovely', 'BillieEilishVEVO', 2000000000, 18000000, 550000, TRUE, TRUE, 2200000000, 0.028120, 'Spotify'),
('Taylor Swift', 'Anti-Hero', 'Midnights', 'album', 0.637, 0.643, -6.571, 0.0519, 0.1300, 0.000002, 0.1420, 0.533, 97.008, 3.34, 'Taylor Swift - Anti-Hero', 'Taylor Swift', 210000000, 3500000, 122000, TRUE, TRUE, 1700000000, 0.091306, 'Spotify'),
('Taylor Swift', 'Blank Space', '1989', 'album', 0.760, 0.703, -5.412, 0.0540, 0.1030, 0.000000, 0.0913, 0.570, 95.997, 3.85, 'Taylor Swift - Blank Space', 'TaylorSwiftVEVO', 3400000000, 17000000, 620000, TRUE, TRUE, 1600000000, 0.064184, 'Youtube'),
('Olivia Rodrigo', 'drivers license', 'SOUR', 'album', 0.561, 0.431, -8.810, 0.0578, 0.7680, 0.000014, 0.1060, 0.137, 143.875, 4.03, 'Olivia Rodrigo - drivers license', 'OliviaRodrigoVEVO', 510000000, 8200000, 260000, TRUE, TRUE, 1900000000, 0.045686, 'Spotify'),
('Glass Animals', 'Heat Waves', 'Dreamland', 'album', 0.761, 0.525, -6.900, 0.0944, 0.4400, 0.000007, 0.0921, 0.531, 80.870, 3.98, 'Glass Animals - Heat Waves', 'Glass Animals', 620000000, 5200000, 140000, TRUE, TRUE, 2700000000, 0.048353, 'Spotify'),
('Imagine Dragons', 'Bones', 'Mercury - Acts 1 & 2', 'single', 0.772, 0.750, -3.670, 0.0469, 0.0206, 0.000000, 0.0740, 0.595, 114.061, 2.75, 'Imagine Dragons - Bones', 'ImagineDragonsVEVO', 420000000, 4800000, 155000, TRUE, TRUE, 900000000, 0.055500, 'Spotify'),
('Sample Artist', 'Zero Duration Track', 'Data Quality Album', 'single', 0.500, 0.500, -8.000, 0.0400, 0.2000, 0.000000, 0.1000, 0.300, 120.000, 0.00, 'Zero Duration Track', 'Sample Channel', 1000, 20, 5, FALSE, FALSE, 10000, 0.050000, 'Spotify'),
(NULL, 'Missing Artist Track', 'Data Quality Album', 'single', 0.500, 0.500, -8.000, 0.0400, 0.2000, 0.000000, 0.1000, 0.300, 120.000, 2.50, 'Missing Artist Track', 'Sample Channel', 1000, 20, 5, FALSE, FALSE, 10000, 0.050000, 'Youtube');
