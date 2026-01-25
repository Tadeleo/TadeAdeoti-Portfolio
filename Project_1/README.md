# Bayesian Spatiotemporal Analysis of the Nature and Patterns of Crime Risk in Abuja, Nigeria (2012–2021)

## Project Overview
This project applies **Bayesian Spatiotemporal Modeling** to analyze crime patterns in Abuja, Nigeria, over a 10-year period. Moving beyond traditional descriptive statistics, this study estimates the **Relative Risk (RR)** of Homicide and Robbery incidents across various localities to assist in strategic police resource allocation.

## Key Insights
* **Temporal Hotspots:** Criminal activity peaks significantly between **12:00 AM – 6:00 AM**.
* **High-Risk Localities:** The heatmap reveals a progressive intensification of crime volume across the Federal Capital Territory, peaking in 2021 with 6,707 reported cases, which represents a 70% increase since 2012. Maitama, Lugbe, and Garki emerge as persistent hotspots throughout the decade, while the 2019 data indicates a significant reporting anomaly that was immediately followed by a sharp rebound in criminal activity during 2020
* **Crime Prevalence:** The relative risk map demonstrates a high prevalence of crime in Maitama, Trademark, Garki and Wuse, where the risk of incidents is disproportionately higher than the regional average relative to their population densities.

## Tech Stack & Methodology
* **R Packages:** `sf` (Spatial Data), `tidyverse` (Data Wrangling), `viridis` (Color Scaling), `ggplot2` (Visualization).
* **Preprocessing:** Data cleaning and standardization conducted in Excel prior to Bayesian modeling.
* **Spatial Data:** Shapefile (.shp) and .dbf processing for 11 primary Abuja localities.
* **Analysis:** Relative Risk (RR) calculation using Observed vs. Expected crime counts based on population-weighted global rates.

## Project Structure
* `/data`: Cleaned CSVs (Homicide, Robbery, Spatiotemporal modeling data).
* `/scripts`: R scripts for data joining, RR calculation and faceted mapping.
* `/output`: Spatiotemporal faceted maps showing annual risk evolution.

## Visualizations
### Spatiotemporal Relative Risk (Homicide and Robbery)
The faceted maps illustrate how risk intensity shifted from the city center to the suburban fringes over the decade.
![Relative Risk Map](https://your-image-link-here.com/faceted_map.png)

## Technical Paper
This analysis is based on the research paper: *“Bayesian Analysis of the Nature and Patterns of Crime Risk in Abuja, Nigeria (2012-2021)”* by Adeoti & Ajibade.
