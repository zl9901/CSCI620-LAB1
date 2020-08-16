#CREATE RAW DATA TABLE
CREATE TABLE `title_akas` (
  `titleId` varchar(80) NOT NULL,
  `ordering` varchar(45) NOT NULL,
  `title` longtext,
  `region` varchar(45) DEFAULT NULL,
  `language` varchar(45) DEFAULT NULL,
  `types` longtext,
  `attributes` longtext,
  `isOriginal` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`titleId`,`ordering`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_basics` (
  `tconst` varchar(80) NOT NULL,
  `title-type` varchar(80) DEFAULT NULL,
  `pTitle` longtext,
  `oTitle` varchar(600) DEFAULT NULL,
  `isAdult` varchar(45) DEFAULT NULL,
  `startYear` varchar(45) DEFAULT NULL,
  `endYear` varchar(45) DEFAULT NULL,
  `runtimeMinutes` varchar(45) DEFAULT NULL,
  `genres` varchar(180) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_episodes` (
  `tconst` varchar(45) NOT NULL,
  `parentTconst` varchar(45) DEFAULT NULL,
  `seasonNumber` varchar(45) DEFAULT NULL,
  `episodeNumber` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_principals` (
  `tconst` varchar(45) NOT NULL,
  `ordering` varchar(45) DEFAULT NULL,
  `nconst` varchar(45) DEFAULT NULL,
  `category` varchar(45) DEFAULT NULL,
  `job` varchar(45) DEFAULT NULL,
  `characters` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `name_basics` (
  `nconst` varchar(45) NOT NULL,
  `primaryName` longtext,
  `birthYear` varchar(45) DEFAULT NULL,
  `deathYear` varchar(45) DEFAULT NULL,
  `primaryProfession` varchar(45) DEFAULT NULL,
  `knownForTitles` longtext,
  PRIMARY KEY (`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#CREATE firstly cleaned DATA TABLE
CREATE TABLE `new_title_akas` (
  `titleId` varchar(80) NOT NULL,
  `ordering` varchar(45) NOT NULL,
  `title` longtext,
  `region` varchar(45) DEFAULT NULL,
  `language` varchar(45) DEFAULT NULL,
  `types` longtext,
  `attributes` longtext,
  `isOriginal` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`titleId`,`ordering`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `new_title_basics` (
  `tconst` varchar(80) NOT NULL,
  `title-type` varchar(80) DEFAULT NULL,
  `pTitle` longtext,
  `oTitle` varchar(600) DEFAULT NULL,
  `isAdult` varchar(45) DEFAULT NULL,
  `startYear` varchar(45) DEFAULT NULL,
  `endYear` varchar(45) DEFAULT NULL,
  `runtimeMinutes` varchar(45) DEFAULT NULL,
  `genres` varchar(180) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `new_title_episodes` (
  `tconst` varchar(45) NOT NULL,
  `parentTconst` varchar(45) DEFAULT NULL,
  `seasonNumber` varchar(45) DEFAULT NULL,
  `episodeNumber` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `new_title_principals` (
  `tconst` varchar(45) NOT NULL,
  `ordering` varchar(45) DEFAULT NULL,
  `nconst` varchar(45) DEFAULT NULL,
  `category` varchar(45) DEFAULT NULL,
  `job` varchar(45) DEFAULT NULL,
  `characters` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `new_name_basics` (
  `nconst` varchar(45) NOT NULL,
  `primaryName` longtext,
  `birthYear` varchar(45) DEFAULT NULL,
  `deathYear` varchar(45) DEFAULT NULL,
  `primaryProfession` varchar(45) DEFAULT NULL,
  `knownForTitles` longtext,
  PRIMARY KEY (`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#LOAD DATA
LOAD DATA INFILE 'titleBasic.tsv' INTO TABLE `title_basics`
FIELDS enclosed by '"' TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA INFILE 'titleAkas.tsv' INTO TABLE `title_akas`
FIELDS enclosed by '"' TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA INFILE 'episode.tsv' INTO TABLE `title_episodes`
FIELDS enclosed by '"' TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA INFILE 'principals.tsv' INTO TABLE `title_principals`
FIELDS enclosed by '"' TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA INFILE 'name.tsv' INTO TABLE `name_basics`
FIELDS enclosed by '"' TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;

#clean the data and store into the new table
#First step, remove null value 
INSERT INTO `new_title_akas`
SELECT *
FROM `title_akas` old
WHERE old.language IS NOT NULL
AND old.title IS NOT NULL
AND old.original IS NOT NULL;

INSERT INTO `new_title_basics`
SELECT *
FROM `title_basics` old
WHERE (old.startYear IS NOT NULL
AND old.title-type IS NOT NULL
AND old.pTitle IS NOT NULL
AND old.oTitle IS NOT NULL)
# check each movie has runtime
OR (old.title-type = `movie`
AND old.runtimeMinutes IS NOT NULL);

INSERT INTO `new_title_episodes`
SELECT *
FROM `title_episodes` old
WHERE old.parentTconst IS NOT NULL
AND old.seasonNumber IS NOT NULL
AND old.episodeNumber IS NOT NULL;

INSERT INTO `new_title_principals`
SELECT *
FROM `title_principals` old
WHERE (old.nconst IS NOT NULL
AND old.category IS NOT NULL)
OR( old.job = 'actor' OR old.job = 'actress' AND old.characters IS NOT NULL);

INSERT INTO `new_name_basics`
SELECT *
FROM `name_basics` old
WHERE old.primaryName IS NOT NULL
AND old.birthYear IS NOT NULL;

#Second step, remove duplicated data
CREATE TABLE `new2_title_akas` SELECT * FROM `new_title_akas` N1 GROUP BY (N1.title, N1.language);
CREATE TABLE `new2_title_basics` SELECT * FROM `new_title_basics` N1 GROUP BY (N1.pTitle, N1.oTitle, N1.startYear);
CREATE TABLE `new2_title_episodes` SELECT * FROM `new_title_episodes` N1 GROUP BY (N1.tconst, N1.parentTconst);
# Only actor ot actress and have multiple characters in this table
CREATE TABLE `new2_title_principals` SELECT * FROM `new_title_principals` N1
WHERE NOT N1.job = 'actor' AND NOT N1.job = 'actress' GROUP BY (N1.tconst, N1.nconst);
CREATE TABLE `new2_name_basics` SELECT * FROM `new_name_basics` N1 GROUP BY (N1.primaryName, N1.birthYear);

#drop old tables now
DROP TABLE new_title_akas;
DROP TABLE new_title_basics;
DROP TABLE new_title_episodes;
DROP TABLE new_title_principals;
DROP TABLE new_name_basics;
DROP TABLE title_basics;
DROP TABLE title_akas;
DROP TABLE title_episodes;
DROP TABLE title_principals;
DROP TABLE name_basics;