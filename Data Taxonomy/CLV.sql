With repeat_tbl as (SELECT COUNT(Customer_ID) total_cust
        , (SELECT COUNT(Customer_ID) 
        FROM (
        SELECT Customer_ID 
                ,  COUNT(Customer_ID) OVER(partition by Customer_ID ORDER by Date) order_num
        FROM dbo.scanner_data) sub
        where order_num > 1) multiple_purchases_cust
FROM dbo.scanner_data),

        repeat_rate_tbl as (SELECT 1 - round(1.0*multiple_purchases_cust/total_cust,2) repeat_rate
        FROM repeat_tbl),

        scanner_data_price as ( select * 
                , ROUND(Sales_Amount/Quantity,2) price
        FROM dbo.scanner_data),

        Average_order_value_tbl as (SELECT Customer_ID
        , round(1.0*SUM(price)/COUNT(Transaction_ID),2) Average_order_value
        , 1.0*COUNT(distinct Transaction_ID)/(select COUNT(distinct Customer_ID) FROM dbo.scanner_data) Purchase_frequency
        , SUM(price)*0.1 profit_margin
        FROM scanner_data_price
        GROUP by Customer_ID)
        
SELECT  *
        , ROUND(Customer_value / (SELECT 1 - round(1.0*multiple_purchases_cust/total_cust,2) repeat_rate
        FROM repeat_tbl),2) * profit_margin AS CLV
FROM (
 SELECT *
        , round(Average_order_value * Purchase_frequency,2) Customer_value
 FROM Average_order_value_tbl
 ) sub
 ORDER BY Customer_ID

