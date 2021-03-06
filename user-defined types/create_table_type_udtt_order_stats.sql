USE [ExampleDB]
GO

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
