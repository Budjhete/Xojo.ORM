#
# SQLite schema for ORMTestDatabase
#

CREATE TABLE `UsersProjects` (
    `user` INTEGER REFERENCES `Users`(`id`) ON UPDATE CASCADE ON DELETE CASCADE,
    `project` INTEGER REFERENCES `Projects`(`id`),
    PRIMARY KEY (`user`, `project`)
);

CREATE TABLE `Projects` (
    `id` INTEGER PRIMARY KEY,
    `user` INTEGER REFERENCES `Users`(`id`) ON UPDATE CASCADE ON DELETE SET NULL,
    `name` TEXT NOT NULL UNIQUE,
    `description` TEXT
);

CREATE TABLE `Users` (
    `id` INTEGER PRIMARY KEY,
    `username` TEXT UNIQUE NOT NULL,
    `password` TEXT,
    `group` INTEGER REFERENCES `Groups`(`id`) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE `Groups` (
    `id` INTEGER PRIMARY KEY,
    `user` INTEGER REFERENCES `User`(`id`),
    `name` TEXT UNIQUE
);
