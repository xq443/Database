# Creating a new SQLite database using R and RSQLite
# Author: Xujia Qin
# Date: 20th May, 2025

# Load RSQLite library
library(RSQLite)

# Define file path and database file name
fpath <- "/Users/cathyqin/Desktop/DB/Assignment5/"
dbfile <- "lessonDB-QinX.sqlitedb"

# Connect to existing DB or create a new one
dbcon <- dbConnect(RSQLite::SQLite(), paste0(fpath, dbfile))
# Enable foreign key constraint
dbExecute(dbcon, "PRAGMA foreign_keys = ON")

# Drop any tables if they already exist
dbExecute(dbcon, "DROP TABLE IF EXISTS LessonPrerequisite;")
dbExecute(dbcon, "DROP TABLE IF EXISTS LessonModule;")
dbExecute(dbcon, "DROP TABLE IF EXISTS Lesson;")
dbExecute(dbcon, "DROP TABLE IF EXISTS Module;")
dbExecute(dbcon, "DROP TABLE IF EXISTS Difficulty;")

# Create lookup table for difficulty levels: better data integrity and normalization
# Create Difficulty table before creating the Module table to implement foreign key resolution.
dbExecute(dbcon, "
CREATE TABLE Difficulty (
  level TEXT PRIMARY KEY
);
")

# Insert values into Difficulty table
dbExecute(dbcon, "INSERT INTO Difficulty (level) VALUES ('beginner'), ('intermediate'), ('advanced');")

# Create Module table
dbExecute(dbcon, "
CREATE TABLE Module (
  mid TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  lengthInMinutes NUMERIC NOT NULL,
  difficulty TEXT NOT NULL,
  FOREIGN KEY (difficulty) REFERENCES Difficulty(level)
);
")

# Insert modules data
dbExecute(dbcon, "
INSERT INTO Module (mid, title, lengthInMinutes, difficulty) VALUES
('M1', 'CS Fundamentals', 90, 'beginner'),
('M2', 'Data Track', 120, 'intermediate'),
('M3', 'Security', 100, 'intermediate')
")

# Create Lesson table with composite primary key
dbExecute(dbcon, "
CREATE TABLE Lesson (
  category INTEGER NOT NULL,
  number INTEGER NOT NULL,
  title TEXT NOT NULL,
  PRIMARY KEY (category, number)
);
")

dbExecute(dbcon, "
INSERT INTO Lesson (category, number, title) VALUES
(1, 101, 'Java Programming'),
(1, 102, 'Data Structures'),
(1, 103, 'Algorithms'),
(2, 201, 'Databases Management'),
(2, 202, 'Machine Learning'),
(3, 301, 'Cybersecurity Basics'),
(3, 302, 'Network Security');
")


# Create LessonPrerequisite table (resolve many-to-many into self-relationship)
dbExecute(dbcon, "
CREATE TABLE LessonPrerequisite (
  category INTEGER NOT NULL,
  number INTEGER NOT NULL,
  pre_category INTEGER NOT NULL,
  pre_number INTEGER NOT NULL,
  FOREIGN KEY (category, number) REFERENCES Lesson(category, number),
  PRIMARY KEY (category, number, pre_category, pre_number)
);
")

# Insert prerequisites data
dbExecute(dbcon, "
INSERT INTO LessonPrerequisite (category, number, pre_category, pre_number) VALUES
(1, 102, 1, 101),  -- Data Structures requires Java
(1, 103, 1, 102),  -- Algorithms requires Data Structures
(3, 302, 3, 301); -- Network security requires cybersecurity basics
")

# Create LessonModule junction table (resolve many-to-many relationship)
dbExecute(dbcon, "
CREATE TABLE LessonModule (
  category INTEGER NOT NULL,
  number INTEGER NOT NULL,
  mid TEXT NOT NULL,
  FOREIGN KEY (category, number) REFERENCES Lesson(category, number),
  FOREIGN KEY (mid) REFERENCES Module(mid),
  PRIMARY KEY (category, number, mid)
);
")

# Insert lessonsModule data to map lessions to modules
dbExecute(dbcon, "
INSERT INTO LessonModule (category, number, mid) VALUES
(1, 101, 'M1'),
(1, 102, 'M1'),
(1, 103, 'M2'),
(2, 201, 'M2'),
(2, 202, 'M2');
(3, 301, 'M3'),
(3, 302, 'M3');
")

# Log successful connection
cat("Database schema successfully created.\n")

# --------------------------
# ~ Run Queries ~
# --------------------------

# 1. List all lessons
cat("\nAll Lessons:\n")
print(dbGetQuery(dbcon, "SELECT * FROM Lesson;"))

# 2. List Lessons and their prerequisites
cat("\nLesson Prerequisites:\n")
print(dbGetQuery(dbcon, "
  SELECT l1.title AS lesson, l2.title AS prerequisite
  FROM LessonPrerequisite lp
  JOIN Lesson l1 ON lp.category = l1.category AND lp.number = l1.number
  JOIN Lesson l2 ON lp.pre_category = l2.category AND lp.pre_number = l2.number;
"))

# 3. Lessons associated with modules (in ASCII asc order)
cat("\nLessons in Modules:\n")
print(dbGetQuery(dbcon, "
  SELECT m.title AS module, l.title AS lesson
  FROM LessonModule lm
  JOIN Module m ON lm.mid = m.mid
  JOIN Lesson l ON lm.category = l.category AND lm.number = l.number
  ORDER BY m.title;
"))


# Disconnect
dbDisconnect(dbcon)
