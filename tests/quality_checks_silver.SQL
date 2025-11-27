/*
=====================================================
                    Quality Checks
=====================================================

Script Purpose:
    This script performs various quality checks to ensure 
    data consistency, accuracy, and standardization across 
    the 'silver' schemas. It includes checks for:

        -- NULL or duplicate primary keys
        -- Unwanted spaces in string fields
        -- Data standardization and consistency
        -- Invalid date ranges and date order issues
        -- Data consistency between related fields

Usage Notes:
    -- Run these checks after loading data into the Silver layer.
    -- Investigate and resolve any discrepancies found during the checks.

=====================================================
*/


/*=====================================================
  CHECKING :  silver.crm_cust_info
=====================================================*/

--  Check for duplicates in Primary Key (cst_id)
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check for unwanted spaces in cst_key
SELECT 
    cst_key
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);


--  Check for unwanted spaces in customer names
SELECT 
    cst_firstname,
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);


--  Data Standardization Check – Gender & Marital Status
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;



/*=====================================================
  CHECKING : silver.crm_prd_info
=====================================================*/

-- Check for duplicates in Primary Key (prd_id)
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;


--  Check for unwanted spaces in product name
SELECT DISTINCT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


--  Check for negative or NULL values in product cost
SELECT 
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL 
   OR prd_cost < 0;


--  Data Standardization Check – Product Line
SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info;


--  Check for invalid date order (start > end)
SELECT 
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;



/*=====================================================
  CHECKING : bronze.crm_sales_details
=====================================================*/

--  Check for invalid due dates
SELECT
    slc_due_dt
FROM bronze.crm_sales_details
WHERE slc_due_dt < 0
   OR LEN(slc_due_dt) <> 8
   OR slc_due_dt > 20500101
   OR slc_due_dt < 19000101;


-- Check invalid date sequence (order > ship OR order > due)
SELECT 
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


--  Check data consistency (Sales = Quantity * Price, no NULLs or negatives)
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales < 0
   OR sls_quantity < 0
   OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price;



/*=====================================================
  CHECKING : silver.erp_cust_az12
=====================================================*/

--  Check valid birthdates (between 1924-01-01 and today)
SELECT 
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


--  Data Standardization Check – Gender values
SELECT DISTINCT 
    gen
FROM silver.erp_cust_az12;



/*=====================================================
  CHECKING : silver.erp_loc_a101
=====================================================*/

--  Data Standardization Check – Country list
SELECT DISTINCT 
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;



/*=====================================================
  CHECKING : silver.erp_px_cat_g1v2
=====================================================*/

--  Check for unwanted spaces in category fields
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


--  Data Standardization Check – Maintenance field
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;
