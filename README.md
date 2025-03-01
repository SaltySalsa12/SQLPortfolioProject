# COVID-19 Data Analysis Using SQL

## Dashboard
![Dashboard 1 (1)](https://github.com/user-attachments/assets/b91fb0e6-b08b-49c1-8776-aa4b26fc3753)

## Overview
This project analyzes COVID-19 data using SQL queries to gain insights into cases, deaths, vaccinations, and trends worldwide. The dataset comes from the `PortfolioProject..CovidDeaths` and `PortfolioProject..CovidVaccinations` tables.

The queries cover key aspects such as:
- Total cases vs. total deaths
- Infection rate relative to population
- Death percentage calculations
- Total population vs. vaccinations
- Rolling vaccination statistics using window functions
- Aggregations by location and continent

## Dataset
The dataset includes two tables:
1. **CovidDeaths**
   - `location`
   - `date`
   - `total_cases`
   - `new_cases`
   - `total_deaths`
   - `new_deaths`
   - `population`
   - `continent`
2. **CovidVaccinations**
   - `location`
   - `date`
   - `new_vaccinations`
   - `total_vaccinations`

## SQL Queries and Analysis

### 1. Total Deaths by Location on a Specific Date
```sql
SELECT location, SUM(new_deaths)
FROM PortfolioProject..CovidDeaths
WHERE date = '2020-01-05 00:00:00.000' AND continent IS NOT NULL
GROUP BY location
ORDER BY 1,2;
```

### 2. Total Cases vs Total Deaths (United States)
```sql
SELECT location, date, total_cases, total_deaths,
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;
```

### 3. Infection Rate Relative to Population (Canada)
```sql
SELECT location, date, total_cases, population,
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;
```

### 4. Countries with the Highest Infection Rate
```sql
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC;
```

### 5. Countries with the Highest Death Count
```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
```

### 6. Total Deaths by Continent
```sql
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

### 7. Global Death Percentage Over Time
```sql
SELECT date, SUM(new_cases) AS TotalCases,
       SUM(CAST(new_deaths AS FLOAT)) AS TotalDeath,
       SUM(CAST(ISNULL(new_deaths, 0) AS INT)) / SUM(CONVERT(FLOAT, new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;
```

### 8. Total Population vs Vaccinations
```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
```

### 9. Rolling Vaccination Numbers
```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccNumbers
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
```

### 10. Using CTE for Population vs. Vaccination Analysis
```sql
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingVaccNumbers) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccNumbers
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccNumbers / population) * 100 AS PercentVaccinated
FROM popvsvac
ORDER BY 2,3;
```

### 11. Using Temporary Table for Population vs. Vaccination Analysis
```sql
DROP TABLE IF EXISTS #PercentPeopleVaccinated;
CREATE TABLE #PercentPeopleVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingVaccNumbers NUMERIC
);

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccNumbers
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingVaccNumbers / population) * 100 AS PercentVaccinated
FROM #PercentPeopleVaccinated
ORDER BY 2,3;
```

### 12. Creating a View for Visualization
```sql
CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccNumbers
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPeopleVaccinated;
```

## Conclusion
These SQL queries allow us to analyze COVID-19 data effectively by:
- Identifying trends in infections, deaths, and vaccinations.
- Calculating important metrics like death percentages and infection rates.
- Using advanced SQL techniques like `JOIN`, `CTE`, `WINDOW FUNCTIONS`, and `VIEWS` for analysis.
- Preparing data for visualization in BI tools like Power BI or Tableau.

## Future Improvements
- Further optimize queries for performance.
- Integrate more datasets for better insights.
- Automate data extraction and visualization updates.

## Author
SaltySalsa  
a.k.a Yash Shah

## License
MIT License

