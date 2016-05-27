import xml.etree.ElementTree as ET
import gmlparser.LaneClass as lc
import gmlparser.TaskClass as tc
import gmlparser.DataObjClass as dc
import gmlparser.EventClass as ec
import gmlparser.EdgeClass as edc

lanes = []
lanename=[]
actnames=[]
eventnames=[]
act = []
events=[]
donames=[]
dataobjs=[]
edges=[]
edgenames=[]

def make(element,pkg,ap):
    for obj in element:
        if obj.text and len(obj.text.strip()) > 0:
            temp = eval(pkg)(obj.text, 1)
            ap.append(temp)

def display(text,element):
    for obj in element:
        print(text,": ", obj.name)

tree = ET.parse('ego_deu_loads_per_grid_district.graphml')
root = tree.getroot()
print ("Parsing file: ", root)

ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
      'tn': 'http://www.yworks.com/xml/graphml'}

#top = root.find('gml:graph', ns).find('gml:node', ns)
#data = top.find('gml:data', ns)
#tablenode = data.find('tn:TableNode', ns)
#lanename = tablenode.findall('tn:NodeLabel', ns)

for pool in root.iter('{http://www.yworks.com/xml/graphml}TableNode'):
    #print("Found Pool:  ",pool,"  -  ",pool.attrib.values())
    if 'com.yworks.bpmn.Pool' in pool.attrib.values():
        lanename += pool.findall('tn:NodeLabel', ns)

make(lanename,"lc.Lane",lanes)
display("Lane",lanes)

for gnode in root.iter('{http://www.yworks.com/xml/graphml}GenericNode'):
    if "com.yworks.bpmn.Activity.withShadow" in gnode.attrib.values():
        actnames+=gnode.findall('tn:NodeLabel', ns)
    if "com.yworks.bpmn.Artifact.withShadow" in gnode.attrib.values():
        donames += gnode.findall('tn:NodeLabel', ns)
    if "com.yworks.bpmn.Event.withShadow" in gnode.attrib.values():
        eventnames += gnode.findall('tn:StyleProperties', ns)

for gnode in root.iter('{http://www.yworks.com/xml/graphml}GenericGroupNode'):
    if "com.yworks.bpmn.Activity.withShadow" in gnode.attrib.values():
        actnames+=gnode.findall('tn:NodeLabel', ns)

make(actnames,"tc.Task",act)
display("Activity",act)

make(donames,"dc.DataObj",dataobjs)
display("Data Object",dataobjs)

for x in eventnames:
    for property in x:
        if "EVENT_CHARACTERISTIC" in property.attrib["value"]:
            eobj = ec.Event(property.attrib["name"], property.attrib["value"])
            events.append(eobj)

for a in events:
    print("Event: ",a.name, "of type " ,a.type )

for edge in root.iter('{http://graphml.graphdrawing.org/xmlns}edge'):
    edobj = edc.Edge(edge.attrib["source"],edge.attrib["target"])
    edges.append(edobj)

for a in edges:
    print("Edge from: ",a.source, "to" ,a.target )

