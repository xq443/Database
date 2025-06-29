# Date: 2025-05-11
# Semester: Summer 2025
# Author: Xujia Qin
# Title: Assignment 02.1 / Summarize Data

#' Summarize Orders from CSV Files in a Folder
#'
#' This function scans a specified folder dir for CSV files, aggregates order data, 
#' and provides a summary of the orders including:
#' - Total number of unique products and customers
#' - The most ordered product by total quantity
#' - The customer who ordered the most by quantity
#'
#' @param folder A string representing the path dir to the folder containing CSV files.
#' @return NULL This function outputs the summary directly to the console.
#' @export
#'
summarizeOrders <- function(folder) {
  # Check if the folder exists
  if (!dir.exists(folder)) {
    cat("Input folder does not exist.\n")
    return(invisible(NULL))
  }
  # List only .csv files in the specified folder (non-recursive)
  csv_files <- list.files(path = folder, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(csv_files) == 0) {
    cat("No CSV files found in the folder.\n")
    return(invisible(NULL))
  }
  
  # Initialize empty data frame to hold all orders
  all_orders <- data.frame()
  
  # Load each CSV file and append to all_orders
  for (file in csv_files) {
    data <- tryCatch({
      read.csv(file, stringsAsFactors = FALSE)
    }, warning = function(w) {
      cat(sprintf("Folder %s contains empty files: unable to read CSV (%s)\n", basename(file), conditionMessage(w)))
      return(invisible(NULL))
    }, error = function(e) {
      cat(sprintf("Folder %s contains empty files: unable to read CSV (%s)\n", basename(file), conditionMessage(e)))
      return(invisible(NULL))
    })
    
    # Skip files that failed to read
    if (is.null(data)) next
    
    # Make sure required columns exist
    if (!all(c("Customer.ID", "Order.Data", "Product.ID", "Quantity") %in% names(data))) {
      cat(sprintf("Skipping %s: missing required columns.\n", basename(file)))
      next
    }
    
    all_orders <- rbind(all_orders, data)
  }
  
  # If no valid data was loaded
  if (nrow(all_orders) == 0) {
    cat("No valid order data found.\n")
    return(invisible(NULL))
  }
  
  # Calculate analytics
  unique_customers <- length(unique(all_orders$`Customer.ID`))
  unique_products <- length(unique(all_orders$`Product.ID`))
  num_files <- length(csv_files)
  
  # Product ordered the most (by total quantity)
  product_summary <- aggregate(Quantity ~ `Product.ID`, data = all_orders, sum)
  top_product <- product_summary[which.max(product_summary$Quantity), "Product.ID"]
  
  # Customer who ordered the most (by total quantity)
  customer_summary <- aggregate(Quantity ~ `Customer.ID`, data = all_orders, sum)
  top_customer <- customer_summary[which.max(customer_summary$Quantity), "Customer.ID"]
  
  # Output summary
  cat(sprintf("Scanned %d files containing a total of %d unique products being ordered by %d unique customers.\n",
              num_files, unique_products, unique_customers))
  cat(sprintf("Product %s was ordered the most.\n", top_product))
  cat(sprintf("Customer %s ordered the most by quantity.\n", top_customer))
}

# Import the library for unit testing
library(testthat)

#' Unit Tests for summarizeOrders Function
#'
#' This function runs a series of test cases to verify the functionality of the 
#' summarizeOrders function. It checks for different folder scenarios:
#' - Valid folder with CSV files
#' - Folder with no CSV files
#' - Non-existent folder
#' - Folder containing empty CSV files
#'
#' @return NULL The function does not return any values but outputs test results.
#' @export
#'
main <- function() {
  library(testthat)
  
  test_that("TEST CASE 1: Normal folder with valid files", {
    output <- capture.output(summarizeOrders("~/Desktop/QueryTabularData.Qin/CS5200.SummarizeOrders.Qin/orders"))
    expected <- c(
      "Scanned 10 files containing a total of 100 unique products being ordered by 30 unique customers.",
      "Product P017 was ordered the most.",
      "Customer C028 ordered the most by quantity."
    )
    expect_equal(output, expected)
  })
  
  test_that("TEST CASE 2: Folder exists but has no CSV files", {
    output <- capture.output(summarizeOrders("~/Desktop/QueryTabularData.Qin/CS5200.SummarizeOrders.Qin/empty"))
    
    expected <- c("No CSV files found in the folder." )
    expect_equal(output, expected)
  })
  
  test_that("TEST CASE 3: Folder does not exist", {
    output <- capture.output(summarizeOrders("~/Desktop/QueryTabularData.Qin/CS5200.SummarizeOrders.Qin/order"))
    expected <- c("Input folder does not exist.")
    expect_equal(output, expected)
  })
  
  test_that("TEST CASE 4: Folder contains empty CSV files", {
    output <- capture.output(summarizeOrders("~/Desktop/QueryTabularData.Qin/CS5200.SummarizeOrders.Qin/emptycsv"))
    expect_true(any(grepl("Folder .* contains empty files: unable to read CSV", output)))
    expect_true(any(grepl("No valid order data found", output)))
  })
}

# Run main
main()