require(tidyverse)
require(cronR)

cron_rscript("update_data.R") %>%
	cron_add(frequency = "daily", at = "00:00", description = "update data")