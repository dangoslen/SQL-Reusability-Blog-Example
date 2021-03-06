USE [ExampleDB]
GO

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
