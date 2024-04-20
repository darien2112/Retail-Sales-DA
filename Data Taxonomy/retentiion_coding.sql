with data_set as (SELECT Customer_ID, [Date] , Quantity, Sales_Amount
        , DATETRUNC(month,[Date]) as mth
from dbo.scanner_data),

        first_mth_tbl as (SELECT Customer_ID
        , MIN(mth) first_mth
FROM data_set
GROUP BY Customer_ID),

        new_cust_tbl as ( SELECT first_mth, COUNT(distinct Customer_ID) as new_customer
FROM first_mth_tbl
GROUP BY first_mth),

        retentio_tbl as (SELECT data_set.Customer_ID, data_set.mth, first_mth_tbl.first_mth
FROM data_set
JOIN first_mth_tbl
ON data_set.Customer_ID = first_mth_tbl.Customer_ID),

        retention1_tbl as (SELECT first_mth, mth, COUNT(distinct Customer_ID) as retention_cust
FROM retentio_tbl
GROUP BY first_mth, mth),

        retention2_tbl as (SELECT  retention1_tbl.first_mth, retention1_tbl.mth, retention1_tbl.retention_cust, new_cust_tbl.new_customer
FROM retention1_tbl
JOIN new_cust_tbl
        ON retention1_tbl.first_mth = new_cust_tbl.first_mth
)

SELECT *
        , ROUND(100.0*retention_cust/new_customer,2) as retention_rate
FROM retention2_tbl
ORDER by first_mth, mth