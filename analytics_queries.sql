-- Looking at top 5 wiki sites based on page views
select  wiki,sum(views) as total_views
from `bigquery-public-data.wikipedia.pageviews_2023`
where DATE(datehour) >= "2023-08-01" 
group by 1
order by 2 desc
limit 5


-- Top viewed title by wikipedia site
WITH base AS (
  select
    title
    , wiki
    , sum(views) as total_page_views
  from `bigquery-public-data.wikipedia.pageviews_2023`
  where DATE(datehour) >= "2023-08-18"
  group by 1,2
)

select * from (
  select title 
        ,total_page_views as views
        , wiki
        , row_number() over(partition by wiki order by total_page_views desc) as search_ranking
  from base 
)
where search_ranking = 1
order by 3


-- percent of traffic top 5 wikipedia sites account for 
with base as (
    select  sum(views) as total_views_all_sites
    from `bigquery-public-data.wikipedia.pageviews_2023`
    where DATE(datehour) >= "2023-08-01" 
    )
,

top_5_sites as (
    select  wiki, sum(views) as total_views_top_5_sites
    from `bigquery-public-data.wikipedia.pageviews_2023`
    where DATE(datehour) >= "2023-08-01" and wiki in ("en","en.m","ru.m","ja.m","es.m")
    group by 1
    )

select 
  top_5_sites.wiki
  ,(top_5_sites.total_views_top_5_sites / base.total_views_all_sites) * 100 AS traffic_percentage
from
  top_5_sites
  cross join base
order by 2 desc
