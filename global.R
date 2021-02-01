# prerequisites
require(tidyverse)
require(rnaturalearth)
require(sf)
require(rgeos)
require(leaflet)
require(RColorBrewer)
require(shiny)
require(shinyWidgets)
require(colorspace)

require(conflicted)
conflict_prefer("addLegend", "leaflet")
conflict_prefer("filter", "dplyr")

# source shared variables used by update_data cron job and app
source("shared_vars.R")


# if(!dir.exists("data")) { dir.create("data") }
# if(!file.exists(file) | as.Date(file.info(file)$mtime) != Sys.Date()) {
# 	
# 	temp <- try(read_csv(url), silent = T)
# 	if(class(temp) != "try-error") {
# 		temp %>%
# 			filter(is.na(sub_region_1)) %>%
# 			rename(iso_a2 = country_region_code, country = country_region) %>%
# 			select(-sub_region_1, -sub_region_2, -metro_area) %>%
# 			gather("category", "mobility", -iso_a2, -country, -iso_3166_2_code, -census_fips_code, -date) %>%
# 			mutate(
# 				category = str_to_title(
# 					str_replace_all(str_replace(category, "_percent_change_from_baseline", ""), "_", " ")
# 				),
# 				bin = cut(
# 					mobility, 
# 					breaks = c(seq(-100, 100, 20), Inf), 
# 					labels = labels, 
# 					right = F
# 				)
# 			) %>%
# 			saveRDS(file)
# 	}
# }

dat <- readRDS(file)

data_attribution = paste(
	"<a href = 'https://www.google.com/covid19/mobility/'>Google LLC</a>",
	"Google COVID-19 Community Mobility Reports, Accessed: ",
	Sys.Date()
)

sf <- ne_countries(scale = 110, returnclass = "sf") %>%
	mutate(name = admin) %>%
	select(name, iso_a2)

sf_attribution <- "Made with <a href = 'naturalearthdata.com'>Natural Earth</a>"

