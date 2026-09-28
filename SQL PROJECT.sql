-- MySQL PROJECT - DATA CLEANING


Select *
from layoffs;

# STEP 1: REMOVE DUPLICATES
# STEP 2: STANDARDIZE THE DATA
# STEP 3: NULL VALUES/MISSING VALUES
# STEP 4: REMOVE UNECESSARY COLUMNS AND ROWS


CREATE TABLE layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;


-- STEP 1 - DUPLICATES

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

select *
from layoffs_staging
where company = 'Casper';



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over( 
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

delete
from layoffs_staging2
where row_num > 1;


# STEP 2 - STANDARDIZE

# we are trying to get rid of the white spaces in the company names just to have a clean looking data name
select company, trim(company)
from layoffs_staging2
;

update layoffs_staging2
set company = trim(company);

# next we will look at the industry
select distinct industry
from layoffs_staging2
order by 1;
# we have seen that there crypto, cryptocurrency, crypto currency, so we will merge that into just one industry

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

# next we look at the country, where there are values recorded in United States with a dot at the end
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

# Let us look at the date now
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');
# at this point, the date has been changed but it is still in the text format 

alter table layoffs_staging2
modify column `date` date;


-- STEP 3 - NULL

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where company = 'Bally%';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;


-- STEP 4 - REMOVE ROWS AND COLUMNS

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

DELETE 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;
