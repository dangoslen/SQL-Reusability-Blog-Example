USE [ExampleDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
-- Create a TVF (table-valued user-defined function) for performing some basic 
-- statistics on the stats contained in the @stats table. The @stats table MUST
-- be of the UDTT type 'udtt_order_stats'. By passing in a table, we can peform 
-- these statistics based on any 'set' of data the function gets passed in.
--
CREATE FUNCTION [dbo].[tvf_gather_anayltics] (@stats udtt_order_stats READONLY)
RETURNS TABLE AS
RETURN (
	SELECT
		stat.order_type AS 'order_type',
		MAX(stat.new_order_count) AS 'highest_new_order_count_per_snapshot',
		AVG(CAST(stat.new_order_count AS NUMERIC(19,2))) AS 'mean_new_order_count_per_snapshot',
		SUM(stat.new_order_count) AS 'sum_new_order_count',
		MAX(stat.fulfilled_order_count) AS 'highest_fulfilled_order_count_per_snapshot',
		AVG(CAST(stat.fulfilled_order_count  AS NUMERIC(19,2))) AS 'mean_fulfilled_order_count',
		SUM(stat.fulfilled_order_count) AS 'sum_fulfilled_order_count',
		MAX(stat.shipped_order_count) AS 'highest_shipped_order_count_per_snapshot',
		AVG(CAST(stat.shipped_order_count  AS NUMERIC(19,2))) AS 'mean_shipped_order_count',
		SUM(stat.shipped_order_count) AS 'sum_shipped_order_count',
		COUNT(1) AS 'stats_present',
		MIN(stat.snapshot_start_time) AS 'stat_start_time',
		MAX(stat.snapshot_end_time) AS 'stat_end_time'
	FROM
		@stats stat
	GROUP BY 
		stat.order_type WITH ROLLUP
)
GO
