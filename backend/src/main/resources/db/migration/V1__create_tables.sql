-- Schema from blueprint.md §5 (approved v1.0). Flyway runs this once per database and records it
-- in flyway_schema_history. Never edit this file after it has run anywhere (invariant 5):
-- change the schema with a new file, V2__..., V3__..., instead.

CREATE TABLE education (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institution VARCHAR(150) NOT NULL,
    degree      VARCHAR(200) NOT NULL,
    cgpa        NUMERIC(4,2) CHECK (cgpa BETWEEN 0 AND 10),
    location    VARCHAR(100),
    start_date  DATE NOT NULL,
    end_date    DATE,                                   -- NULL = ongoing
    position    INT  NOT NULL,
    UNIQUE (institution, degree),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE skill_categories (
    id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     VARCHAR(50) NOT NULL UNIQUE,               -- "Frameworks & Tools"
    skills   TEXT[]      NOT NULL DEFAULT '{}',         -- in resume order
    position INT         NOT NULL
);

CREATE TABLE experiences (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organization VARCHAR(150) NOT NULL,
    role         VARCHAR(150) NOT NULL,
    location     VARCHAR(100),
    start_date   DATE   NOT NULL,
    end_date     DATE,                                  -- NULL = "Present"
    bullets      TEXT[] NOT NULL DEFAULT '{}',
    position     INT    NOT NULL,
    UNIQUE (organization, role),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE projects (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         VARCHAR(150) NOT NULL UNIQUE,
    technologies TEXT[]       NOT NULL DEFAULT '{}',
    bullets      TEXT[]       NOT NULL DEFAULT '{}',
    github_url   VARCHAR(500),
    source       VARCHAR(10)  NOT NULL DEFAULT 'RESUME' CHECK (source IN ('RESUME', 'MANUAL')),
    position     INT          NOT NULL
);

CREATE TABLE publications (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       VARCHAR(300) NOT NULL UNIQUE,
    authors     TEXT[]       NOT NULL,                  -- in the order printed on the paper
    self_author INT          NOT NULL,                  -- which author is Praveen (1 = first)
    venue       VARCHAR(200) NOT NULL,
    status      VARCHAR(100),
    position    INT          NOT NULL,
    CHECK (self_author BETWEEN 1 AND cardinality(authors))   -- cardinality('{}') = 0, so an empty list is rejected
);

CREATE TABLE certifications (
    id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     VARCHAR(200) NOT NULL UNIQUE,
    position INT NOT NULL
);

-- Written by visitors; never touched by the resume sync.
CREATE TABLE contact_messages (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    email      VARCHAR(254)  NOT NULL,
    message    VARCHAR(5000) NOT NULL,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
