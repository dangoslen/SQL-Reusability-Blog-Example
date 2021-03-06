USE [ExampleDB]
GO

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
