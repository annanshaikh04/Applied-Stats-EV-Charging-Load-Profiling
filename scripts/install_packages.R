# scripts/install_packages.R
pkgs <- c("dplyr","lubridate","readr","ggplot2","tidyr","scales","janitor")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
