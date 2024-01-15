SELECT * 
from [dbo].[covid deaths (1)]
Where continent is not null

-- Selecting the Data to be Used

Select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[covid deaths (1)]
Order by 1,2

-- Total cases v Total deaths 

Select location,date,total_cases,total_deaths,(total_cases/total_deaths)
from [dbo].[covid deaths (1)]
Order by 1,2

-- Calculating Death Percentage

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[covid deaths (1)]
Order by 1,2

-- Estimating Total Death Count

Select location,Max(Cast(total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths (1)]
Where continent is not null
Group BY location
Order by TotalDeathCount desc

-- Categorising by Location 

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths (1)]
Where continent is null
Group BY location
Order by TotalDeathCount desc

-- Showing continents with the highest deathcount per population

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths (1)]
Where continent is not null
Group BY continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases,SUM(Cast(new_deaths as int)) as TotalDeaths,(SUM(Cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from [dbo].[covid deaths (1)]
where continent is not null
Order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





-- Queries for Tableau Project

--1

Select SUM(new_cases) as TotalCases,SUM(Cast(new_deaths as int)) as TotalDeaths,(SUM(Cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from [dbo].[covid deaths (1)]
where continent is not null
Order by 1,2

--2

Select location,SUM(Cast(new_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths (1)]
--where location like '%states%'
where continent is null
and location not in ('World','European Union','International')
Group by location
Order by TotalDeathCount desc

--3

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [dbo].[covid deaths (1)]
--where location like '%states%'
Group BY location, population
Order by PercentPopulationInfected desc

--4

Select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [dbo].[covid deaths (1)]
--where location like '%states%'
Group BY location, population, date
Order by PercentPopulationInfected desc


-- DATA CLEANING

Select *
from [dbo].[Nashville Housing Data for Data Cleaning (1)]

-- Standardize Date Format

Select SaleDateConverted,CONVERT(Date,SaleDate) 
from [dbo].[Nashville Housing Data for Data Cleaning (1)]


ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add SaleDateConverted Date;

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address 


Select *
from [dbo].[Nashville Housing Data for Data Cleaning (1)]
--where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [dbo].[Nashville Housing Data for Data Cleaning (1)] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning (1)] b
   On a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Nashville Housing Data for Data Cleaning (1)] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning (1)] b
   On a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

-- Breaking out Adress into different columns (Address,city,state) 

Select PropertyAddress
from [dbo].[Nashville Housing Data for Data Cleaning (1)]
--where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [dbo].[Nashville Housing Data for Data Cleaning (1)]

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add PropertySplitAddress NVarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add PropertySplitCity NVarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
from [dbo].[Nashville Housing Data for Data Cleaning (1)]

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from [dbo].[Nashville Housing Data for Data Cleaning (1)]

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add OwnerSplitAddress NVarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add OwnerSplitCity NVarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
Add OwnerSplitState NVarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning (1)]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select *
from [dbo].[Nashville Housing Data for Data Cleaning (1)]

-----------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
Select*,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID
				 )row_num

from [dbo].[Nashville Housing Data for Data Cleaning (1)]
)
Delete
From RowNumCTE
Where Row_Num > 1


-------------------------------------------------------------------------------

--Deleting Unused Columns

Select*
from [dbo].[Nashville Housing Data for Data Cleaning (1)]

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (1)]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

Select*
from [dbo].[Nashville Housing Data for Data Cleaning (1)]