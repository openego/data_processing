import xml.etree.ElementTree as ET

from gmlparsing.GraphClass import Graph
from gmlparsing.NodeClass import Node
from gmlparsing.LaneClass import Lane
from gmlparsing.TaskClass import Task
from gmlparsing.DataObjClass import DataObj
from gmlparsing.EventClass import Event
from gmlparsing.EdgeClass import Edge
from gmlparsing.PoolClass import Pool
from gmlparsing.ConnectionClass import Connection
from gmlparsing.GatewayClass import Gateway


tree = ET.parse('ego_deu_loads_per_grid_district.graphml')
root = tree.getroot()

ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
      'tn': 'http://www.yworks.com/xml/graphml'}

allStartEv = []
alltasks= []
alledges = []
alldos = []
allGateways = []
allObj = []

def makeGraph(graphs):
    nodeArray = []
    edgeArray = []
    if graphs is None:
        graphs = root.findall('gml:graph', ns)

    for gIterator in graphs:
        nodes = gIterator.findall('gml:node',ns)
        size = len(nodes)
        if (size > 0):
            if size == 1:
                nodeArray=makeNode(nodes)
            else:
                nodeArray.extend(makeNode(nodes))

        edges = gIterator.findall('gml:edge', ns)
        size = len(edges)
        if (size > 0):
            makeConnectionType(edges)
            if size == 1:
                edgeArray = makeEdge(edges)
            else:
                edgeArray.extend(makeEdge(edges))
            alledges.extend(edgeArray)
        Graph(gIterator.attrib["id"], nodeArray, edgeArray)

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
                allStartEv.extend(makeEvent(activities,tmpArray[-1]))
                alldos.extend(makeDataObj(activities,tmpArray[-1]))
                alltasks.extend(makeTask(activities,tmpArray[-1].name))
                allGateways.extend(makeGateway(activities,tmpArray[-1]))

            pools = d.findall('tn:TableNode',ns)
            if(pools):
                makePool(pools)

    return tmpArray

def makeEdge(edges):
    tmpArray = []
    for eIterator in edges:
        tmpArray.append(Edge(eIterator.attrib["source"],eIterator.attrib["target"]))
    return tmpArray

def makeConnectionType(edges):
    tmpArray = []
    for cIterator in edges:
        connectionData = cIterator.findall('gml:data',ns)
        for d in connectionData:
            connections = d.findall('tn:GenericEdge',ns)
            for cIterator in connections:
                if "com.yworks.bpmn.Connection" in cIterator.attrib.values():
                    connectionNames = cIterator.findall('tn:StyleProperties', ns)
                    for x in connectionNames:
                        for property in x:
                            if "CONNECTION_TYPE" in property.attrib["value"]:
                                cobj = Connection(property.attrib["name"], property.attrib["value"])
                                tmpArray.append(cobj)

    return tmpArray

def makeTask(activities,pos):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Activity.withShadow" in aIterator.attrib.values():
            name = aIterator.find('tn:NodeLabel', ns).text
            tmpArray.append(Task(name, pos))
    return tmpArray

def makeDataObj(activities,pos):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Artifact.withShadow" in aIterator.attrib.values():
            obj = aIterator.find('tn:NodeLabel', ns);
            if(obj and len(obj.text.strip())>0):
                name = obj.text
                tmpArray.append(DataObj(name, pos))
    return tmpArray

def makeEvent(activities, innode):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Event.withShadow" in aIterator.attrib.values():
            eventnames = aIterator.findall('tn:StyleProperties', ns)
            for x in eventnames:
                for property in x:
                    if "EVENT_CHARACTERISTIC" in property.attrib["value"]:
                        eobj = Event(property.attrib["name"], property.attrib["value"],innode)
                        tmpArray.append(eobj)
    return tmpArray

def makeGateway(activities,pos):
    tmpArray = []
    for gIterator in activities:
        if "com.yworks.bpmn.Gateway.withShadow" in gIterator.attrib.values():
            gatewayNames = gIterator.findall('tn:StyleProperties', ns)
            for x in gatewayNames:
                for property in x:
                    if "GATEWAY_TYPE" in property.attrib["value"]:
                        gobj = Gateway(property.attrib["name"], property.attrib["value"],pos)
                        tmpArray.append(gobj)
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


parsing = []
parsing_nodes = []
starts=[]
mids=[]
ends=[]


def getStart():         # fixed start and end at events
    currInd=-1

    for ase in allStartEv:
        if type(ase) is Event and ase.type == 'EVENT_CHARACTERISTIC_START':
            starts.append(ase.position.name)
            parsing.append(ase.type)
            parsing_nodes.append(ase.position)
            currInd += 1

            for ae in alledges:
                if ae.source == ase.position.name:   #if current item has outgoing edge
                    for t in alltasks:
                        if ae.target == t.position:
                            currInd = checkOtherStarts(ae.target, 1,currInd)
                            allStartEv.insert(currInd + 1, t)  # dynamic list tht has all parsing elements
                            #print(t.name)
                            parsing.append(t.name)
                            parsing_nodes.append(t.position)
                            currInd += 1
                            checkNext(ae.target,currInd)

        if type(ase) is Event and (ase.type == 'EVENT_CHARACTERISTIC_INTERMEDIATE_CATCHING' or ase.type == 'EVENT_CHARACTERISTIC_END'):
            #starts.append(ase.position.name)
            parsing.append(ase.type)
            currInd += 1

def checkNext(next,currInd):
    for ae in alledges:
        if ae.source == next:
            newObj = findType(ae.target)

            if type(newObj) is DataObj and newObj.position.name not in parsing_nodes:
                checkOtherStarts(ae.target, 3, currInd)
                parsing.append(newObj.name)
                parsing_nodes.append(newObj.position.name)
                checkNext(newObj.position.name,currInd)

            if type(newObj) is Task and newObj.position not in parsing_nodes:
                checkOtherStarts(ae.target, 3, currInd)
                parsing.append(newObj.name)
                parsing_nodes.append(newObj.position)
                checkNext(newObj.position,currInd)

def checkOtherStarts(target,ttype,ind):
    for ae in alledges:
        if(ae.target==target and ae.source not in starts):
            newElement = findType(ae.source)
            newType = type(newElement)
            #print('another one for ',newElement.name)

            if newElement != '':


                ''' if (ttype is 2 and ind>0):
                    parsing.insert(ind,newElement.name)
                    ind += 1
                else:
                    parsing.append(newElement.name)
                    ind += 1'''

                if newType is DataObj and newElement.position.name not in parsing_nodes:
                    ind += 1
                    #print('appended',newElement.name)
                    parsing.append(newElement.name)
                    parsing_nodes.append(newElement.position.name)
                    ind = checkOtherStarts(newElement.position.name,2,ind) #going to the beginning in reverse

                else:
                    if newType is Task and newElement.position not in parsing_nodes:
                        parsing.append(newElement.name)
                        parsing_nodes.append(newElement.position)
                        ind = checkOtherStarts(newElement.position, 2, ind)
                        #print(newElement.position)
    return ind

def findType(input): # fixed start and end at events
    answer=''
    for d in alldos:
        if input==d.position.name:
            answer=d
            break

    if  answer=='' :
        for t in alltasks:
            if input == t.position:
                answer = t
                break
    return answer

getStart()

for x in parsing:
    if x=='EVENT_CHARACTERISTIC_START':
        print('')
    print(x)
