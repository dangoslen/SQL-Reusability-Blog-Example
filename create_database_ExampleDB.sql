USE [master]
GO

--========================================================================
-- Create small database to hold the examples. We will call it ExampleDB
--========================================================================
CREATE DATABASE [ExampleDB]
GO

--========================================================================
-- Create tables 
--========================================================================
USE [ExampleDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
-- Create a table to hold basic order information in our simple example.
-- An order has a unique id (order_id), an order_type, a product_id, a customer_id,
-- as well as the current status of the order (placed, fulfilled, shipped). We also
-- keep track of when each order was placed (ordered_time), fulfilled (fulfilled_time), 
-- and shipped (shipped_time).
--
CREATE TABLE [dbo].[orders](
	[order_id] [bigint] IDENTITY(1,1) NOT NULL,
	[order_type] [tinyint] NOT NULL,
	[product_id] [bigint] NOT NULL,
	[customer_id] [bigint] NOT NULL,
	[status] [tinyint] NOT NULL DEFAULT ((1)),
	[ordered_time] [datetime] NOT NULL DEFAULT (getdate()),
	[fulfilled_time] [datetime] NULL,
	[shipped_time] [datetime] NULL
) ON [PRIMARY]
GO

--
-- Create a table to hold basic stats about orders in our simplistic example.
-- A stat has a unique id (stat_id), an order_type and the period for which the 
-- stat is covered for. The stats gathered here are only the sum of new orders (new_order_count),
-- fulfilled orders (fulfilled_order_count), and shipped orders (shipped_order_count) in the time period.
--
CREATE TABLE [dbo].[order_stats](
	[stat_id] [bigint] IDENTITY(1,1) NOT NULL,
	[order_type] [int] NOT NULL,
	[new_order_count] [int] NOT NULL DEFAULT ((0)),
	[fulfilled_order_count] [int] NOT NULL DEFAULT ((0)),
	[shipped_order_count] [int] NOT NULL DEFAULT ((0)),
	[snapshot_start_time] [datetime] NOT NULL DEFAULT (getdate()),
	[snapshot_end_time] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[stat_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--========================================================================
-- Create user-defined types. 
--========================================================================

--
-- Create a UDTT (user defined table type) that mimics the basic information
-- of the dbo.order_stats table.
--
CREATE TYPE [dbo].[udtt_order_stats] AS TABLE(
	[order_type] [int] NOT NULL,
	[new_order_count] [int] NOT NULL DEFAULT ((0)),
	[fulfilled_order_count] [int] NOT NULL DEFAULT ((0)),
	[shipped_order_count] [int] NOT NULL DEFAULT ((0)),
	[snapshot_start_time] [datetime] NOT NULL DEFAULT (getdate()),
	[snapshot_end_time] [datetime] NOT NULL DEFAULT (getdate())
)
GO

--========================================================================
-- Create user-defined functions. 
--========================================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
-- Create a TVF (table-valued user-defined function) to gather the basic stats outlined
-- in the dbo.order_stats table. It returns the count of new, fulfilled, and shipped
-- orders within the snapshot start and snapshot end times provided grouped by the order_type.
--
CREATE FUNCTION [dbo].[tvf_gather_stats] (@snapshot_start datetime, @snapshot_end datetime)
RETURNS TABLE AS
RETURN (
	SELECT 
		new.order_type AS 'order_type', 
		ISNULL(new.order_count, 0) AS 'new_order_count',
		ISNULL(fulfilled.order_count, 0) AS 'fulfilled_order_count',
		ISNULL(shipped.order_count, 0) AS 'shipped_order_count',
		@snapshot_start AS 'snapshot_start_time',
		@snapshot_end AS 'snapshot_end_time'
	FROM 
		-- Get the count of new orders
		(SELECT
			ord.order_type,
			ISNULL(COUNT(1), 0) AS 'order_count'
		FROM 
			dbo.orders ord
		WHERE 
			ord.ordered_time >= @snapshot_start
			AND ord.ordered_time <= @snapshot_end
		GROUP BY
			ord.order_type) As new
		LEFT JOIN 
		-- Get the count of fulfilled orders
		(SELECT 
			ord.order_type,
			ISNULL(COUNT(1), 0) AS 'order_count'
		FROM
			dbo.orders ord
		WHERE 
			ord.fulfilled_time >= @snapshot_start
			AND ord.fulfilled_time <= @snapshot_end
		GROUP BY
			ord.order_type) AS fulfilled ON new.order_type = fulfilled.order_type -- join on order_type
		LEFT JOIN 
		-- Get the count of shipped orders
		(SELECT 
			ord.order_type,
			ISNULL(COUNT(1), 0) AS 'order_count'
		FROM
			dbo.orders ord
		WHERE 
			ord.shipped_time >= @snapshot_start
			AND ord.shipped_time <= @snapshot_end
		GROUP BY
			ord.order_type) AS shipped ON new.order_type = shipped.order_type -- join on order_type
)
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

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--========================================================================
-- Create stored procedures. 
--========================================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--
-- Capture a set base stats from the orders table based upon a 
-- duration in time. The procedure accepts a start datetime and 
-- a duration value (in minutes) of the snapshot. The snapshot will
-- be from the snapshot_start till the duration.
--
CREATE PROCEDURE [dbo].[capture_order_stats]
	@snapshot_start datetime,
	@snapshot_duration int = 240 -- in minutes
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- If the snapshot_start is NULL, use the current time.
	IF @snapshot_start IS NULL
	BEGIN 
		SET @snapshot_start = GETDATE()
	END

	-- Set the snapshot_end time by adding the duration
	DECLARE @snapshot_end datetime = DATEADD(Minute, @snapshot_duration, @snapshot_start)

	-- Capture stats and insert them into the dbo.order_stats table using the tvf_gather_stats function
    INSERT INTO dbo.order_stats (
		order_type,
		new_order_count,
		fulfilled_order_count,
		shipped_order_count,
		snapshot_start_time,
		snapshot_end_time
	)
	SELECT 
		order_type,
		new_order_count,
		fulfilled_order_count,
		shipped_order_count,
		@snapshot_start,
		@snapshot_end
	FROM dbo.tvf_gather_stats(@snapshot_start, @snapshot_end)

END
GO

