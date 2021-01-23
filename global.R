# prerequisites
require(tidyverse)
require(rnaturalearth)
require(sf)
require(rgeos)
require(leaflet)
require(RColorBrewer)
require(shiny)
require(shinyWidgets)

require(conflicted)
conflict_prefer("addLegend", "leaflet")
conflict_prefer("filter", "dplyr")

url <- "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv"
file <- "data/global-mobility-report.csv"

if(!file.exists(file) | as.Date(file.info(file)$ctime) != Sys.Date()) {
	
	try(download.file(url, destfile = file), silent = T)
}

dat <- read_csv(file) %>%
	filter(is.na(sub_region_1)) %>%
	rename(iso_a2 = country_region_code, country = country_region) %>%
	select(-sub_region_1, -sub_region_2) %>%
	gather("category", "mobility", -iso_a2, -country, -iso_3166_2_code, -census_fips_code, -date, ) %>%
	mutate(category = str_to_title(
		str_replace_all(str_replace(category, "_percent_change_from_baseline", ""), "_", " ")
	))

data_attribution = paste(
	"<a href = 'https://www.google.com/covid19/mobility/'>Google LLC</a>",
	"Google COVID-19 Community Mobility Reports, Accessed: ",
	Sys.Date()
)

sf <- ne_countries(scale = 110, returnclass = "sf") %>%
	mutate(name = admin) %>%
	select(name, iso_a2)

sf_attribution <- "Made with <a href = 'naturalearthdata.com'>Natural Earth</a>"