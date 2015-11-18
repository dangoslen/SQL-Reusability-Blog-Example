--========================================================================
-- Insert some baseline orders
--========================================================================
INSERT INTO orders(order_type, product_id, customer_id, status, ordered_time, fulfilled_time, shipped_time)
VALUES 
	(1, 13, 1789, 1, '2015-11-11 10:35:31.497', NULL, NULL),
	(2, 24, 3889, 1, '2015-11-11 10:35:31.497', NULL, NULL),
	(3, 39, 3891, 1, '2015-11-11 10:35:31.497', NULL, NULL),
	(3, 33, 3892, 1, '2015-11-11 10:35:31.497', NULL, NULL),
	(1, 13, 1722, 2, '2015-11-11 08:32:31.503', '2015-11-11 10:35:31.503', NULL),
	(1, 14, 1723, 2, '2015-11-11 09:06:31.503', '2015-11-11 10:35:31.503', NULL),
	(1, 15, 1724, 2, '2015-11-11 08:56:31.503', '2015-11-11 10:35:31.503', NULL),
	(1, 16, 1725, 2, '2015-11-11 09:06:31.503', '2015-11-11 10:35:31.503', NULL),
	(3, 31, 3726, 2, '2015-11-11 06:54:31.503', '2015-11-11 10:35:31.503', NULL),
	(3, 32, 3727, 2, '2015-11-11 06:36:31.503', '2015-11-11 10:35:31.503', NULL),
	(2, 22, 2889, 2, '2015-11-11 07:06:31.503', '2015-11-11 10:35:31.503', NULL),
	(2, 23, 2889, 2, '2015-11-11 07:56:31.503', '2015-11-11 10:35:31.503', NULL),
	(2, 24, 2889, 2, '2015-11-11 08:36:31.503', '2015-11-11 10:35:31.503', NULL),
	(2, 25, 2889, 2, '2015-11-11 08:56:31.503', '2015-11-11 10:35:31.503', NULL),
	(1, 13, 1789, 3, '2015-11-11 05:52:31.507', '2015-11-11 09:32:31.507', '2015-11-11 10:35:31.507'),
	(1, 14, 1791, 3, '2015-11-11 07:26:31.507', '2015-11-11 09:13:31.507', '2015-11-11 10:35:31.507'),
	(2, 21, 2792, 3, '2015-11-11 06:21:31.507', '2015-11-11 09:50:31.507', '2015-11-11 10:35:31.507'),
	(2, 22, 2793, 3, '2015-11-11 07:56:31.507', '2015-11-11 09:06:31.507', '2015-11-11 10:35:31.507'),
	(3, 33, 3721, 3, '2015-11-11 01:54:31.507', '2015-11-11 06:54:31.507', '2015-11-11 10:35:31.507'),
	(3, 34, 3721, 3, '2015-11-11 02:20:31.507', '2015-11-11 06:36:31.507', '2015-11-11 10:35:31.507'),
	(1, 14, 1889, 3, '2015-11-11 07:06:31.507', '2015-11-11 07:06:31.507', '2015-11-11 10:35:31.507')

--========================================================================
-- Gather the stats of the records we just inserted via the tvf_gather_stats 
-- function. These values won't be added to our order_stats table
--========================================================================
SELECT * FROM tvf_gather_stats('2015-11-11 00:00', '2015-11-11 12:00')
	
--========================================================================
-- Capture the stats of the records we just inserted and write them to order_stats
-- via the capture_order_stats stored procedure we wrote
--========================================================================
EXEC dbo.capture_order_stats @snapshot_start = '2015-11-11 00:00'
EXEC dbo.capture_order_stats @snapshot_start = '2015-11-11 04:00'
EXEC dbo.capture_order_stats @snapshot_start = '2015-11-11 08:00'
EXEC dbo.capture_order_stats @snapshot_start = '2015-11-11 12:00'

--========================================================================
-- Gather some analytics from the order_stats table using a temporary table
-- of the udtt_order_stats type and the tvf_gather_anayltics function. 
-- You can play with the WHERE clause in the INSERT INTO .. SELECT .. FROM order_stats
-- query to change the analytics you get back.
--========================================================================
DECLARE @stats AS dbo.udtt_order_stats;

INSERT INTO @stats (
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
	snapshot_start_time,
	snapshot_end_time
FROM dbo.order_stats
WHERE order_type = 2

SELECT * FROM tvf_gather_anayltics(@stats)