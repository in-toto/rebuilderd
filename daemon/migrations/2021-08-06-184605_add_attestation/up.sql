-- add attestation field to "build" table
ALTER TABLE builds
ADD attestation VARCHAR;

-- drop attestation column, add has_attestation field to "packages" table
PRAGMA foreign_keys=off;

CREATE TABLE _packages_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    base_id INTEGER,
    name VARCHAR NOT NULL,
    version VARCHAR NOT NULL,
    status VARCHAR NOT NULL,
    distro VARCHAR NOT NULL,
    suite VARCHAR NOT NULL,
    architecture VARCHAR NOT NULL,
    url VARCHAR NOT NULL,
    build_id INTEGER,
    built_at DATETIME,
    has_diffoscope BOOLEAN NOT NULL,
    has_attestation BOOLEAN NOT NULL,
    checksum VARCHAR,
    retries INTEGER NOT NULL,
    next_retry DATETIME,
    CONSTRAINT packages_unique UNIQUE (name, distro, suite, architecture),
    FOREIGN KEY(base_id) REFERENCES pkgbases(id),
    FOREIGN KEY(build_id) REFERENCES builds(id)
);

INSERT INTO _packages_new (id, base_id, name, version, status, distro, suite, architecture, url, build_id, built_at, has_diffoscope, has_attestation, checksum, retries, next_retry)
    SELECT id, base_id, name, version, status, distro, suite, architecture, url, build_id, built_at, false, false, checksum, retries, next_retry
    FROM packages;

DROP TABLE packages;
ALTER TABLE _packages_new RENAME TO packages;

PRAGMA foreign_keys=on;

-- initialize new has_attestation field
update packages set has_attestation=true where build_id in (select id from builds where attestation is not null);
