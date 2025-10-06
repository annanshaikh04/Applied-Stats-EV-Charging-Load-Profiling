\
    # R/00_setup.R
    required <- c("dplyr","lubridate","readr","ggplot2","tidyr","scales","janitor")
    to_install <- setdiff(required, rownames(installed.packages()))
    if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
    invisible(lapply(required, library, character.only = TRUE))
    here <- function(...) file.path(normalizePath(getwd(), winslash = "/"), ...)
