# Program: Practicum II - Part B / Create Analytics Datamart
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: This script creates fact and dimension tables into which we will then extract data from the operational databases.

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

# Drop tables if rerunning (drop fact first to avoid FK conflicts)
dbExecute(con, "DROP TABLE IF EXISTS fact_sales;")
dbExecute(con, "DROP TABLE IF EXISTS dim_customer;")
dbExecute(con, "DROP TABLE IF EXISTS dim_date;")
dbExecute(con, "DROP TABLE IF EXISTS dim_country;")

# Create dim_date table
dbExecute(con, "
  CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    month INT NOT NULL,
    quarter VARCHAR(10) NOT NULL,
    year INT NOT NULL
  );
")

# Create dim_country table — use country name as primary key
dbExecute(con, "
  CREATE TABLE dim_country (
    country VARCHAR(100) PRIMARY KEY
  );
")

# Create dim_customer table — reference country directly
dbExecute(con, "
  CREATE TABLE dim_customer (
    customer_id VARCHAR(100) PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    media_type VARCHAR(10) NOT NULL,
    FOREIGN KEY (country) REFERENCES dim_country(country),
    CHECK (media_type IN ('music', 'film'))
  );
")

# Create fact_sales table — reference customer, country, and date
dbExecute(con, "
  CREATE TABLE fact_sales (
    sales_id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    country VARCHAR(100) NOT NULL,
    customer_id VARCHAR(100) NOT NULL,
    media_type VARCHAR(10) NOT NULL,
    units_sold INT NOT NULL,
    revenue DOUBLE NOT NULL,
    FOREIGN KEY (date) REFERENCES dim_date(date),
    FOREIGN KEY (country) REFERENCES dim_country(country),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CHECK (media_type IN ('music', 'film'))
  );
")

cat("✅ Fact and Dim Tables Created.\n")

# Disconnect
dbDisconnect(con)
cat("✅ Database has been disconnected.\n")

