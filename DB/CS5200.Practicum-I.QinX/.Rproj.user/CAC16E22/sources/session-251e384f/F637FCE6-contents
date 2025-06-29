# Program: Practicum I - Part H / Add Business Logic
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: This script contains functions and logic to interact with the MySQL database, including stored procedure calls for incidents.

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


# Drop the existing stored procedure if it exists
drop_procedure_query <- "DROP PROCEDURE IF EXISTS storeIncident;"

# Execute the query to drop the procedure
dbExecute(con, drop_procedure_query)

# Define the query to create the stored procedure `storeIncident`
create_procedure_query <- "
CREATE PROCEDURE storeIncident(
    IN iid VARCHAR(20),
    IN flight_number INT,
    IN incident_type VARCHAR(50),
    IN severity VARCHAR(20),
    IN incident_date DATE,
    IN delay_mins INT,
    IN num_injuries INT,
    IN reported_by VARCHAR(50)
)
BEGIN
    -- Insert the incident into the Incident table w/t considering the existance of fk
    INSERT INTO Incident (
        iid, flight_number, incident_type, severity, date, delay_mins, num_injuries, reported_by
    ) 
    VALUES (
        iid, flight_number, incident_type, severity, incident_date, delay_mins, num_injuries, reported_by
    );
END
"

# Execute the query to create the procedure
dbExecute(con, create_procedure_query)
cat("✅ Stored Procedure 'storeIncident' Created.\n")

# Test for storeIncident
incident_id <- 'i11'
flight_number <- 104
incident_type <- 'mechanical'
severity <- 'minor'
incident_date <- '2016-09-12'
delay_mins <- 120
num_injuries <- 2
reported_by <- 'ground staff'

# Try to call the storeIncident procedure and print the result
tryCatch({
  # Call the stored procedure (no airline_id, airport_id, or aircraft_id passed)
  result <- dbExecute(con, 
                      paste0("CALL storeIncident('", incident_id, "', ", flight_number, ", '", incident_type, "', '", severity, "', '", incident_date, "', ", delay_mins, ", ", num_injuries, ", '", reported_by, "');"))
  
  # Fetch the newly inserted incident from the Incident table
  fetch_query <- paste0("SELECT * FROM Incident WHERE iid = '", incident_id, "';")
  rs <- dbSendQuery(con, fetch_query)
  data <- fetch(rs, n = -1)  # Fetch all rows
  print(data)
  # Clear the result set
  dbClearResult(rs) 
  
  print("✅ Incident successfully stored!")
}, error = function(e) {
  print(paste("❌ Error: ", e$message))
})

# Drop the existing stored procedure `storeNewIncident` if it exists
drop_procedure_query <- "DROP PROCEDURE IF EXISTS storeNewIncident;"
dbExecute(con, drop_procedure_query)

# Create the stored procedure `storeNewIncident`
create_new_incident_procedure_query <- "
CREATE PROCEDURE storeNewIncident(
    IN iid VARCHAR(20),
    IN flight_number INT,
    IN incident_type VARCHAR(50),
    IN severity VARCHAR(20),
    IN incident_date DATE,
    IN delay_mins INT,
    IN num_injuries INT,
    IN reported_by VARCHAR(50),
    IN airline VARCHAR(100),
    IN aircraft VARCHAR(50),
    IN dep_airport VARCHAR(10)
)
BEGIN
    -- Insert new flight entry if it doesn't exist
    INSERT IGNORE INTO Flight (flight_number, date, airline, aircraft, dep_airport)
    VALUES (flight_number, incident_date, airline, aircraft, dep_airport);

    -- Insert the incident into the Incident table
    INSERT INTO Incident (
        iid, flight_number, incident_type, severity, date, delay_mins, num_injuries, reported_by
    ) 
    VALUES (
        iid, flight_number, incident_type, severity, incident_date, delay_mins, num_injuries, reported_by
    );
END
"

# Execute the query to create the stored procedure
dbExecute(con, create_new_incident_procedure_query)

cat("✅ Stored Procedure 'storeNewIncident' Created.\n")

# Test 2: Call `storeNewIncident` procedure
cat("\nTesting 'storeNewIncident' Procedure:\n")

# Define the procedure call parameters
incident_id_new <- 'i22'
flight_number_new <- 3377
incident_type_new <- 'weather'
severity_new <- 'critical'
incident_date_new <- '2021-09-20'
delay_mins_new <- 90
num_injuries_new <- 0
reported_by_new <- 'pilot'
airline_code_new <- 'DL'  
airport_code_new <- 'GRU'  
aircraft_model_new <- 'A350-900'  

# Try to call the stored procedure and fetch the newly inserted data
tryCatch({
  # Call the stored procedure
  dbExecute(con, paste0("CALL storeNewIncident('", incident_id_new, "', ", flight_number_new, ", '", incident_type_new, "', '", severity_new, "', '", incident_date_new, "', ", delay_mins_new, ", ", num_injuries_new, ", '", reported_by_new, "', '", airline_code_new, "', '", aircraft_model_new, "', '", airport_code_new, "');"))
  
  # Fetch the newly inserted incident
  fetch_query_new <- paste0("SELECT * FROM Incident WHERE iid = '", incident_id_new, "';")
  rs_new <- dbSendQuery(con, fetch_query_new)
  data_new <- fetch(rs_new, n = -1)  # Fetch all rows
  print(data_new)
  # Clear the result set
  dbClearResult(rs_new) 
  
  print("✅ New incident successfully stored via storeNewIncident procedure!")
}, error = function(e) {
  print(paste("❌ Error: ", e$message))
})

# Define the procedure call parameters with non-existent values
incident_id_new <- 'i33'
flight_number_new <- 9999
incident_type_new <- 'turbulence'
severity_new <- 'major'
incident_date_new <- '2023-05-15'
delay_mins_new <- 30
num_injuries_new <- 1
reported_by_new <- 'crew'
airline_code_new <- 'XYZ'  # Non-existent airline code
airport_code_new <- 'PVG'  # Non-existent airport code
aircraft_model_new <- 'XYZ-123'  # Non-existent aircraft model

# Try to call the stored procedure with the parameters (non-existent entries)
tryCatch({
  # Call the stored procedure with new non-existent values
  dbExecute(con, paste0("CALL storeNewIncident('", incident_id_new, "', ", flight_number_new, ", '", incident_type_new, "', '", severity_new, "', '", incident_date_new, "', ", delay_mins_new, ", ", num_injuries_new, ", '", reported_by_new, "', '", airline_code_new, "', '", aircraft_model_new, "', '", airport_code_new, "');"))
  
  # Fetch the newly inserted incident (even with non-existent values)
  fetch_query_non_existent <- paste0("SELECT * FROM Incident WHERE iid = '", incident_id_new, "';")
  rs_non_existent <- dbSendQuery(con, fetch_query_non_existent)
  data_non_existent <- fetch(rs_non_existent, n = -1)  # Fetch all rows
  print(data_non_existent)
  # Clear the result set
  dbClearResult(rs_non_existent) 
  
  print("✅ New incident successfully stored via storeNewIncident procedure!")
}, error = function(e) {
  print(paste("❌ Error: ", e$message))
})

# Close the database connection
dbDisconnect(con)
