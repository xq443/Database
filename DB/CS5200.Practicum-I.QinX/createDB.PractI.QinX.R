# Program: Practicum I - Part C / Realize Database
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: Define the database schema and load data into a MySQL database on Aiven.

# Load required libraries
library(DBI)
library(RMySQL)

# Database connection settings
db_user <- 'avnadmin'
db_password <- 'AVNS_myNMlu7wBu69NOuFkU1'
db_name <- 'defaultdb'
db_host <- 'mysql-1c2ba4a8-northeastern-cee5.k.aivencloud.com'
db_port <- 19461

# Connect to the database
con <- dbConnect(RMySQL::MySQL(),
                 user = db_user,
                 password = db_password,
                 dbname = db_name,
                 host = db_host,
                 port = db_port)


# Create Flight table
dbExecute(con, "
  CREATE TABLE Flight (
    flight_number INT NOT NULL,
    date DATE NOT NULL,
    airline VARCHAR(100) NOT NULL,
    aircraft VARCHAR(50) NOT NULL,
    dep_airport VARCHAR(10) NOT NULL,
    PRIMARY KEY (flight_number, date)
  );
")

# Create lookup tables
dbExecute(con, "
  CREATE TABLE IncidentType (
    type VARCHAR(50) PRIMARY KEY
  );
")

dbExecute(con, "
  CREATE TABLE Severity (
    level VARCHAR(20) PRIMARY KEY
  );
")

dbExecute(con, "
  CREATE TABLE Reporter (
    source VARCHAR(50) PRIMARY KEY
  );
")

# Create Incident table
dbExecute(con, "
  CREATE TABLE Incident (
    iid VARCHAR(20) PRIMARY KEY,
    flight_number INT NOT NULL,
    date DATE,
    incident_type VARCHAR(50),
    severity VARCHAR(20),
    delay_mins INT DEFAULT 0,
    num_injuries INT DEFAULT 0,
    reported_by VARCHAR(50),
    FOREIGN KEY (flight_number, date) REFERENCES Flight(flight_number, date),
    FOREIGN KEY (incident_type) REFERENCES IncidentType(type),
    FOREIGN KEY (severity) REFERENCES Severity(level),
    FOREIGN KEY (reported_by) REFERENCES Reporter(source)
  );
")

# Disconnect
dbDisconnect(con)
cat("✅Database has been created.\n")