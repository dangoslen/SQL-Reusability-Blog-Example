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
