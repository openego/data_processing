"""
Create LV grid districts
"""

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "jong42"

import networkx as nx
from sqlalchemy.sql import text
from oemof import db
from shapely.wkt import loads
import math
import time

t0 = time.clock()


# connect to database
engine = db.engine(section='oedb')
conn = engine.connect()

# Truncate result table
#s = text("Truncate TABLE model_draft.ego_grid_lv_onts")
#result = conn.execute(s)
#result.close()

s = text("SELECT COUNT(id) AS numberofloadareas FROM calc_ego_loads.ego_deu_load_area")
result = conn.execute(s)
for row in result:
    numberofloadareas = row['numberofloadareas']
result.close()

# Iterate over load areas
for w in range(200000,numberofloadareas):
    
    # Initialize variables
    onts = []
    distmax = 250
    xcoord = []
    ycoord = []
    dominated = []
    ont = []
    street_geoms = []
    street_gids = []
    
    print ('new iteration step begins  ', (time.clock() - t0, "seconds process time")) 
       
    # Perform query
    s = text(
            "SELECT ST_AsText(ST_UNION(ST_MULTI(geom))) AS geom, ST_GEOMETRYTYPE(ST_UNION(ST_MULTI(geom))) AS type, \
            AVG(ontnumber) AS ontnumber FROM model_draft.ego_grid_lv_streets WHERE load_area_id = :x")
    result = conn.execute(s, x = w)
    print ("load_area_id:",w)
#    print("type:"+str(type(result)))
    # Get number of ont for this load area
    for row in result:
        #print("row:"+str(row))
        numberofonts = row['ontnumber']
        result2 = row['geom']
        resulttype = row['type']

    # Do nothing if there is no or only one street in the load area:
    if (str(result2) == "None"):
        print ("passed")        
        pass
    elif (resulttype == "ST_LineString"):
        print('only one street in the load area')
    else:
        
        #print ("result2:" + str(result2))
        wkt = loads(result2)
        print ('Create graph  ', (time.clock() - t0, "seconds process time"))   
        # Create graph from lines
        graph = nx.Graph()
        for line in wkt:
            for seg_start, seg_end in zip(list(line.coords),list(line.coords)[1:]):
                graph.add_edge(seg_start, seg_end,)
    
        result.close()

        print ('change to undirected graph  ', (time.clock() - t0, "seconds process time")) 
        # change to undirected graph
        graph = graph.to_undirected()
        
        print ('number of nodes:')
        print (graph.number_of_nodes())
        
        # Leave out very big load_areas due to performance issues
        if(graph.number_of_nodes() > 9000):
            print ("Street network is too large")
        else:
            # Perform positioning algorithm on graph
            
            # Step 1: Mark every node as undominated
            print ('Step 1  ', (time.clock() - t0, "seconds process time")) 
            for x in range(0, graph.number_of_nodes()):
                graph.node[graph.nodes()[x]]['dominated'] = None
            
            # Step 2
            print ('Step 2.1  ', (time.clock() - t0, "seconds process time")) 
            # Step 2.1: Count the number of adjacent nodes for each node:
            for x in range(0, graph.number_of_nodes()):
                adjacent_nodes = len(graph.neighbors(graph.nodes()[x]))
                graph.node[graph.nodes()[x]]['adjacent_undominated'] = adjacent_nodes
                graph.node[graph.nodes()[x]]['ONT'] = False
            
            # Step 2.2: Calculate the length of each edge
            print ('Step 2.2  ', (time.clock() - t0, "seconds process time")) 
            for x in range(0, graph.number_of_edges()):
                first = graph.edges(data=True)[x]
                distance = math.sqrt(sum([(a - b) ** 2 for a, b in zip(first[0],first[1])]))
                graph.edge[first[0]][first[1]]['weight'] = distance         
            #print ('nodes:')
            #print (graph.nodes(data=True)) 
            
            print ('Step 2.3  ', (time.clock() - t0, "seconds process time"))         
            for x in range(0, int(numberofonts)):
                # Step 2.3: Add the node with the most adjacent undominated nodes to onts 
                max_neighbors = max(nx.get_node_attributes(graph, 'adjacent_undominated').values())
                #print('max neighbors:' + str(max_neighbors))
                for y in range (0, graph.number_of_nodes()):
                    if (graph.node[graph.nodes()[y]]['adjacent_undominated'] == max_neighbors):
                        nextont = graph.nodes()[y]
                        graph.node[graph.nodes()[y]]['ONT'] = True
                        onts.append (nextont)
                        break
             
                
                # Step 3: Mark every node within the range of the previously added ont as dominated
                
                # Step 3.1: Calculate the distance for each node and the previously added ont
                distances = nx.single_source_dijkstra_path_length (graph, source = 
                   nextont, cutoff=distmax, weight= 'weight')    
                
                
                # Step 3.2: Mark every node within the range of the previously added ont as dominated
                #print ('distances:')        
                #print (distances)        
                for y in distances.keys():
                    if (graph.node[y]['dominated'] == None):
                        graph.node[y]['dominated'] = x
                        
                        # Step 3.3: For every neighbor of those nodes: Decrease number of adjacent undominated nodes by 1
                        for z in graph.neighbors(y):
                            graph.node[z]['adjacent_undominated'] -= 1
                    else:
                        
                        # if a node is already dominated, change the dominating ont if the distance to the new ont is shorter
                        ont_new = nextont
                        ont_old = onts[graph.node[y]['dominated']]
                        #print ("ont_old:")                
                        #print (ont_old)
                        point = graph.nodes()[graph.nodes().index(y)]
                        pathlength_old = nx.shortest_path_length(graph,source = point,target = ont_old, weight = 'weight')
                        pathlength_new = nx.shortest_path_length(graph,source = point,target = ont_new, weight = 'weight')
                        if ( pathlength_new <= pathlength_old ):
                            graph.node[y]['dominated'] = x    
                        
        
        # assign every node which is not already dominated to a ont
#        print ('Assign rest nodes  ', (time.clock() - t0, "seconds process time"))              
#        for x in range (0,graph.number_of_nodes()):
#            if (graph.node[graph.nodes()[x]]['dominated'] == None):
#                # Calculate the distance to each ont
#                pathlengths = []
#                for y in range(0, int(numberofonts)):
#                    # Check if path between node and ont exists
#                    if (nx.has_path(graph,source = graph.nodes()[x], target = onts[y])):
#                        pathlengths.append(nx.shortest_path_length(graph,source = graph.nodes()[x], target = onts[y], weight = 'weight'))
#                    else:
#                        pathlengths.append(999999999999999)
#                # Assign the ont with the minimal pathlength to the node
#                if (min(pathlengths) < 999999999999999):
#                    graph.node[graph.nodes()[x]]['dominated'] = pathlengths.index(min(pathlengths))
        
        
        
        # Assign onts to edges
#        print ('Assign onts to edges  ', (time.clock() - t0, "seconds process time"))  
#        for x in range(0, graph.number_of_edges()):
#            ed = graph.edges(data=True)[x]
#            graph.edge[ed[0]][ed[1]]['dominated'] = graph.node[ed[1]]['dominated']
        
        
        # create output graph
        out_graph = graph.copy()
        out_graph.remove_nodes_from(graph.nodes())
        out_graph.add_nodes_from(onts)
        
                 
        # Insert values into table
        s = text(
                "Insert into model_draft.ego_grid_lv_onts (geom) SELECT ST_SetSRID(ST_MAKEPOINT(:x,:y),3035)")
        
        for z in range(0, out_graph.number_of_nodes()):
            #print (out_graph.nodes()[z][0])
            result = conn.execute(s, x = out_graph.nodes()[z][0],y = out_graph.nodes()[z][1])
        
        result.close()  


# Add MV substation information to onts
s = text(
    "ALTER TABLE model_draft.ego_grid_mvlv_onts\
    ADD COLUMN subst_id integer;\
    \
    UPDATE model_draft.ego_grid_mvlv_onts AS t1\
    SET subst_id = t2.subst_id FROM\
        (SELECT onts.id AS id, MAX(district.subst_id) AS subst_id\
        FROM model_draft.ego_grid_mvlv_onts AS onts, calc_ego_grid_district.grid_district AS district\
        WHERE ST_INTERSECTS (onts.geom,district.geom)\
        GROUP BY onts.id) AS t2\
    WHERE t1.id = t2.id"
        )

result = conn.execute(s)
result.close() 

# Add load area information to onts
s = text(
    "ALTER TABLE model_draft.ego_grid_mvlv_onts\
    ADD COLUMN la_id integer;\
    \
    UPDATE model_draft.ego_grid_mvlv_onts AS t1\
    SET la_id = t2.la_id FROM\
        (SELECT onts.id AS id, MAX(larea.id) AS la_id\
        FROM model_draft.ego_grid_mvlv_onts AS onts, calc_ego_loads.ego_deu_load_area AS larea\
        WHERE ST_INTERSECTS (onts.geom,larea.geom)\
        GROUP BY onts.id) AS t2\
    WHERE t1.id = t2.id"
        )

result = conn.execute(s)
result.close() 
     
# Close db connection
conn.close()

print ((time.clock() - t0)/3600, "hours process time")


    
   
## Store results ins lists  
#for x in range(0, graph.number_of_nodes()):
#    ont.append(graph.node[graph.nodes()[x]]['ONT'])
#    dominated.append(graph.node[graph.nodes()[x]]['dominated'])
#    xc,yc = graph.nodes()[x]
#    xcoord.append(xc)
#    ycoord.append(yc)
#
#
## write results into csv file
#csv_name = 'process_eGo_lv_grid.csv'
#with open(csv_name,'w',newline = '') as foo:
#    writer = csv.writer(foo,delimiter = ',')
#    for x in range (0, graph.number_of_nodes()):
#        writer.writerow([xcoord[x],ycoord[x],dominated[x], ont[x]])
#   
#
#
#



