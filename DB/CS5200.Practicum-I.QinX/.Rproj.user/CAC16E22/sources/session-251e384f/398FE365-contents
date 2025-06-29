# Program: Practicum I - Part E / Populate Database
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: Load the data from the source URL into the pre-defined db schema

# Load required libraries
library(DBI)
library(RMySQL)

# Database connection parameters
db_user <- 'avnadmin'
db_password <- 'AVNS_myNMlu7wBu69NOuFkU1'
db_name <- 'defaultdb'
db_host <- 'mysql-1c2ba4a8-northeastern-cee5.k.aivencloud.com'
db_port <- 19461

# Connect to the database
con <- dbConnect(MySQL(), user = db_user, password = db_password,
                 dbname = db_name, host = db_host, port = db_port)
cat("✅ Database Connection Succeed.\n")

# Load CSV from URL
url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/incidents.csv"
data <- read.csv(url, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Fill missing values
data$delay.mins[is.na(data$delay.mins)] <- 0
data$num.injuries[is.na(data$num.injuries)] <- 0
data$reported.by[is.na(data$reported.by)] <- "Unknown"

# Populate lookup tables
unique_incident_types <- unique(data$incident.type)
for (val in unique_incident_types) {
  query <- sprintf("INSERT IGNORE INTO IncidentType (type) VALUES ('%s')", val)
  dbExecute(con, query)
}
cat("✅IncidentType table has been populated.\n")

unique_severity <- unique(data$severity)
for (val in unique_severity) {
  query <- sprintf("INSERT IGNORE INTO Severity (level) VALUES ('%s')", val)
  dbExecute(con, query)
}
cat("✅Severity table has been populated.\n")

unique_reporter <- unique(data$reported.by)
for (val in unique_reporter) {
  query <- sprintf("INSERT IGNORE INTO Reporter (source) VALUES ('%s')", val)
  dbExecute(con, query)
}
cat("✅Reporter table has been populated.\n")

# Populate the main tables
# Flight table
flights <- unique(data[c("flight.number", "date", "airline", "aircraft", "dep.airport")])

# reads each row from the flights DataFrame and inserts it into the SQL database.
for (i in 1:nrow(flights)) {
  row <- flights[i, ] # Extract the i-th row from the incidents data frame and assign it to the variable row.
  query <- sprintf(
    "INSERT IGNORE INTO Flight (flight_number, date, airline, aircraft, dep_airport)
     VALUES (%d, '%s', '%s', '%s', '%s')",
    as.integer(row$flight.number),  # passed as integer
    format(as.Date(row$date, format = "%d.%m.%Y"), "%Y-%m-%d"),
    dbEscapeStrings(con, row$airline),  # escape special characters in strings
    dbEscapeStrings(con, row$aircraft),
    dbEscapeStrings(con, row$dep.airport)
  )
  
  dbExecute(con, query)
}
cat("✅Flight table has been populated.\n")

# Incident table
incidents <- unique(data[c("iid", "flight.number", "date", "incident.type", "severity", "delay.mins", "num.injuries", "reported.by")])
for (i in 1:nrow(incidents)) {
  row <- incidents[i, ]
  query <- sprintf(
    "INSERT IGNORE INTO Incident (iid, flight_number, date, incident_type, severity, delay_mins, num_injuries, reported_by)
     VALUES ('%s', %d, '%s', '%s', '%s', %d, %d, '%s')",
    dbEscapeStrings(con, row$iid),
    as.integer(row$flight.number),         # %d for integer
    format(as.Date(row$date, format = "%d.%m.%Y"), "%Y-%m-%d"),
    dbEscapeStrings(con, row$incident.type),
    dbEscapeStrings(con, row$severity),
    as.integer(row$delay.mins),
    as.integer(row$num.injuries),
    dbEscapeStrings(con, row$reported.by)
  )
  
  dbExecute(con, query)
}
cat("✅Incident table has been populated.\n")

# Disconnect
dbDisconnect(con)
cat("✅Data successfully normalized and inserted into Aiven MySQL database.\n")
