CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION citext;
CREATE EXTENSION pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  user_id uuid DEFAULT uuid_generate_v4 () PRIMARY KEY,
  name varchar(250) NOT NULL,
  email citext UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_on TIMESTAMP NOT NULL,
  last_login TIMESTAMP 
);

CREATE TABLE IF NOT EXISTS moviedetail (
    id INTEGER PRIMARY KEY,
    adult BOOLEAN NOT NULL,
    backdrop_path TEXT,
    budget INTEGER,
    imdb_id TEXT NOT NULL,
    title TEXT NOT NULL,
    overview TEXT,
    popularity FLOAT,
    poster_path TEXT,
    release_date DATE,
    runtime INTEGER,
    revenue INTEGER,
    vote_average FLOAT
);

CREATE TABLE IF NOT EXISTS People_info (
    id INTEGER NOT NULL PRIMARY KEY,
    birthday DATE,
    know_for_department TEXT,
    name TEXT NOT NULL,
    gender INTEGER NOT NULL,
    biography TEXT,
    place_of_birth TEXT,
    profile_path TEXT
);

CREATE TABLE IF NOT EXISTS userratings (
    rating_uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    movie_id INTEGER REFERENCES moviedetail (id) ON DELETE CASCADE,
    rates FLOAT,
    CONSTRAINT per_user_rating UNIQUE (user_id, movie_id)
);

CREATE TABLE IF NOT EXISTS userfavmovie (
    favourite_uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    movie_id INTEGER REFERENCES moviedetail (id) ON DELETE CASCADE,
    CONSTRAINT per_user_movie UNIQUE (user_id, movie_id)
);

CREATE TABLE IF NOT EXISTS userfavactor (
    actor_like_uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    actor_id INTEGER REFERENCES People_info (id) ON DELETE CASCADE,
    CONSTRAINT per_user_actor UNIQUE (user_id, actor_id)
);

CREATE TABLE IF NOT EXISTS userview (
    view_uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    movie_id INTEGER REFERENCES moviedetail (id) ON DELETE CASCADE,
    time TIMESTAMP,
    CONSTRAINT per_user_view UNIQUE (user_id, movie_id)
);

CREATE TABLE IF NOT EXISTS genre (
    id INTEGER NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS moviegenre (
    movie_id INTEGER NOT NULL REFERENCES moviedetail (id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES genre (id),
    PRIMARY KEY(movie_id, genre_id)
);

CREATE TABLE IF NOT EXISTS Movie_People (
    movie_id INTEGER NOT NULL REFERENCES moviedetail (id) ON DELETE CASCADE,
    id INTEGER NOT NULL REFERENCES People_info (id),
    types TEXT,
    PRIMARY KEY(movie_id, id)
);

CREATE TABLE IF NOT EXISTS userreview (
    review_uuid uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    movie_id INTEGER REFERENCES moviedetail (id) ON DELETE CASCADE,
    contents TEXT,
    CONSTRAINT per_user_review UNIQUE (user_id, movie_id)
);