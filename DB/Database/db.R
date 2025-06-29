install.packages("RSQLite")
library(RSQLite)
dbfile <- "CoffeeDB.sqlitedb"
conn <- dbConnect(SQLite(), dbfile)

dbExecute(conn, "
  CREATE TABLE coffees (
    id INTEGER PRIMARY KEY,
    coffee_name TEXT,
    price REAL
  );
")

dbExecute(conn, "
  INSERT INTO coffees (coffee_name, price) VALUES
    ('Espresso', 2.5),
    ('Latte', 3.5),
    ('Cappuccino', 3.0);
")
dbListTables(conn)
dbListFields(conn, "coffees")
dbGetQuery(conn, "SELECT * FROM coffees")

p <- 2

sql <- "select coffee_name as coffee, price
        from coffees
        where price > "
sql <- paste0(sql, p)

rs <- dbGetQuery(conn, sql)

print(rs)


minP <- 1
maxP <- 3

sql <- "select coffee_name as coffee, price
        from coffees
        where price between ? and ?"

rs <- dbSendQuery(conn, sql, params = list(minP, maxP))
dbFetch(rs)
print(rs)


rs <- dbReadTable(conn, "coffees")
head(rs, 3)


rs <- dbReadTable(conn, "coffees")

# let's write all of the data to an archive table, but let's delete the old
# table first
dbRemoveTable(conn, "arx_coffees", fail_if_missing = F)
dbWriteTable(conn, "arx_coffees", rs, append = T)

# and read it back to see if it worked
rs <- dbReadTable(conn, "arx_coffees")

tail(rs, 1)
