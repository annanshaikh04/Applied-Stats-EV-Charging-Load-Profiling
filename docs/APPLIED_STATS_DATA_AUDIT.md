# Applied Stats Dataset Audit

## Files

- acndata.csv: 7591 rows, 11 cols, 1.13 MB, nulls=0, columns=[Index, Charging_Id, connectionTime, disconnectTime, doneChargingTime, ChargingDuration, StandByTime, kWhDelivered, ...]
- acndata_output.csv: 5411 rows, 4 cols, 0.22 MB, nulls=0, columns=[date, stationID, number_of_users, average_power_usage]
- acndata_output1.csv: 0 rows, 5 cols, 0.0 MB, nulls=0, columns=[date, session_time, stationID, number_of_users, average_power_usage]
- acndata_output2.csv: 409 rows, 5 cols, 0.02 MB, nulls=0, columns=[date, session_time, stationID, number_of_users, average_power_usage]
- acndata_output3.csv: 409 rows, 5 cols, 0.02 MB, nulls=0, columns=[date, session_time, stationID, number_of_users, average_power_usage]

## Checks & Notes

- connectionTime: 0 unparsable values; range=2019-10-10 14:39:05+00:00 to 2021-09-14 01:52:37+00:00 (UTC)
- doneChargingTime: 0 unparsable values; range=2019-10-10 16:35:48+00:00 to 2021-09-14 03:05:10+00:00 (UTC)
- ChargingPower_KW: 0 non-numeric entries; range=0.0322309310644684 to 981.3279569887776 kW
- stationID: 55 unique stations; mode=2-39-81-4550
- acndata_output.csv: Missing session_time; rows=5411
- acndata_output.csv: average_power_usage negative values=0; min=0.0002057557217312
- acndata_output1.csv: OK; rows=0
- acndata_output1.csv: average_power_usage negative values=0; min=nan
- acndata_output2.csv: OK; rows=409
- acndata_output2.csv: average_power_usage negative values=0; min=0.056976913024539
- acndata_output3.csv: OK; rows=409
- acndata_output3.csv: average_power_usage negative values=0; min=0.056976913024539