# ---------------------------------------------------------------
# Assignment: Build Triggers in SQLite
# Date: 2025-05-28
# Author: Xujia Qin
# ---------------------------------------------------------------

# -------------------------
# Step 0: Load necessary library
# Connect to the SQLite database in the current project folder
# -------------------------
library(RSQLite)
con <- dbConnect(SQLite(), dbname = "OrdersDB.sqlitedb.db")


# -------------------------
# Step 1: List all tables & schema in the database
# -------------------------
tables <- dbListTables(con)
cat("Tables in the database:\n")
print(tables)

cat("\nSchema of each table:\n")
for (table_name in tables) {
  cat("\n--- Schema for table:", table_name, "---\n")
  schema <- dbGetQuery(con, paste0("PRAGMA table_info(", table_name, ");"))
  print(schema)
}


# -------------------------
# Step 2: ALTER TABLE: Add a new column 'Total' to the 'Orders' table
# The 'Total' column will store positive fractional values (e.g., 12.30)
# -------------------------
alter_query <- "ALTER TABLE Orders ADD COLUMN Total NUMERIC CHECK (Total > 0);"
dbExecute(con, alter_query)
cat("\nAdded 'Total' column to Orders table.\n")

# -------------------------
# Step 3: Update Orders.Total with calculated totals
# -------------------------
update_total_query <- "
  UPDATE Orders
  SET Total = (
    SELECT SUM(od.Quantity * p.Price)
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = Orders.OrderID
);"
dbExecute(con, update_total_query)
cat("Updated Orders.Total with calculated total values.\n")


# -------------------------
# Step 4: Create AFTER INSERT Trigger on OrderDetails
# -------------------------
after_insert_trigger <- "
CREATE TRIGGER IF NOT EXISTS trg_recalc_total_after_insert
AFTER INSERT ON OrderDetails
BEGIN
  UPDATE Orders
  SET Total = (
    SELECT SUM(od.Quantity * p.Price)
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = NEW.OrderID
  )
  WHERE OrderID = NEW.OrderID;
END;"
dbExecute(con, after_insert_trigger)
cat("Created AFTER INSERT trigger on OrderDetails.\n")


# -------------------------
# Step 5: Create AFTER UPDATE Trigger on OrderDetails
# -------------------------
after_update_trigger <- "
CREATE TRIGGER IF NOT EXISTS trg_recalc_total_after_update
AFTER UPDATE ON OrderDetails
BEGIN
  UPDATE Orders
  SET Total = (
    SELECT SUM(od.Quantity * p.Price)
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = NEW.OrderID
  )
  WHERE OrderID = NEW.OrderID;
END;"
dbExecute(con, after_update_trigger)
cat("Created AFTER UPDATE trigger on OrderDetails.\n")


# -------------------------
# Step 6: Create AFTER DELETE Trigger on OrderDetails
# -------------------------
after_delete_trigger <- "
CREATE TRIGGER IF NOT EXISTS trg_recalc_total_after_delete
AFTER DELETE ON OrderDetails
BEGIN
  UPDATE Orders
  SET Total = (
    SELECT SUM(od.Quantity * p.Price)
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = OLD.OrderID
  )
  WHERE OrderID = OLD.OrderID;
END;"
dbExecute(con, after_delete_trigger)
cat("Created AFTER DELETE trigger on OrderDetails.\n")


# -------------------------
# Step 7: Test trigger functionality
# -------------------------
cat("\n--- Testing triggers ---\n")

# Select an existing order ID to test with
test_order <- dbGetQuery(con, "SELECT OrderID FROM Orders LIMIT 100;")
test_order_id <- test_order$OrderID[10]
cat(sprintf("test_order_id: %d\n", test_order_id)) # e.g., test_order_id: 10257

# Get the initial total
initial_total <- dbGetQuery(con, sprintf("SELECT Total FROM Orders WHERE OrderID = %d;", test_order_id))$Total
cat(sprintf("Initial Total: %.2f\n", initial_total))

# Check price of ProductID = 1
product_info <- dbGetQuery(con, "SELECT ProductID, ProductName, Price FROM Products WHERE ProductID = 1;")
product_price <- product_info$Price
cat(sprintf("ProductID = %d (%s), Price = %.2f\n", product_info$ProductID, product_info$ProductName, product_price))

# ----- Test INSERT -----
test_insert <- sprintf("
  INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
  VALUES (%d, 1, 5);", test_order_id)
dbExecute(con, test_insert)
cat(sprintf("Inserted new OrderDetail (ProductID = 1, Quantity = 5) for OrderID %d\n", test_order_id))

# Verify new total
post_insert_total <- dbGetQuery(con, sprintf("SELECT Total FROM Orders WHERE OrderID = %d;", test_order_id))$Total
cat(sprintf("Post-insert Total: %.2f (Expected: %.2f)\n", post_insert_total, initial_total + 5 * product_price))

# ----- Test UPDATE -----
test_update <- sprintf("
  UPDATE OrderDetails
  SET Quantity = 10
  WHERE OrderID = %d AND ProductID = 1;", test_order_id)
dbExecute(con, test_update)
cat("Updated OrderDetail quantity to 10\n")

# Verify updated total
post_update_total <- dbGetQuery(con, sprintf("SELECT Total FROM Orders WHERE OrderID = %d;", test_order_id))$Total
cat(sprintf("Post-update Total: %.2f (Expected: %.2f)\n", post_update_total, initial_total + 10 * product_price))

# ----- Test DELETE -----
test_delete <- sprintf("
  DELETE FROM OrderDetails
  WHERE OrderID = %d AND ProductID = 1;", test_order_id)
dbExecute(con, test_delete)
cat("Deleted OrderDetail entry\n")

# Verify total reset
post_delete_total <- dbGetQuery(con, sprintf("SELECT Total FROM Orders WHERE OrderID = %d;", test_order_id))$Total
cat(sprintf("Post-delete Total: %.2f (Expected: %.2f)\n", post_delete_total, initial_total))


# -------------------------
# Step 8: Clean up and disconnect
# -------------------------
dbDisconnect(con)
