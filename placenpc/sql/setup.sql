CREATE TABLE IF NOT EXISTS npcs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    z FLOAT NOT NULL,
    heading FLOAT NOT NULL,
    anim_dict VARCHAR(255) DEFAULT NULL, -- Added column for animation dictionary
    anim_name VARCHAR(255) DEFAULT NULL  -- Added column for animation name
);