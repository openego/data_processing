"""
Read renpassG!S results in a csv format. Write the records to the renpassG!S
schema table renpass_gis_results on the oedb!



For higher performance a single insert statement is created.
Faster than using SQLA ORM and SQLA CORE as described here:

http://www.devx.com/dbzone/optimize-inserts-using-sqlalchemy.html

------------------------------------------------------------------------------
Needs a configuration file in ~/.open_eGo of the following format

[Connection]
username =
password =
host =
port =
db =

"""
import pandas as pd
from db import conn

filepath = "~/oemof/examples/solph/nodes_from_csv/results/"
csv_file = "scenario_nep_2014_2016-09-06 14:24:29.364210_results_complete.csv"

scenario_id = 2
tablename = "calc_renpass_gis.renpass_gis_results"

# read csv, add scenario_id
df = pd.read_csv(filepath + csv_file)
df.columns = [c.lower() for c in df.columns]
df.insert(0, 'scenario_id', scenario_id)

# single quotes around string cols necessary for query statement
cols = ['datetime', 'bus_label', 'type', 'obj_label']
df[cols] = df[cols].applymap(lambda x: "'" + x + "'")

# best solution performance wise, a single insert statement is created
records = [tuple(x) for x in df.values]

records = ",".join("(" + ",".join(str(i) for i in r) + ")" for r in records)
head = ("INSERT INTO " + tablename + " (scenario_id, bus_label, type, "
             "obj_label, datetime, val) VALUES ")

# export to db
conn.execute(head + records)
