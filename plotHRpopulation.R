###############################################################################
## map Karnataka's population in its homogenous regions using district shp-file
## Author: Jay Kulkarni ##
## Date: 09-08-2023 ##
###############################################################################

## load libraries ##
library(readr)
library(sf)
library(dplyr)
library(tmap)

## note url of the zipped shapefile ##
url <- "https://github.com/JKAY3366/karnataka_pop_by_hr/raw/main/District.zip"
# File name you want to save locally
local_filename <- basename(url)

# Download the file to your working directory
download.file(url, destfile = local_filename, method = "auto")

if (file.exists(local_filename)) {
  cat("File downloaded successfully:", local_filename, "\n")
} else {
  cat("File download failed.\n")
}

# unzip shapefile
unzip(local_filename)

# read shapefile using sf package
shapefile <- st_read("District.shp")

# read csv file: Karnataka districts matched with CMIE's homogenous regions
df <- 
  read_csv("https://github.com/JKAY3366/karnataka_pop_by_hr/raw/main/districtHRmatched.csv")

shapefile <- left_join(shapefile, df, by = "KGISDist_1")

# Perform the dissolve operation
shp_dissolved <- shapefile %>%
  group_by(!!sym("HR")) %>%
  summarise()

shp_dissolved <- st_sf(geometry = shp_dissolved)
plot(shp_dissolved)

# read csv file: contains HR matched with population
df2 <- 
  read_csv("https://github.com/JKAY3366/karnataka_pop_by_hr/raw/main/karnataka_hr_populn.csv",
                col_types = cols(...1 = col_skip()))

shp_dissolved <- left_join(shp_dissolved, df2, by = "HR")

## Nice Plot using tmap ##
map<- qtm(shp_dissolved, fill = "Population", fill.palette = "Greens", 
    contrast=1.2, text = "HR", 
    text.size = 0.50)+ 
  tm_legend(legend.position = c("left", "top"),
            legend.text.size = 1,
            main.title = "Karnataka population by CMIE's homogenous regions",
            main.title.position = "left",
            main.title.size = 0.9)+
  tm_layout(legend.outside = TRUE ,
            legend.outside.position= c("right"), 
            frame.lwd = 0.2, 
            legend.text.size = 0.8)+
  tmap_style("watercolor")

# Save the map as a PNG image
tmap_save(map, filename = "thematic_map.png", 
          width = 10, height = 6, units = "in", dpi = 300)

## free up space ##
rm(list = ls())
################################################################################
