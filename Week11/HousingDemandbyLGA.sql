/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Local_government_area]
      ,[LGA_CODE22]
      ,[State]
      ,[Households_at_2021]
      ,[Current_unmet_need_Estimate]
      ,[Current_unmet_need_all_households]
      ,[Source_of_unmet_need_Q1_rent_stress]
      ,[Source_of_unmet_need_Q2_rent_stress]
      ,[Source_of_unmet_need_Manifest_homeless]
      ,[Current_social_housing_at_2021]
      ,[Current_social_housing_all_need_met_unmet]
      ,[Projected_need_by_2041_Estimate]
      ,[Projected_need_by_2041_As_annual_SH_growth]
      ,[Projected_need_by_2041_As_average_annual_build]
  FROM [bronze].[dbo].[LGA]

  -- Inspecting data
  -- Total distinct record count between LGA name and Code should match
  select count(distinct local_government_area),count(distinct lga_code22)
  from [bronze].[dbo].[LGA];

  -- Rental stress would mean finding difficulties on living in rental properties by LGA(Council)
  select * 
   from [bronze].[dbo].[LGA];

   -- Households_at_2021 -- total housing no by 2021
   -- Current_unmet_need_Estimate -- unmet need estimate ( housing shortage) 
   -- (Source_of_unmet_need)-- Rental stress would mean finding difficulties on living in rental properties by LGA(Council)
   --
-- key insights
-- isnumeric function will check if the column is numeric or not. isnumeric(column_name) = 0 --non-numeric value
select 
distinct 
	Current_unmet_need_Estimate
from 
	[bronze].[dbo].[LGA] 
where isnumeric(Current_unmet_need_Estimate) = 0

-- if <100 -- change this to 99

-- Top 10 unmeet needs by local government area across australia
select 
distinct top 10
	case when Current_unmet_need_Estimate = '<100' then 99 else Current_unmet_need_Estimate end as Current_unmet_need_Estimate,
	state,
	Local_government_area
from 
	[bronze].[dbo].[LGA] 
order by 1 desc;

select 
distinct top 10
	Current_unmet_need_all_households,
	state,
	Local_government_area
from 
	[bronze].[dbo].[LGA] 
order by 1 desc;

-- Find unmet estimates broken down by state
-- CTE -- common table expression 
-- Housing shortage bhako (unmet_need)top 10 local_government_area nikalyam by state
create view top10LGAbystate as 
with get_unmet_needbystate as 
(
select 
distinct   
	case when Current_unmet_need_Estimate = '<100' then 99 else Current_unmet_need_Estimate end as Current_unmet_need_Estimate,
	state,
	Local_government_area,
	ROW_NUMBER() over(partition by state order by current_unmet_need_estimate desc) row_num,
	avg(case when Current_unmet_need_Estimate = '<100' then 99 else Current_unmet_need_Estimate end) over(partition by state) avg_unmet_needs
	--
from 
	[bronze].[dbo].[LGA]
--where state = 'NSW'
--order by 4
-- PERCENTILE_CONT -- 0.50 bhane ko median -- within group (Current_unmet_need_Estimate yo field)
-- over(partition by state) ( state wise grouping)
), get_median_housing_shortage as (
select *,
PERCENTILE_CONT(0.50) within group (order by Current_unmet_need_Estimate) over(partition by state) as Median_unmetNeed_Estimate
from get_unmet_needbystate
where row_num <=10
--order by state,row_num
)
select 
case when Current_unmet_need_Estimate > Median_unmetNeed_Estimate then 'Impactful Housing Crisis'
else 'Not Impactful Housing Crisis' end as 'IsImpactful',*
from get_median_housing_shortage


create view top10LGAbystatebyPercent as 
with get_Percent_unmet_needbystate as 
(
select 
distinct   
	cast(replace(Current_unmet_need_all_households ,'-',0) as numeric(19,2)) as Current_unmet_need_all_households,
	state,
	Local_government_area,
	ROW_NUMBER() over(partition by state order by cast(replace(Current_unmet_need_all_households ,'-',0) as numeric(19,2)) desc) row_num,
	avg(cast(replace(Current_unmet_need_all_households ,'-',0) as numeric(19,2))) over(partition by state) avg_unmet_needs
	--
from 
	[bronze].[dbo].[LGA]
--where state = 'NSW'
--order by 4
-- PERCENTILE_CONT -- 0.50 bhane ko median -- within group (Current_unmet_need_Estimate yo field)
-- over(partition by state) ( state wise grouping)
), get_median_housing_shortage as (
select *,
PERCENTILE_CONT(0.50) within group (order by cast(Current_unmet_need_all_households as numeric(19,2))) over(partition by state) as Median_unmetNeed_Estimate
from get_Percent_unmet_needbystate
where row_num <=10
--order by state,row_num
)
select 
case when Current_unmet_need_all_households > Median_unmetNeed_Estimate then 'Impactful Housing Crisis'
else 'Not Impactful Housing Crisis' end as 'IsImpactful',*
from get_median_housing_shortage

select * from top10LGAbystate order by state,row_num;
select * from top10LGAbystatebyPercent order by state,row_num;

select *
from 
	[bronze].[dbo].[LGA]

-- Insights
-- 1. ACT state ko complete aggregated housing no cha ( not broken down by LGA code) 
-- 2. Top 10 LGA by housing shortage
-- 3. Top 10 LGA broken down by state having housing shortage. ( both by total no and by percentage)
-- 4. Give me LGA whose rental stress decline/increase from Q1 to Q2 broken down by states. (HW)
-- 5. Homeless (%) by LGA. (HW)
-- 6. Correlation between unmet estimate vs homeless ( python)

-- check the distribution of social_housing column
select 
case when Current_social_housing_at_2021 = 'negligible' then 0 else Current_social_housing_at_2021 end as Current_social_housing_at_2021

,count(*) -- aggregate function
from 
	[bronze].[dbo].[LGA]
where Current_social_housing_at_2021 <> '-'
group by Current_social_housing_at_2021
order by 2 desc

-- select *
-- FROM <table_name>
-- WHERE <column_name>
-- GROUP BY <column_name>
-- HAVING Agg sum(<column_name) >= value

-- Findings -- 82 records have (-) or blank information.
select Projected_need_by_2041_As_average_annual_build,count(*)
from 
	[bronze].[dbo].[LGA]
group by Projected_need_by_2041_As_average_annual_build

select *
from 
	[bronze].[dbo].[LGA]
where Households_at_2021 <=200



select * 
from 
	[bronze].[dbo].[LGA]
where state = 'ACT'

select * from INFORMATION_SCHEMA.columns where table_name = 'LGA'

