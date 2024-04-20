WITH rfm_calcu as (SELECT Customer_ID
        , max([Date]) recent_date
        , DATEDIFF(DAY, max([Date]), DATEFROMPARTS(2016, 12, 31)) recency
        , COUNT(distinct [Date]) frequency
        , SUM(Sales_Amount) monetary
FROM dbo.scanner_data
GROUP BY Customer_ID),

        rfm_rank as (SELECT Customer_ID, recent_date
        , recency
        , NTILE(100) OVER(ORDER by recency DESC) recency_rank
        , frequency
        , NTILE(100) OVER(ORDER by frequency) frequency_rank
        , monetary
        , NTILE(100) OVER(ORDER by monetary) monetary_rank
FROM rfm_calcu ),

    rfm_lvl as (SELECT Customer_ID, recent_date
        , case when recency_rank <= 50 then '1'
            when recency_rank <= 80 then '2'
            when recency_rank <= 100 then '3'
            end as r
        ,case when frequency_rank <= 50 then '1'
            when frequency_rank <= 80 then '2'
            when frequency_rank <= 100 then '3'
            end as f
        ,case when monetary_rank <= 50 then '1'
            when monetary_rank <= 80 then '2'
            when monetary_rank <= 100 then '3'
            end as m    
FROM rfm_rank),

    rfm_tbl as (SELECT *
                , CONCAT(r,f,m) rfm
        FROM rfm_lvl)

SELECT *
        , case when rfm = '333' then 'VIP customer'
            when rfm in ('332','322','232','222','331','231') then 'Loyal customer'
            when rfm in ('323') then 'Potential prospective customers'
            when rfm in ('133','123','223','233','132','131') then 'Risky customer'
            when rfm in ('113','213','212','313') then 'Customer spend a lot'
            when rfm in ('321','312','311','211') then 'New customer'
            when rfm in ('111','112','121','122','221') then 'Low value customer'
        end customer_segmentation
FROM rfm_tbl
order by customer_segmentation
