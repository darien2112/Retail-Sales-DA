SELECT Customer_ID
        , max([Date]) recent_date
        , DATEDIFF(DAY, max([Date]), DATEFROMPARTS(2016, 12, 31)) recency
        , COUNT(distinct [Date]) frequency
        , SUM(Sales_Amount) monetary
FROM dbo.scanner_data
GROUP BY Customer_ID