require(cronR)

r <- cron_rscript("update_data.R", workdir = here::here())
cron_add(r, frequency = "daily", at = "18:30", description = "update data")