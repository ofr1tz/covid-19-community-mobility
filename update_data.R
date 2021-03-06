print(Sys.Date())

require(tidyverse)

# source shared variables used by update_data cron job and app
source("shared_vars.R")


if(!dir.exists("data")) { dir.create("data") }

temp <- try(read_csv(url, col_types = "ccccccccDiiiiii"), silent = T)
if(class(temp) != "try-error") {
	temp %>%
		filter(is.na(sub_region_1)) %>%
		rename(iso_a2 = country_region_code, country = country_region) %>%
		select(-sub_region_1, -sub_region_2, -metro_area, -place_id) %>%
		gather("category", "mobility", -iso_a2, -country, -iso_3166_2_code, -census_fips_code, -date) %>%
		mutate(
			category = str_to_title(
				str_replace_all(str_replace(category, "_percent_change_from_baseline", ""), "_", " ")
			),
			bin = cut(
				mobility, 
				breaks = c(seq(-100, 100, 20), Inf), 
				labels = labels, 
				right = F
			)
		) %>%
		saveRDS(file, compress = F)
}