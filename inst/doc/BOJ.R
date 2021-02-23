## ----setup, echo = FALSE------------------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  fig.width = 6, 
  fig.height = 4
)

## ----loading------------------------------------------------------------------
library("BOJ")

## ----datasets, message=FALSE, warning=FALSE-----------------------------------
datasets <- get_boj_datasets()
datasets

## ----sppi, message=FALSE, warning=FALSE---------------------------------------
sppi <- get_boj(datasets$url[(datasets$name == "sppi_m_en")])
sppi

## ----plot, message=FALSE, warning=FALSE---------------------------------------
library("dplyr")
library("ggplot2")
library("zoo")

sppi_plot <- subset(sppi, code %in% c("PRCS15_5200000000", "PRCS15_5200010001",
                                      "PRCS15_5200010002", "PRCS15_5200010003",
                                      "PRCS15_5200010004", "PRCS15_5200010005",
                                      "PRCS15_5200010006", "PRCS15_5200010007"))
sppi_plot <- mutate(sppi_plot, date = as.Date(as.yearmon(date, format = "%Y%m")))
sppi_plot <- mutate(sppi_plot, struc = gsub("^Major group/ ", "", struc))
sppi_plot <- subset(sppi_plot, !is.na(obs_value))

ggplot(sppi_plot, aes(x = date, y = obs_value)) +
  geom_line(aes(colour = struc)) +
  labs(x = "Date", y = "Services Producer Price Index (2015 base)") +
  theme(legend.title = element_blank())

