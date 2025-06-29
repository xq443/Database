# Program: Practicum II - Part C / Extract, Transform and Load Data
# Author: Xujia Qin
# Semester: SummerI 2025
# Description: This script creates an analytical datamart is to populate the datamart with data for the dimensions and compute (and store) the facts in the fact tables.

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

cat("✅ Cloud Database Connection Succeed.\n")


# Connect to operational DBs
con_film <- dbConnect(SQLite(), "film-sales.db")
con_music <- dbConnect(SQLite(), "music-sales.db")

cat("✅ Local Database Connection Succeed.\n")

# List tables in film_sales
cat("📦 Tables in film_sales.db:\n")
print(dbListTables(con_film))

# List tables in music_sales
cat("📦 Tables in music_sales.db:\n")
print(dbListTables(con_music))


# STEP 1: Load countries from both DBs into dim_country (no duplicates)

# Load film customers first (to get countries)
film_customers <- dbGetQuery(con_film, "
  SELECT customer_id, country FROM customer
  JOIN address USING (address_id)
  JOIN city USING (city_id)
  JOIN country USING (country_id);
")
film_customers$customer_id <- paste0("F_", film_customers$customer_id)
film_customers$media_type <- "film"

# Load music customers (to get countries)
music_customers <- dbGetQuery(con_music, "
  SELECT CustomerId AS customer_id, Country AS country
  FROM customers;
")
music_customers$customer_id <- paste0("M_", music_customers$customer_id)
music_customers$media_type <- "music"

# Now get all unique countries from both
all_countries <- unique(c(film_customers$country, music_customers$country))

for (country in all_countries) {
  country_q <- dbQuoteString(con, country)
  sql <- paste0("INSERT IGNORE INTO dim_country (country) VALUES (", country_q, ");")
  dbExecute(con, sql)
}
cat("✅ dim_country populated with countries.\n")

# STEP 2: Load distinct dates from film rentals and music invoices

film_dates <- dbGetQuery(con_film, "SELECT DISTINCT DATE(rental_date) AS date FROM rental;")
music_dates <- dbGetQuery(con_music, "SELECT DISTINCT DATE(InvoiceDate) AS date FROM invoices;")

all_dates <- unique(c(film_dates$date, music_dates$date))
all_dates <- as.Date(all_dates)

df_dates <- data.frame(
  date = all_dates,
  month = as.integer(format(all_dates, "%m")),
  quarter = paste0("Q", ceiling(as.integer(format(all_dates, "%m")) / 3)),
  year = as.integer(format(all_dates, "%Y"))
)

for (i in seq_len(nrow(df_dates))) {
  row <- df_dates[i, ]
  
  date_q     <- dbQuoteString(con, as.character(row$date))
  quarter_q  <- dbQuoteString(con, row$quarter)
  
  sql <- paste0(
    "INSERT IGNORE INTO dim_date (date, month, quarter, year) VALUES (",
    date_q, ", ", row$month, ", ", quarter_q, ", ", row$year, ");"
  )
  
  dbExecute(con, sql)
}
cat("✅ dim_date table Created.\n")

# STEP 3: Insert customers into dim_customer

# Combine customers
all_customers <- rbind(
  film_customers[, c("customer_id", "country", "media_type")],
  music_customers[, c("customer_id", "country", "media_type")]
)

for (i in seq_len(nrow(all_customers))) {
  c_row <- all_customers[i, ]
  
  customer_id_q <- dbQuoteString(con, c_row$customer_id)
  country_q     <- dbQuoteString(con, c_row$country)
  media_type_q  <- dbQuoteString(con, c_row$media_type)
  
  sql <- paste0(
    "INSERT IGNORE INTO dim_customer (customer_id, country, media_type) VALUES (",
    customer_id_q, ", ", country_q, ", ", media_type_q, ");"
  )
  
  dbExecute(con, sql)
}
cat("✅ dim_customer table Created.\n")

# STEP 4: Load fact_sales — Optimized version

# 1. Load sales data from both DBs
music_sales <- dbGetQuery(con_music, "
  SELECT i.InvoiceDate AS date, 
         CONCAT('M_', i.CustomerId) AS customer_id,
         ii.Quantity AS units_sold, 
         ii.UnitPrice * ii.Quantity AS revenue
  FROM invoice_items ii
  JOIN invoices i ON ii.InvoiceId = i.InvoiceId;
")
music_sales$media_type <- "music"

film_sales <- dbGetQuery(con_film, "
  SELECT r.rental_date AS date, 
         CONCAT('F_', r.customer_id) AS customer_id,
         1 AS units_sold, 
         p.amount AS revenue
  FROM rental r
  JOIN payment p ON r.rental_id = p.rental_id;
")
film_sales$media_type <- "film"

# 2. Combine both
fact_data <- rbind(music_sales, film_sales)

# 3. Load dim_customer once
dim_customer <- dbGetQuery(con, "SELECT customer_id, country FROM dim_customer;")

# 4. Merge to avoid repeated queries
fact_data <- merge(fact_data, dim_customer, by = "customer_id")

# 5. Convert date if needed
fact_data$date <- as.Date(fact_data$date)

# 6. Bulk insert
for (i in seq_len(nrow(fact_data))) {
  f <- fact_data[i, ]
  
  sql <- sprintf(
    "INSERT INTO fact_sales (date, country, customer_id, media_type, units_sold, revenue) VALUES ('%s', '%s', '%s', '%s', %d, %.2f);",
    f$date, f$country, f$customer_id, f$media_type, as.integer(f$units_sold), as.numeric(f$revenue)
  )
  dbExecute(con, sql)
}

cat("✅ fact_sales table inserted with vectorized join.\n")


# Test & Validation Queries

film_us_customers <- dbGetQuery(con_film, "
  SELECT COUNT(DISTINCT customer.customer_id) AS num_customers
  FROM customer
  JOIN address USING (address_id)
  JOIN city USING (city_id)
  JOIN country USING (country_id)
  WHERE country.country = 'United States';
")

music_us_customers <- dbGetQuery(con_music, "
  SELECT COUNT(DISTINCT CustomerId) AS num_customers
  FROM customers
  WHERE Country IN ('USA', 'United States');
")

analytics_us_customers <- dbGetQuery(con, "
  SELECT media_type, COUNT(DISTINCT customer_id) AS num_customers
  FROM dim_customer
  WHERE country IN ('United States', 'USA')
  GROUP BY media_type;
")

cat("US Customers in film_sales.db:", film_us_customers$num_customers, "\n")
cat("US Customers in music_sales.db:", music_us_customers$num_customers, "\n")
cat("US Customers in analytics dim_customer table:\n")
print(analytics_us_customers)

# Sum all media_type customer counts
analytics_total_customers <- sum(analytics_us_customers$num_customers)

# Validate counts
if (film_us_customers$num_customers + music_us_customers$num_customers == analytics_total_customers) {
  cat("✅ Customer counts from film_sales and music_sales match total in dim_customer.\n")
} else {
  cat("⚠️ Mismatch in customer counts! Please check the transformation logic.\n")
}


# Disconnect
dbDisconnect(con)
cat("✅ Database has been disconnected.\n")
