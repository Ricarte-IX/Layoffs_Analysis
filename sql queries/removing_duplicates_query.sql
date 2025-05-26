-- Create a new table as a duplicate for the dataset.
-- Why? So that we can rollback to our original dataset when we perform an incorrect query  
SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- REMOVING DUPLICATES
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY 
		company, 
		industry, 
		total_laid_off, 
		percentage_laid_off, 
		`date`, 
		stage, 
		country, 
		funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicates_cte AS (
	SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY 
			company, 
			location, 
			industry, 
			total_laid_off, 
			percentage_laid_off, 
			`date`, 
			stage, 
			country, 
			funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT * 
FROM duplicates_cte
WHERE row_num > 1
;	

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a new table for removing the duplicates
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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY 
	company, 
    location, 
    industry, 
    total_laid_off, 
    percentage_laid_off, 
    `date`, 
    stage, 
    country, 
    funds_raised_millions) AS row_num
FROM layoffs_staging; 

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE company = 'Casper';