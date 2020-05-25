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

## ----bop, message=FALSE, warning=FALSE----------------------------------------
bop <- get_boj(datasets$url[(datasets$name == "bp_m_en")])
bop

## ----plot, message=FALSE, warning=FALSE---------------------------------------
library("dplyr")
library("ggplot2")
library("zoo")

bop_plot <- subset(bop, code %in% c("BPBP6JYNTB", "BPBP6JYNSN", "BPBP6JYNPIN",
                                    "BPBP6JYNSIN"))
bop_plot <- mutate(bop_plot, date = as.Date(as.yearmon(date, format = "%Y%m")))
bop_plot <- subset(bop_plot, date > as.Date("2000-01-01"))
bop_plot <- subset(bop_plot, !is.na(obs_value))

ggplot(bop_plot, aes(x = date, y = obs_value)) +
  geom_bar(aes(fill = struc), stat = "identity") +
  labs(x = "Date", y = "100 million yen") +
  theme(legend.title = element_blank())

