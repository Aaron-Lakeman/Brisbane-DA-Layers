library(sf)
library(tidyverse)
library(mapview)

# API call with filtering: Where title != "Tennyson" AND title != "Exhibition"
# To be modified when Cross River Rail Opens
station_url <- "https://data.brisbane.qld.gov.au/api/explore/v2.1/catalog/datasets/railway-station-facilities/exports/geojson?where=title%20!%3D%20%22Tennyson%22%20AND%20title%20!%3D%20%22Exhibition%22"

# API call with filtering: 
# Select "zone_prec_desc", "geo_shape"
# Where zone_prec_desc = "LMR2 - Low-medium density residential (3 or 4 storey mix)"
LMR_url <- "https://data.brisbane.qld.gov.au/api/explore/v2.1/catalog/datasets/cp14-zoning-overlay/exports/geojson?select=%22zone_prec_desc%22%2C%20%22geo_shape%22&where=zone_prec_desc%20%3D%20%22LMR2%20-%20Low-medium%20density%20residential%20(3%20or%204%20storey%20mix)%22"

# Read into R
stations <- st_read(station_url)
LMR <- st_read(LMR_url)

# Reproject into GDA2020 / MGA Zone 56
brisbane_crs <- 7856
stations_proj <- st_transform(stations, brisbane_crs)
LMR_proj <- st_transform(LMR, brisbane_crs)

# 400m buffer
station_buffers <- st_buffer(stations_proj, dist = 400)

# Spatial Intersection: Find all LMR land that falls within the 400m buffers
# st_union() combines overlapping station buffers into one continuous polygon shape
lmr_near_stations <- st_intersection(LMR_proj,st_union(station_buffers))

# View the summary
print(lmr_near_stations)

# Map the results
plot(st_geometry(station_buffers), border = "lightblue", main = "LMR Land Within 400m Buffer")
plot(st_geometry(lmr_near_stations), col = "salmon", border = NA, add = TRUE)

station_buffers_clean <- station_buffers %>%
  select(-ln, -stops, -facility)

# Interactive Map
mapview(lmr_near_stations, col.regions = "salmon", layer.name = "LMR Land") + 
  mapview(station_buffers_clean, col.regions = "lightblue", layer.name = "400m Buffers")