import xml.etree.ElementTree as ET

from GraphClass import Graph
from NodeClass import Node
from LaneClass import Lane
from TaskClass import Task
from DataObjClass import DataObj
from EventClass import Event
from EdgeClass import Edge
from PoolClass import Pool


tree = ET.parse('ego_deu_loads_per_grid_district.graphml')
root = tree.getroot()

ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
      'tn': 'http://www.yworks.com/xml/graphml'}

def makeGraph(graphs):
    nodeArray = []
    edgeArray = []
    if graphs is None:
        graphs = root.findall('gml:graph', ns)

    for gIterator in graphs:
        Graph(gIterator.attrib["id"],1)

        nodes = gIterator.findall('gml:node',ns)
        size = len(nodes)
        if (size > 0):
            if size == 1:
                nodeArray.append(makeNode(nodes))
            else:
                nodeArray.extend(makeNode(nodes))


        edges = gIterator.findall('gml:edge', ns)
        if (len(edges) > 0):
            edgeArray.append(makeEdge(edges))

def makeNode(nodes):
    tmpArray = []
    for nIterator in nodes:
        tmpArray.append(Node(nIterator.attrib["id"], 1))

        graphs = nIterator.findall('gml:graph', ns)
        if (len(graphs) > 0):
            makeGraph(graphs) #mutual recursion

        data = nIterator.findall('gml:data',ns)
        for d in data:
            activities = d.findall('tn:GenericNode',ns)
            if(activities):
                makeTask(activities)
                makeDataObj(activities)
                makeEvent(activities)

            pools = d.findall('tn:TableNode',ns)
            if(pools):
                makePool(pools)

    return tmpArray

def makeEdge(edges):
    tmpArray = []
    for eIterator in edges:
        tmpArray.append(Edge(eIterator.attrib["source"],eIterator.attrib["target"]))
    return tmpArray

def makeTask(activities):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Activity.withShadow" in aIterator.attrib.values():
            name = aIterator.find('tn:NodeLabel', ns).text
            tmpArray.append(Task(name, 1))
    return tmpArray

def makeDataObj(activities):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Artifact.withShadow" in aIterator.attrib.values():
            obj = aIterator.find('tn:NodeLabel', ns);
            if(obj and len(obj.text.strip())>0):
                name = obj.text
                tmpArray.append(DataObj(name, 1))
    return tmpArray

def makeEvent(activities):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Event.withShadow" in aIterator.attrib.values():
            eventnames = aIterator.findall('tn:StyleProperties', ns)
            for x in eventnames:
                for property in x:
                    if "EVENT_CHARACTERISTIC" in property.attrib["value"]:
                        eobj = Event(property.attrib["name"], property.attrib["value"])
                        tmpArray.append(eobj)
    return tmpArray

def makePool(pools):
    tmpArray = []
    laneArray = []
    for pIterator in pools:
        if "com.yworks.bpmn.Pool" in pIterator.attrib.values():
            completePool = pIterator.findall('tn:NodeLabel', ns)
            name = completePool[0].text
            tmpArray.append(Pool(name, 1))
            completePool.remove(completePool[0])
            laneArray.append(makeLane(completePool,name))
    return tmpArray

def makeLane(lanes,parent):
    tmpArray = []
    for pIterator in lanes:
        name =pIterator.text
        if(len(name.strip())>0):
            tmpArray.append(Lane(name,parent, 1))
    return tmpArray

makeGraph(None)