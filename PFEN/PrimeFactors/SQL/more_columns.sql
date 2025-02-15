ALTER TABLE Numbers
ADD COLUMN inv_primorial   SMALLINT UNSIGNED,
ADD COLUMN inv_factorial   SMALLINT UNSIGNED,
ADD COLUMN log2            SMALLINT UNSIGNED,
ADD COLUMN log3            SMALLINT UNSIGNED,
ADD COLUMN log5            SMALLINT UNSIGNED,
ADD COLUMN log7            SMALLINT UNSIGNED,
ADD COLUMN log10           SMALLINT UNSIGNED;

--- OR ---


CREATE TABLE inv_primeorial (
    inv_primeorial_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    inv_primorial_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
CREATE TABLE inv_factorial (
    inv_factorial_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    inv_factrial_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);

CREATE TABLE log2 (
    log2_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    log2_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
CREATE TABLE log3 (
    log3_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    log3_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
CREATE TABLE log5 (
    log5_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    log5_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
CREATE TABLE log7 (
    log7_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    log7_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
CREATE TABLE log10 (
    log10_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number_id BIGINT UNSIGNED NOT NULL,
    log10_value INT UNSIGNED NOT NULL,
    FOREIGN KEY (number_id) REFERENCES numbers(number_id) ON DELETE CASCADE,
    UNIQUE (number_id)  -- Ensures each number_id appears only once
);
