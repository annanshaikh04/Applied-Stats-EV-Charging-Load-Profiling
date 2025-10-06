# EV Charging Load Profiling — Applied Statistics (R)

Compute **per-station per-hour** usage from EV charging sessions, handling partial overlaps and producing clean hourly aggregates.

## Highlights
- **Precise windowing:** proportional allocation of session power within each hour
- **Robust parsing:** timezone-safe `ymd_hms(..., tz="UTC")` and numeric coercion
- **Reproducible:** path-safe scripts; single command to install packages
- **Artifacts preserved:** your original outputs kept in `data/processed/`

## Repo structure
```
Applied-Stats-EV-Charging-Load-Profiling/
├── R/
│   ├── 00_setup.R
│   └── 01_process_sessions.R
├── scripts/
│   └── install_packages.R
├── data/
│   ├── raw/
│   │   └── acndata.csv
│   └── processed/
│       ├── acndata_output.csv
│       ├── acndata_output1.csv
│       ├── acndata_output2.csv
│       └── acndata_output3.csv
├── reports/
├── figures/
├── docs/
├── .gitignore
└── README.md

```

## Quickstart
```r
# Install packages
source("scripts/install_packages.R")

# Process raw → processed
source("R/01_process_sessions.R")
# → writes data/processed/acndata_output_clean.csv
```

## Input columns (required)
- `stationID` (chr)
- `connectionTime` (ISO 8601, UTC recommended)
- `doneChargingTime` (ISO 8601, UTC recommended)
- `ChargingPower_KW` (numeric)

## Output columns
- `date` (Date), `session_time` (HH:MM:SS), `stationID`, `number_of_users`, `average_power_usage` (kW)

## Notes
- Overlap rule uses **[start, end)** to prevent double counting at hour boundaries.
- Invalid or missing timestamps/power rows are dropped before aggregation.
