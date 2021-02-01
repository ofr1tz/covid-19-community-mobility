require(tidyverse)
require(cronR)

cron_rscript("update_data.R") %>%
	cron_add(frequency = "daily", at = "18:15", description = "update data")