"""
Create LV grids
"""

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "jong42"

import networkx as nx
import fiona
import math
import csv
from shapely.geometry import shape
from shapely.ops import unary_union
import sqlalchemy as sqla
#from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select,text
from oemof import db


# Initialize variables
numberofonts = 11
onts = []
distmax = 250
xcoord = []
ycoord = []
dominated = []
ont = []
street_geoms = []
street_gids = []

# Create shapefile for one load area


# connect to database
engine = db.engine(section='oedb')
conn = engine.connect()

# perform query

s = text(
        "SELECT * FROM model_draft.process_eGo_lv_streets WHERE load_area_id = :x")
result = conn.execute(s, x = 1)

# Store geometries and load_area_ids in lists
for i in result:
    row = result.fetchone()
    print("gid:", row['gid'], "; geom:", row['geom'],"load_area_id:",row['load_area_id'])
    street_geoms.append(row['geom'])
    street_gids.append(row['load_area_id'])

# Close connections and result objects 
result.close()
conn.close()

# read graph vom shapefile
in_path = "//SRV02/RL-Institut/04_Projekte/140_open_eGo/10-Stud_Ordner/Jonas_Guetter/Daten/shapefiles/test/Tus/osm_streets_Tus.shp"

lines =[shape(line['geometry']) for line in fiona.open(in_path)]
result = unary_union(lines)

graph = nx.Graph()
for line in result:
   for seg_start, seg_end in zip(list(line.coords),list(line.coords)[1:]):
       graph.add_edge(seg_start, seg_end)


# change to undirected graph
graph = graph.to_undirected()



# Step 1: Mark every node as undominated

for x in range(0, graph.number_of_nodes()):
    graph.node[graph.nodes()[x]]['dominated'] = None

# Step 2

# Step 2.1: Count the number of adjacent nodes for each node:
for x in range(0, graph.number_of_nodes()):
    adjacent_nodes = len(graph.neighbors(graph.nodes()[x]))
    graph.node[graph.nodes()[x]]['adjacent_undominated'] = adjacent_nodes
    graph.node[graph.nodes()[x]]['ONT'] = False

   

# Step 2.2: Calculate the length of each edge
for x in range(0, graph.number_of_edges()):
    first = graph.edges(data=True)[x]
    distance = math.sqrt(sum([(a - b) ** 2 for a, b in zip(first[0],first[1])]))
    graph.edge[first[0]][first[1]]['weight'] = distance 
    
  
for x in range(0, numberofonts):
    # Step 2.3: Add the node with the most adjacent undominated nodes to onts 
    max_neighbors = max(nx.get_node_attributes(graph, 'adjacent_undominated').values())
    for y in range (0, graph.number_of_nodes()):
        if (graph.node[graph.nodes()[y]]['adjacent_undominated'] == max_neighbors):
            nextont = graph.nodes()[y]
            graph.node[graph.nodes()[y]]['ONT'] = True
            onts.append (nextont)
            break
        

    # Step 3: Mark every node within the range of the previously added ont as dominated
    
    # Step 3.1: Calculate the distance for each node and the previously added ont
    distances = nx.single_source_dijkstra_path_length (graph, source = 
       nextont, cutoff=distmax, weight='weight')    
    
    # Step 3.2: Mark every node within the range of the previously added ont as dominated
    for y in distances.keys():
        if (graph.node[y]['dominated'] == None):
            graph.node[y]['dominated'] = x
            
            # Step 3.3: For every neighbor of those nodes: Decrease number of adjacent undominated nodes by 1
            for z in graph.neighbors(y):
                graph.node[z]['adjacent_undominated'] -= 1
        else:
            
            # if a node is already dominated, change the dominating ont if the distance to the new ont is shorter
            ont_new = graph.nodes()[x]
            ont_old = graph.nodes()[graph.node[y]['dominated']]
            point = graph.nodes()[graph.nodes().index(y)]
            pathlength_old = nx.shortest_path_length(graph,source = point,target = ont_old, weight = 'weight')
            pathlength_new = nx.shortest_path_length(graph,source = point,target = ont_new, weight = 'weight')
            if ( pathlength_new <= pathlength_old ):
                graph.node[y]['dominated'] = x
            
# assign every node which is not already dominated to a ont
            
for x in range (0,graph.number_of_nodes()):
    if (graph.node[graph.nodes()[x]]['dominated'] == None):
        # Calculate the distance to each ont
        pathlengths = []
        for y in range(0, numberofonts):
            # Check if path between node and ont exists
            if (nx.has_path(graph,source = graph.nodes()[x], target = onts[y])):
                pathlengths.append(nx.shortest_path_length(graph,source = graph.nodes()[x], target = onts[y], weight = 'weight'))
            else:
                pathlengths.append(999999999999999)
        # Assign the ont with the minimal pathlength to the node
        if (min(pathlengths) < 999999999999999):
            graph.node[graph.nodes()[x]]['dominated'] = pathlengths.index(min(pathlengths))
            
    
 
# Assign onts to edges

for x in range(0, graph.number_of_edges()):
    ed = graph.edges(data=True)[x]
    graph.edge[ed[0]][ed[1]]['dominated'] = graph.node[ed[1]]['dominated']

    
   
# Store results ins lists  
for x in range(0, graph.number_of_nodes()):
    ont.append(graph.node[graph.nodes()[x]]['ONT'])
    dominated.append(graph.node[graph.nodes()[x]]['dominated'])
    xc,yc = graph.nodes()[x]
    xcoord.append(xc)
    ycoord.append(yc)

#for x in range (0, graph.number_of_edges()):

# write results into csv file
csv_name = 'process_eGo_lv_grid.csv'
with open(csv_name,'w',newline = '') as foo:
    writer = csv.writer(foo,delimiter = ',')
    for x in range (0, graph.number_of_nodes()):
        writer.writerow([xcoord[x],ycoord[x],dominated[x], ont[x]])
   



# create output graph
out_graph = graph.copy()
out_graph.remove_nodes_from(graph.nodes())
out_graph.add_nodes_from(onts)

# create shapefile from graph
out_path = "//SRV02/RL-Institut/04_Projekte/140_open_eGo/10-Stud_Ordner/Jonas_Guetter/Daten/shapefiles/test/Tus"
nx.write_shp(out_graph,out_path)

