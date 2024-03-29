if (getRversion() >= "2.15.1") utils::globalVariables(c("obs_value"))

.clean_names <- function(x) {
  x <- make.unique(tolower(trimws(gsub("[[:space:]]", "_", x))))

  return(x)
}

.pivot_longer_boj <- function(df) {
  excl_cols <- names(df)[is.element(names(df),
                                    c("code", "desc", "struc", "unit"))]
  df <- tidyr::pivot_longer(data = df, cols = -tidyselect::all_of(excl_cols),
                            names_to = "date", values_to = "obs_value")
  df <- dplyr::mutate(df, obs_value = as.numeric(obs_value))

  return(df)
}

#' Download and parse a list of available BOJ data sets
#'
#' @param url URL of the BOJ's Time-Series Data portal flat files page
#' (optional).
#'
#' @return A tibble data frame
#' @export
#'
#' @examples
#' \dontrun{
#' datasets <- get_boj_datasets()
#' }
get_boj_datasets <- function(
  url = "https://www.stat-search.boj.or.jp/info/dload_en.html") {
  tbl <- tryCatch({
      # Download webpage
      page  <- xml2::read_html(url)
      nodes <- rvest::html_nodes(page, xpath = "//a[contains(@href, 'zip')]")

      # Get file name and path to file
      item_urls  <- paste0("https://www.stat-search.boj.or.jp/info/",
                           (rvest::html_attr(nodes, "href")))
      item_names <- sub(".*\\/(.*?) *\\.zip*", "\\1", item_urls)
      item_descs <- gsub(".zip", "", rvest::html_text(nodes))

      # Return tibble
      tbl <- dplyr::tibble(desc = item_descs,
                           name = item_names,
                           url  = item_urls)

      if (nrow(tbl) == 0) {
        message(paste("Unable to download and parse BOJ homepage:", url))
        message("The resource is unavailable or has changed.")
      }

      tbl
    },
    error = function(x) {
      message(paste("Unable to download and parse BOJ homepage:", url))
      message("The resource is unavailable or has changed.")
      message("Original error message:")
      message(x)
      return(NA)
    },
    warning = function(x) {
      message(paste("Unable to download and parse BOJ homepage:", url))
      message("The resource is unavailable or has changed.")
      message("Original warning message:")
      message(x)
      return(NA)
    }
  )

  return(tbl)
}

#' Download and parse a BOJ data set
#'
#' @param url URL of the data set to be imported (usually obtained through
#' \code{get_boj_datasets()})
#' @param ... Arguments passed to \code{download.file()} (e.g.
#' \code{quiet = TRUE})
#'
#' @return A tibble data frame
#' @export
#'
#' @examples
#' \dontrun{
#' datasets <- get_boj_datasets()
#' df <- get_boj(datasets$url[(datasets$name == "sppi_q_en")])
#' }
get_boj <- function(url, ...) {
  # Get file name
  file_name <- sub(".*\\/(.*?) *\\.zip*", "\\1", url)

  # Download data
  tmp_dir  <- tempdir()
  tmp_file <- tempfile(fileext = ".zip")

  tryCatch({
      # Download file
      utils::download.file(url, tmp_file, mode = "wb", ...)

      # Unpack zip file
      filename <- utils::unzip(tmp_file, list = TRUE)
      utils::unzip(tmp_file, exdir = tmp_dir)

      path <- file.path(tmp_dir, filename$Name)

      # Read data into a list of tibble data frames
      df <- list()
      i  <- 0

      # One tibble data frame per file
      while (i < length(path)) {
        i       <- i + 1
        df[[i]] <- readr::read_csv(path[[i]], col_names = FALSE,
                                   show_col_types = FALSE,
                                   na = c("", "NA", "ND"))

        # Distinguish between wide and long data sets
        if (!is.element(file_name, c("fof", "co", "colease"))) {
          # Wide data (horizontal)
          nms <- as.character(df[[i]][1, ])

          if (!is.element(file_name, c("bp_m_en", "regbp_q_en", "qiip_q_en",
                                       "iip_cy_en"))) {
            # Three columns
            if (is.element(file_name, c("bis1-1_q_en", "bis1-2_q_en",
                                        "bis2-1_q_en", "bis2-2_q_en"))) {
              nms[1:3] <- c("code", "struc", "unit")
            } else {
              nms[1:3] <- c("code", "desc", "struc")
            }
          } else {
            # Four columns
            nms[1:4] <- c("code", "desc", "struc", "unit")
          }

          names(df[[i]]) <- .clean_names(nms)
          df[[i]]        <- df[[i]][-1, ]
          df[[i]]        <- .pivot_longer_boj(df[[i]])

        } else {
          # Long data (vertical)
          names(df[[i]]) <- c("code", "freq", "date", "obs_value")
        }

        if (nrow(df[[i]]) == 0) {
          message(paste("Unable to download and parse BOJ homepage:", url))
          message("The resource is unavailable or has changed.")
        }
      }

      # If there is only one tibble data frame, return as single object
      if (length(df) < 2) {
        df <- df[[1]]
      }

      df
    },
    error = function(x) {
      message(paste("Unable to download and parse file:", url))
      message("The resource is unavailable or has changed.")
      message("Original error message:")
      message(x)
      return(NA)
    },
    warning = function(x) {
      message(paste("Unable to download and parse file:", url))
      message("The resource is unavailable or has changed.")
      message("Original warning message:")
      message(x)
      return(NA)
    }
  )

  return(df)
}
