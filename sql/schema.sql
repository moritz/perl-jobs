DROP TABLE IF EXISTS job;
DROP TABLE IF EXISTS login;
DROP TABLE IF EXISTS skillset;
DROP TYPE IF EXISTS VISIBILITY_T;
DROP TYPE IF EXISTS SKILLSET_T;

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
    other_technologies      HSTORE,
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_skillset_modtime BEFORE UPDATE ON skillset FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER audit_skillset AFTER INSERT OR UPDATE OR DELETE ON skillset FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();

CREATE TABLE login (
    id          SERIAL PRIMARY KEY,
    email       TEXT NOT NULL UNIQUE,
    skillset    INTEGER REFERENCES skillset (id),
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_login_modtime BEFORE UPDATE ON login FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER audit_login AFTER INSERT OR UPDATE OR DELETE ON login FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();

CREATE TABLE job (
    id          SERIAL PRIMARY KEY,
    skillset    INTEGER REFERENCES skillset (id),
    entered_by  INTEGER NOT NULL REFERENCES login (id),
    modified    TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TRIGGER update_job_modtime BEFORE UPDATE ON login FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER audit_job AFTER INSERT OR UPDATE OR DELETE ON job FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();
