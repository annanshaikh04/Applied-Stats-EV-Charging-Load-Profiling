# R/02_visualize.R
# Generates figures into figures/ from processed data

# ── packages ────────────────────────────────────────────────────────────────────
req <- c("dplyr","lubridate","readr","ggplot2","scales")
to_install <- setdiff(req, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
invisible(lapply(req, library, character.only = TRUE))

here <- function(...) file.path(normalizePath(getwd(), winslash = "/"), ...)

# ── load processed data ────────────────────────────────────────────────────────
cand <- c("data/processed/acndata_output_clean.csv",
          "data/processed/acndata_output3.csv",
          "data/processed/acndata_output2.csv",
          "data/processed/acndata_output1.csv",
          "data/processed/acndata_output.csv")
path <- cand[file.exists(cand)][1]
stopifnot(!is.na(path))
df <- readr::read_csv(path, show_col_types = FALSE)

# required columns
need <- c("date","session_time","stationID","number_of_users","average_power_usage")
miss <- setdiff(need, names(df))
if (length(miss)) stop("Missing columns: ", paste(miss, collapse = ", "))

# build POSIX datetime (UTC) and hour-of-day
df <- df |>
  mutate(
    date = as.Date(date),
    hour = as.integer(substr(session_time,1,2)),              # 0..23
    dt   = as.POSIXct(paste(date, session_time), tz = "UTC")
  )

# ── 1) heatmap: hour-of-day × station ──────────────────────────────────────────
hm <- df |>
  group_by(stationID, hour) |>
  summarise(avg_kW = mean(average_power_usage, na.rm = TRUE), .groups = "drop")

p_heat <- ggplot(hm, aes(x = factor(hour, levels = 0:23), y = stationID, fill = avg_kW)) +
  geom_tile() +
  scale_fill_gradient(name = "kW", low = "white", high = "steelblue") +
  labs(x = "Hour of day", y = "Station", title = "Average power usage by hour × station") +
  theme_minimal(base_size = 12)

ggsave(here("figures/heatmap_hour_station.png"), p_heat, width = 10, height = 6, dpi = 150)

# ── 2) time series: daily totals/averages ──────────────────────────────────────
daily <- df |>
  group_by(date) |>
  summarise(
    daily_total_kW  = sum(average_power_usage, na.rm = TRUE),
    daily_mean_kW   = mean(average_power_usage, na.rm = TRUE),
    .groups = "drop"
  )

p_ts_total <- ggplot(daily, aes(date, daily_total_kW)) +
  geom_line() +
  labs(title = "Daily total power usage", x = "Date", y = "kW (sum across station-hours)") +
  theme_minimal(base_size = 12)

ggsave(here("figures/ts_daily_total.png"), p_ts_total, width = 10, height = 4, dpi = 150)

# ── 3) histogram: distribution of hourly average power ─────────────────────────
p_hist <- ggplot(df, aes(average_power_usage)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of average_hourly_power (kW)", x = "kW", y = "Count") +
  theme_minimal(base_size = 12)

ggsave(here("figures/hist_usage.png"), p_hist, width = 8, height = 4, dpi = 150)

message("Wrote figures to figures/:",
        "\n - heatmap_hour_station.png",
        "\n - ts_daily_total.png",
        "\n - hist_usage.png")
