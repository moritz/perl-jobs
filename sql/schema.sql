DROP TABLE IF EXISTS login;
DROP TABLE IF EXISTS skillset;
DROP TYPE IF EXISTS VISIBILITY_T;

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified = now();
    RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TYPE VISIBILITY_T AS ENUM ('private', 'semi', 'public');
CREATE TYPE SKILLSET_T   AS ENUM ('login', 'job');

CREATE TABLE skillset (
    id          SERIAL PRIMARY KEY,
    name        TEXT,
    visibility  VISIBILITY_T NOT NULL DEFAULT 'private',
    belongs_to  SKILLSET_T   NOT NULL DEFAULT 'login',
    url         VARCHAR(512),
    natural_languages       HSTORE,
    programming_languages   HSTORE,
    perl_stuff              HSTORE,
    other_technoligies      HSTORE,
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE login (
    id          SERIAL PRIMARY KEY,
    email       TEXT NOT NULL UNIQUE,
    skillset    INTEGER REFERENCES skillset (id),
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_login_modtime BEFORE UPDATE ON login FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_skillset_modtime BEFORE UPDATE ON skillset FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
