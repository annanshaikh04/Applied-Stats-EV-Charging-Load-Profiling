\
    # R/01_process_sessions.R
    source("R/00_setup.R")
    raw_path <- here("data/raw/acndata.csv")
    stopifnot(file.exists(raw_path))
    acndata <- readr::read_csv(raw_path, show_col_types = FALSE, progress = FALSE)
    expected <- c("stationID","connectionTime","doneChargingTime","ChargingPower_KW")
    missing <- setdiff(expected, names(acndata))
    if (length(missing)) stop("Missing columns: ", paste(missing, collapse=", "))
    acndata <- acndata |>
      mutate(
        connectionTime = lubridate::ymd_hms(connectionTime, quiet = TRUE, tz = "UTC"),
        doneChargingTime = lubridate::ymd_hms(doneChargingTime, quiet = TRUE, tz = "UTC"),
        ChargingPower_KW = suppressWarnings(as.numeric(ChargingPower_KW))
      ) |>
      filter(!is.na(connectionTime), !is.na(doneChargingTime), !is.na(ChargingPower_KW)) |>
      mutate(session_start = lubridate::floor_date(connectionTime, "hour"))
    calculate_adjusted_power <- function(power_kw, conn, done, session_start, session_end) {
      if (is.na(power_kw) || is.na(conn) || is.na(done)) return(0)
      start <- max(conn, session_start)
      end <- min(done, session_end)
      if (end <= start) return(0)
      portion_h <- as.numeric(difftime(end, start, units = "hours"))
      denom_h <- as.numeric(difftime(session_end, session_start, units = "hours"))
      if (denom_h <= 0) return(0)
      power_kw * (portion_h / denom_h)
    }
    sessions <- split(acndata, acndata$stationID)
    out <- vector("list", length(sessions))
    i <- 1L
    for (station in names(sessions)) {
      sd <- sessions[[station]]
      for (ses in sort(unique(sd$session_start))) {
        ses_end <- ses + lubridate::hours(1)
        in_window <- sd |> dplyr::filter(connectionTime < ses_end, doneChargingTime > ses)
        if (nrow(in_window) == 0) next
        adj <- mapply(calculate_adjusted_power,
                      in_window$ChargingPower_KW,
                      in_window$connectionTime,
                      in_window$doneChargingTime,
                      MoreArgs = list(session_start = ses, session_end = ses_end))
        out[[i]] <- data.frame(
          date = as.Date(ses),
          session_time = format(as.POSIXct(ses, tz = "UTC"), "%H:%M:%S"),
          stationID = station,
          number_of_users = nrow(in_window),
          average_power_usage = mean(adj, na.rm = TRUE)
        )
        i <- i + 1L
      }
    }
    result <- dplyr::bind_rows(out)
    result <- result |> dplyr::arrange(date, session_time, stationID)
    out_path <- here("data/processed/acndata_output_clean.csv")
    readr::write_csv(result, out_path)
    message("Wrote: ", out_path, " (", nrow(result), " rows)")
