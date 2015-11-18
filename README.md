# SQL-Reusability-Blog-Example
This is a very basic tutorial around how to use UDTTs and TVFs in SQL Server to do some basic statistics gathering. The goal is to explain some of the nuances of implementing SQL queries and functions with this pattern.

To read the full example, check out the post here: http://blog.bandwidth.com/attaining-reusability-in-sql-server-part-ii/

## Running
To run the example, you should first run the <code>create_database_exampleDB.sql</code> script. This script will setup a small database with the all of the objects, tables, etc. you will need.

Next, run the <code>examples.sql</code> following the steps provided in the script itself. The script will add base orders, use the stored procedure in the example to write some stats from the orders table and then do some simple analytics after the fact.


