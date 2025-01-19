## ----install, eval=FALSE, message=FALSE, warning=FALSE------------------------
# library(devtools)
# install_github("stefanangrick/BOJ")  # GitHub
# install.packages("BOJ")              # CRAN

## ----loading, eval=FALSE, message=FALSE, warning=FALSE------------------------
# library("BOJ")

## ----datasets, eval=FALSE, message=FALSE, warning=FALSE-----------------------
# ds <- get_boj_datasets()
# head(ds)

## ----sppi, eval=FALSE, message=FALSE, warning=FALSE---------------------------
# sppi <- get_boj(ds$url[(ds$name == "sppi_m_en")])
# head(sppi)

## ----plot, eval=FALSE, message=FALSE, warning=FALSE---------------------------
# library("dplyr")
# library("ggplot2")
# library("zoo")
# 
# sppi_plot <- subset(sppi, code %in% c("PRCS20_5200000000", "PRCS20_5200010001",
#                                       "PRCS20_5200010002", "PRCS20_5200010003",
#                                       "PRCS20_5200010004", "PRCS20_5200010005",
#                                       "PRCS20_5200010006", "PRCS20_5200010007"))
# sppi_plot <- mutate(sppi_plot, date = as.Date(as.yearmon(date, format = "%Y%m")))
# sppi_plot <- mutate(sppi_plot, struc = gsub("^Major group/ ", "", struc))
# sppi_plot <- subset(sppi_plot, !is.na(obs_value))
# 
# ggplot(sppi_plot, aes(x = date, y = obs_value)) +
#   geom_line(aes(colour = struc)) +
#   labs(title = "Services Producer Price Index", x = "Date", y = "Index") +
#   theme(legend.title = element_blank())

