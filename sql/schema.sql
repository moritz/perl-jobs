DROP TYPE IF EXISTS VISIBILITY_T;
DROP TABLE IF EXISTS profile;

CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified = now();
    RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TYPE VISIBILITY_T AS ENUM ('private', 'semi', 'public');
CREATE TABLE profile (
    id          SERIAL PRIMARY KEY,
    email       TEXT NOT NULL UNIQUE,
    name        TEXT,
    visibility  VISIBILITY_T NOT NULL DEFAULT 'private',
    natural_languages       HSTORE,
    programming_languages   HSTORE,
    perl_stuff              HSTORE,
    other_technoligies      HSTORE,
    focus                   HSTORE,
    softskills              HSTORE,
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_profile_modtime BEFORE UPDATE ON profile FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
