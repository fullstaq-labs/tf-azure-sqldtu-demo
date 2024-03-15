SELECT top 500 end_time,
avg_cpu_percent,
avg_data_io_percent,
avg_log_write_percent, 
	(SELECT Max(v) 
		FROM (VALUES (avg_cpu_percent),
		(avg_data_io_percent),
		(avg_log_write_percent)) AS value(v)
	) as [DTU]
FROM sys.dm_db_resource_stats 
order by end_time desc;