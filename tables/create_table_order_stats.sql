USE [ExampleDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
