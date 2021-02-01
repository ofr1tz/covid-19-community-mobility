require(tidyverse)
require(cronR)

cron_rscript("update_data.R", workdir = here::here()) %>%
	cron_add(frequency = "daily", at = "18:30", description = "update data")