# Program: Practicum I - Part F / Test Data Loading Process
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: Test and validate the data loading process by querying aggregation results.

# Load required libraries
library(DBI)
library(RMySQL)

# Database connection parameters
db_user <- 'avnadmin'
db_password <- 'AVNS_myNMlu7wBu69NOuFkU1'
db_name <- 'defaultdb'
db_host <- 'mysql-1c2ba4a8-northeastern-cee5.k.aivencloud.com'
db_port <- 19461

# Connect to database
con <- dbConnect(MySQL(), user = db_user, password = db_password,
                 dbname = db_name, host = db_host, port = db_port)

cat("✅ Database Connection Succeed.\n")

# URL for the CSV file
url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/incidents.csv"
# Load CSV from the URL
data <- read.csv(url, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Fill missing values
data$delay.mins[is.na(data$delay.mins)] <- 0
data$num.injuries[is.na(data$num.injuries)] <- 0
data$reported.by[is.na(data$reported.by)] <- "Unknown"
data$date <- as.Date(data$date, format = "%d.%m.%Y")

# Helper function to compare and print
compare_values <- function(name, csv_val, db_val) {
  if (csv_val == db_val) {
    message(sprintf("✅ %s matches: %s", name, csv_val))
  } else {
    message(sprintf("⚠️ %s mismatch - CSV: %s vs DB: %s", name, csv_val, db_val))
  }
}

# --- Unique counts and dates from CSV ---
csv_unique_airlines <- length(unique(data$airline))
csv_unique_flights <- nrow(unique(data[c("flight.number", "date")]))
csv_unique_incidents <- length(unique(data$iid))
csv_first_date <- min(data$date, na.rm = TRUE)
csv_last_date <- max(data$date, na.rm = TRUE)

cat("Unique Airlines:", csv_unique_airlines, "\n")
cat("Unique Flights:", csv_unique_flights, "\n")
cat("Unique Incidents:", csv_unique_incidents, "\n")
cat("First Date:", format(csv_first_date), "\n")
cat("Last Date:", format(csv_last_date), "\n")

# --- Query unique counts and dates from DB ---
db_unique_airlines <- dbGetQuery(con, "SELECT COUNT(DISTINCT airline) AS cnt FROM Flight")$cnt[1]
db_unique_flights <- dbGetQuery(con, "SELECT COUNT(*) AS cnt FROM Flight")$cnt[1]
db_unique_incidents <- dbGetQuery(con, "SELECT COUNT(*) AS cnt FROM Incident")$cnt[1]
db_first_date <- dbGetQuery(con, "SELECT MIN(date) AS first_date FROM Flight")$first_date[1]
db_last_date <- dbGetQuery(con, "SELECT MAX(date) AS last_date FROM Flight")$last_date[1]


# Compare and print
compare_values("Airlines", csv_unique_airlines, db_unique_airlines)
compare_values("Flights", csv_unique_flights, db_unique_flights)
compare_values("Incidents", csv_unique_incidents, db_unique_incidents)

if (csv_first_date == db_first_date) {
  message(sprintf("✅ First date matches: %s", csv_first_date))
} else {
  message(sprintf("⚠️ First date mismatch - CSV: %s vs DB: %s", csv_first_date, db_first_date))
}

if (csv_last_date == db_last_date) {
  message(sprintf("✅ Last date matches: %s", csv_last_date))
} else {
  message(sprintf("⚠️ Last date mismatch - CSV: %s vs DB: %s", csv_last_date, db_last_date))
}

# --- Aggregates: sum delay mins and average num injuries ---
csv_sum_delay <- sum(data$delay.mins)
csv_avg_injuries <- mean(data$num.injuries)

db_agg_query <- "
  SELECT 
    SUM(delay_mins) AS sum_delay,
    AVG(num_injuries) AS avg_injuries
  FROM Incident;
"

db_agg <- suppressWarnings(dbGetQuery(con, db_agg_query))

compare_values("Sum of delay mins", csv_sum_delay, db_agg$sum_delay[1])
compare_values("Average number of injuries", round(csv_avg_injuries, 2), round(db_agg$avg_injuries[1], 2))

# Disconnect
dbDisconnect(con)


