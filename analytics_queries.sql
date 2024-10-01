-- This query is looking at top 5 most viewed wikipedia sites based on page views
select  wiki,sum(views) as total_views
from `bigquery-public-data.wikipedia.pageviews_2023`
where DATE(datehour) >= "2023-01-01" 
group by 1
order by 2 desc
limit 5


-- This query is looking for the most viewed title by page views for each wikipedia site
WITH base AS (
    select
        title,
        wiki,
        sum(views) as total_page_views
    from `bigquery-public-data.wikipedia.pageviews_2023`
    where DATE(datehour) >= "2023-12-30"
    group by title, wiki
),

ranked_pages AS (
    select 
        title,
        total_page_views as views,
        wiki,
        row_number() over (partition by wiki order by total_page_views desc) as search_ranking
    from base
)

select *
from ranked_pages
where search_ranking = 1
order by wiki


  -- This query is giving us a aggregated look at the sum of views to all wikipedia sites by month
select 
     format_date('%Y-%m',datehour) as month
     , sum(views) as total_views
from `bigquery-public-data.wikipedia.pageviews_2023` 
where date(datehour) >= "2023-01-01" 
group by 1
order by 1

  
-- This query is giving us percent of traffic that the top 5 wikipedia sites account for 
with total_views_all_sites as (
    select sum(views) as total_views
    from `bigquery-public-data.wikipedia.pageviews_2023`
    where DATE(datehour) >= "2023-12-30"
)
select 
  wiki,
  (sum(views) / (select total_views from total_views_all_sites)) * 100 as traffic_percentage
from 
  `bigquery-public-data.wikipedia.pageviews_2023`
where 
  DATE(datehour) >= "2023-12-30" 
  and wiki in ("en","en.m","ru.m","ja.m","es.m")
group by wiki
order by traffic_percentage desc;


