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
