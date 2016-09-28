import xml.etree.ElementTree as ET
import psycopg2
import sys

from gmlparsing.Stack import Stack
from gmlparsing.GraphClass import Graph
from gmlparsing.NodeClass import Node
from gmlparsing.LaneClass import Lane
from gmlparsing.TaskClass import Task
from gmlparsing.DataObjClass import DataObj
from gmlparsing.AnnotsClass import Annotation
from gmlparsing.EventClass import Event
from gmlparsing.EdgeClass import Edge
from gmlparsing.PoolClass import Pool
from gmlparsing.ConnectionClass import Connection
from gmlparsing.GatewayClass import Gateway


#tree = ET.parse('parallel2.graphml')
##tree = ET.parse('ego_deu_loads_per_grid_district.graphml')
##root = tree.getroot()
##
##ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
##      'tn': 'http://www.yworks.com/xml/graphml'}

allStartEv = []
alltasks= []
alledges = []
alldos = []
allanns = []
allGateways = []
allObj = []
allpnodes = []
allPool = []
endGateways = []

def execGraphmlFile(myFileName):
    print("My file Name------------>",myFileName)
    tree = ET.parse(myFileName)
    root = tree.getroot()

    ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
          'tn': 'http://www.yworks.com/xml/graphml'}
    makeGraph(None,root,ns)
    getStart()
    printParsed(parsing,'main')

def makeGraph(graphs,root,ns):
    
    nodeArray = []
    edgeArray = []
    if graphs is None:
        graphs = root.findall('gml:graph', ns)

    for gIterator in graphs:
        nodes = gIterator.findall('gml:node',ns)

        size = len(nodes)
        if (size > 0):
         nodeArray.extend(makeNode(nodes,root,ns))

        edges = gIterator.findall('gml:edge', ns)
        size = len(edges)
        if (size > 0):
            makeConnectionType(edges,ns)
            if size == 1:
                edgeArray = makeEdge(edges,ns)
            else:
                edgeArray.extend(makeEdge(edges,ns))
            alledges.extend(edgeArray)
        Graph(gIterator.attrib["id"], nodeArray, edgeArray,ns)

def makeNode(nodes,root,ns):
    tmpArray = []
    lvl5=None
    for nIterator in nodes:
        nodename = nIterator.attrib["id"]

        if nIterator.find('tn:NodeLabel', ns):
            nodename = nIterator.find('tn:NodeLabel', ns).text
        tmpArray.append(Node(nodename, nIterator.attrib["id"],ns))


        if 'yfiles.foldertype' in nIterator.attrib:
            for groups in nIterator.iter('{http://www.yworks.com/xml/graphml}GenericGroupNode'):
                labels = groups.findall('tn:NodeLabel', ns)
                for l in labels:
                    if l.text and tmpArray[-1] not in allpnodes and ':' in nIterator.attrib["id"]:
                        tmpArray[-1].name = l.text.replace('\n', ' ').replace('\r', '')
                        allpnodes.append(tmpArray[-1])


        graphs = nIterator.findall('gml:graph', ns)
        if (len(graphs) > 0):
            makeGraph(graphs,root,ns) #mutual recursion

        data = nIterator.findall('gml:data',ns)
        for d in data:
            activities = d.findall('tn:GenericNode',ns)
            if(activities):
                allStartEv.extend(makeEvent(activities,tmpArray[-1],ns))
                alldos.extend(makeDataObj(activities,tmpArray[-1],1,ns))
                allanns.extend(makeDataObj(activities, tmpArray[-1], 2,ns))
                alltasks.extend(makeTask(activities,tmpArray[-1],ns))
                allGateways.extend(makeGateway(activities,tmpArray[-1],ns))

        pools = d.findall('tn:TableNode',ns)
        if(pools):
            allPool.extend(makePool(pools,tmpArray[-1].name,ns))
    return tmpArray

def makeEdge(edges,ns):
    tmpArray = []
    for eIterator in edges:
        tmpArray.append(Edge(eIterator.attrib["source"],eIterator.attrib["target"],ns))
    return tmpArray

def makeConnectionType(edges,ns):
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
                                cobj = Connection(property.attrib["name"], property.attrib["value"],ns)
                                tmpArray.append(cobj)

    return tmpArray

def makeTask(activities,pos,ns):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Activity.withShadow" in aIterator.attrib.values():
            name = aIterator.find('tn:NodeLabel', ns).text
            tmpArray.append(Task(name, pos,ns))
    return tmpArray

def makeDataObj(activities,pos,num,ns):
    tmpArray1 = []
    tmpArray2 = []
    for aIterator in activities:
        if "com.yworks.bpmn.Artifact.withShadow" in aIterator.attrib.values():
            obj = aIterator.find('tn:NodeLabel', ns);
            if obj:
                name = obj.text.replace('\n', ' ').replace('\r', '')
            obj2 = aIterator.find('tn:StyleProperties', ns).findall('tn:Property', ns);
            for anns in obj2:
                if "ARTIFACT_TYPE_ANNOTATION" in anns.attrib.values():
                    tmpArray2.append(Annotation(name, pos,ns))
                if obj and "ARTIFACT_TYPE_DATA_OBJECT" in anns.attrib.values():
                    if len(name.strip())>0:
                        tmpArray1.append(DataObj(name, pos,ns))
    if num==1:
        return tmpArray1
    else:
        return tmpArray2

def makeEvent(activities, innode,ns):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Event.withShadow" in aIterator.attrib.values():
            eventnames = aIterator.findall('tn:StyleProperties', ns)
            for x in eventnames:
                for property in x:
                    if "EVENT_CHARACTERISTIC" in property.attrib["value"]:
                        eobj = Event(property.attrib["name"], property.attrib["value"],innode,ns)
                        tmpArray.append(eobj)
    return tmpArray

def makeGateway(activities,pos,ns):
    tmpArray = []
    for gIterator in activities:
        if "com.yworks.bpmn.Gateway.withShadow" in gIterator.attrib.values():
            gatewayNames = gIterator.findall('tn:StyleProperties', ns)
            for x in gatewayNames:
                for property in x:
                    if "GATEWAY_TYPE" in property.attrib["value"]:
                        gobj = Gateway(property.attrib["name"], property.attrib["value"],pos,ns)
                        tmpArray.append(gobj)
    return tmpArray


def makePool(pools,pos,ns):
    tmpArray = []
    laneArray = []
    for pIterator in pools:
        if "com.yworks.bpmn.Pool" in pIterator.attrib.values():
            completePool = pIterator.findall('tn:NodeLabel', ns)
            name = completePool[0].text
            tmpArray.append(Pool(name, pos,ns))
            completePool.remove(completePool[0])
            laneArray.append(makeLane(completePool,name,ns))

    return tmpArray

def makeLane(lanes,parent,ns):
    tmpArray = []
    for pIterator in lanes:
        name =pIterator.text
        if(len(name.strip())>0):
            tmpArray.append(Lane(name,parent, 1,ns))
    return tmpArray

#makeGraph(None)


parsing = []
parsing_nodes = []
starts=[]
mids=[]
ends=[]
s = Stack()
sForSub = Stack()
sublist = []
sublist2 = []
sgFor = None
sgIndex = 0
sg = False

def runSqlFile(filename,conn): # Function to execute sql scripts
    file = open(filename,'r')
    sql = " ".join(file.readlines())
    cur = conn.cursor()
    #cur.execute("DROP SCHEMA IF EXISTS	orig_geo_opsd CASCADE");
    #cur.execute("CREATE SCHEMA orig_geo_opsd");
    try:
        cur.execute(sql);
    except psycopg2.Error as e:
        print(str(e))
        pass
        #sys.exit(1)
##    Create schemas for open_eGo
##    cur.execute("DROP SCHEMA IF EXISTS orig_ego CASCADE");
##    cur.execute("CREATE SCHEMA orig_ego");
##    cur.execute(sql);
##
##    Set default privileges for schema
##    cur.execute("ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON TABLES TO oeuser");
##    cur.execute("ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON SEQUENCES TO oeuser");
##    cur.execute("ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON FUNCTIONS TO oeuser");
##
##    Grant all in schema
##    cur.execute("GRANT ALL ON SCHEMA orig_ego TO oeuser WITH GRANT OPTION");
##    cur.execute("GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA orig_ego TO oeuser");
    
    conn.commit()
    print ("Records created successfully")

def connectToPostgres(filename): #Function to connect postgres
    conn = psycopg2.connect(database="OpenEgo", user="oeuser", password="sql", host="localhost", port="5432")
    print ("Opened database successfully")
    runSqlFile(filename,conn)
    conn.close()    

def getStart():         # fixed start and end at events
    currInd=-1
    sgFor = None
    sgIndex = 0
    sgIndex2 = 0
    sg = False
    sg2 = False
    newSub = '-'

    for ase in allStartEv:

        if type(ase) is Event and ase.type == 'EVENT_CHARACTERISTIC_START':

            starts.append(ase.position.name)
            parsing.append(ase)
            parsing_nodes.append(ase.position.name)

            if sgFor and sgFor in ase.position.name:
                sublist.insert(0,parsing[-1])
                del parsing[-1]
                sg=True
            else:
                sg = False
                sublist = []
            currInd += 1

            if newSub is not None and newSub != '-' and newSub in ase.position.name:
                sgIndex2 = parsing.index(sublist2)
                sublist2.insert(0, parsing[-1])
                del parsing[-1]
                sg2 = True

            for ae in alledges:
                if ae.source == ase.position.name:   #if current item has outgoing edge
                    for ap in allpnodes:
                        if ae.target == ap.position:
                            sgFor = ap.position

                            currInd = checkOtherStarts(ae.target, currInd, sg,sublist,sg2,sublist2,s)
                            while not s.is_empty():
                                parsing.append(s.pop())
                            parsing.append(ap)
                            allAnnots = getAnnot(ap)
                            parsing.append(allAnnots)
                            #print(allAnnots.name)
                            if allAnnots is not None:
                                connectToPostgres(allAnnots.name)

                            sgIndex = parsing.index(ap) + 1
                            parsing_nodes.append(ap.position)

                            sub = checkNext(ae.target, currInd, sg,sublist,sg2,sublist2,s)
                            if sub is not None:
                                newSub = sub
                            break

                    for t in alltasks:
                        if ae.target == t.position.name:
                            currInd = checkOtherStarts(ae.target,currInd, sg,sublist,sg2,sublist2,s)

                            while not s.is_empty():
                                parsing.append(s.pop())
                                assign(sg,sg2,sublist,sublist2,newSub,ase,'start')

                            parsing.append(t)
                            assign(sg, sg2, sublist, sublist2, newSub, ase,'start')

                            allAnnots = getAnnot(t)
                            parsing.append(allAnnots)
                            
                            
                            if allAnnots is not None:
                                #print(allAnnots.name)
                                connectToPostgres(allAnnots.name)   
                            assign(sg, sg2, sublist, sublist2, newSub, ase,'start')

                            parsing_nodes.append(t.position.name)
                            allStartEv.insert(currInd + 1, t)  # dynamic list tht has all parsing elements
                            currInd += 1

                            sub = checkNext(ae.target,currInd,sg,sublist,sg2,sublist2,s)
                            if sub is not None:
                                newSub = sub

                    if sg==True:
                        parsing.insert(sgIndex, sublist)



        if type(ase) is Event and (ase.type == 'EVENT_CHARACTERISTIC_INTERMEDIATE_CATCHING' or ase.type == 'EVENT_CHARACTERISTIC_END'):
            parsing.append(ase)
            currInd += 1


def assign(sg,sg2,sublist,sublist2,newSub,ase,callfrom):
    if callfrom == 'start':
        if sg == True and parsing[-1] is not None:
            sublist.append(parsing[-1])
            del parsing[-1]
        if newSub is not None and newSub != '-' and newSub in ase.position.name and parsing[-1] is not None:
            sublist2.append(parsing[-1])
            del parsing[-1]

    elif callfrom == 'chnext':
        if sg == True and parsing[-1] is not None:
            sublist.append(parsing[-1])
            del parsing[-1]
        if sg2 == True and parsing[-1] is not None:
            sublist2.append(parsing[-1])
            del parsing[-1]

def getAnnot(t):
    answer = None
    checkWith = None
    if type(t) is Task:
        checkWith = t.position.name
    else:
        checkWith = t.position
    for ae in alledges:
        if ae.target == checkWith or ae.source == checkWith:
            for aa in allanns:
                if aa.name is not None and ae.source == aa.position.name:
                    answer = aa
                    #connectToPostgres(answer.name)
                    break
    return answer

def checkNextParallel(curr_gw,currInd,sg,sublist,sg2,sublist2,s):

    for ae in alledges:
        if ae.source == curr_gw.position.name:
            newObj = findType(ae.target)

            if type(newObj) is Task or  type(newObj) is DataObj:
                checkOtherStarts(newObj.position.name, currInd, sg, sublist, sg2, sublist2, s)
                while not s.is_empty():
                    newElement = s.pop()
                    parsing.append(newElement)
                    parsing_nodes.append(newElement.position.name)

                if newObj.name not in parsing_nodes:
                    #print(newObj.name)
                    parsing_nodes.append(newObj.position.name)
                    parsing.append(newObj)

                checkNextParallel(newObj, currInd, sg, sublist, sg2, sublist2, s)


            else:
                if type(newObj) is Gateway:
                    newObj.name = 'start of Parallel Execution:'
                    parsing.append(newObj)
                    parsing_nodes.append(newObj.position.name)


def checkNext(next,currInd,sg,sublist,sg2,sublist2,s):
    sub = None
    for ae in alledges:
        if ae.source == next:
            newObj = findType(ae.target)

            if type(newObj) is Gateway:
                newObj.name = 'start of Parallel Execution:'
                parsing.append(newObj)

                checkNextParallel(newObj,currInd,sg,sublist,sg2,sublist2,s)
                endOfPE = parsing.pop()
                endOfPE.name = endOfPE.name.replace("start","end")
                endOfPE.name = endOfPE.name.replace(":","")

                parsing.append(endOfPE)
                checkNext(parsing[-1].position.name, currInd,sg,sublist,sg2,sublist2,s)


            if type(newObj) is DataObj and newObj.position.name not in parsing_nodes:
                checkOtherStarts(ae.target, currInd, sg,sublist,sg2,sublist2,s)

                while not s.is_empty():
                    other_start = s.pop()
                    print('starts',other_start )
                    parsing.append(other_start)
                    assign(sg,sg2,sublist,sublist2,None,None,'chnext')
                parsing.append(newObj)
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                parsing_nodes.append(newObj.position.name)
                checkNext(newObj.position.name,currInd,sg,sublist,sg2,sublist2,s)

            if type(newObj) is Task and newObj.position.name not in parsing_nodes:
                checkOtherStarts(ae.target, currInd, sg,sublist,sg2,sublist,s)
                while not s.is_empty():
                    if newObj.name not in parsing_nodes:
                        poppedEle = s.pop()
                        parsing.append(poppedEle)
                        parsing_nodes.append(poppedEle.position.name)
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                if newObj.name not in parsing_nodes:
                    parsing.append(newObj)
                    parsing_nodes.append(newObj.position.name)

                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing.append(getAnnot(newObj))
                    allAnnots = getAnnot(newObj)
                    #print(allAnnots.name)
                    #connectToPostgres(allAnnots.name)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                    checkNext(newObj.position.name, currInd,sg,sublist,sg2,sublist2,s)

            if type(newObj) is Node and newObj.position not in parsing_nodes:
                checkOtherStarts(ae.target, currInd, sg,sublist,sg2,sublist2,s)
                while not s.is_empty():
                    parsing.append(s.pop())
                parsing.append(newObj)

                sgIndex = parsing.index(newObj) + 1

                sub = newObj.position
                parsing_nodes.append(newObj.position)

                parsing.append(getAnnot(newObj))
                allAnnots = getAnnot(newObj)
                if allAnnots is not None:
                    connectToPostgres(allAnnots.name)
                #print(allAnnots.name)
               # connectToPostgres(allAnnots.name)
                checkNext(newObj.position, currInd, sg,sublist,sg2,sublist2,s)

                parsing.insert(sgIndex, sublist2)
    return sub

def checkOtherStarts(target,ind, sg,sublist,sg2,sublist2,s):
    for ae in alledges:
        if(ae.target==target and ae.source not in starts):
            newElement = findType(ae.source)
            newType = type(newElement)

            if newElement != '' or newElement is not None:
                if newType is DataObj and newElement.position.name not in parsing_nodes:
                    s.push(newElement)
                    parsing_nodes.append(newElement.position.name)
                    ind = checkOtherStarts(newElement.position.name, ind, sg, sublist, sg2, sublist2, s)

                if newType is Gateway:# and 'end' in newElement.position.name:
                    #print('Gateway before',newElement.position.name);
                    endGateways.append(newElement.position.name)

                if newType is Task and newElement.position.name not in parsing_nodes:
                    ind = checkOtherStarts(newElement.position.name, ind, sg, sublist, sg2, sublist2,s)
                    while not s.is_empty():
                        parsing.append(s.pop())
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing.append(newElement)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing_nodes.append(newElement.position.name)

                if newType is Node and newElement.position not in parsing_nodes:
                    ind = checkOtherStarts(newElement.position, ind, sg, sublist, sg2, sublist2,s)
                    while not s.is_empty():
                        parsing.append(s.pop())
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing.append(newElement)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing_nodes.append(newElement.position)

    return ind

def findType(input):
    answer=''
    for d in alldos:
        if input==d.position.name:
            answer=d
            break

    if  answer=='' :
        for t in alltasks:
            if input == t.position.name:
                answer = t
                break

    if answer == '':
        for ap in allpnodes:
            if input == ap.position:
                answer = ap
                break

    if answer == '':
        for e in allStartEv:
            if type(e) is Event and input == e.position.name:
                answer = e
                break

    if answer == '':
        for g in allGateways:
            if type(g) is Gateway and input == g.position.name:
                answer = g
                break

    return answer

def printParsed(toPrint,dtype):
    for x in toPrint:
        if type(x) is Event:
            if x.type == 'EVENT_CHARACTERISTIC_START' and dtype=='main':
                print('')
            if dtype == 'sub':
                print('\t', end="")
            print('Event: ',x.type)
        elif type(x) is Gateway:
            if dtype == 'sub':
                print('\t', end="")
            print('Gateway: ', x.name)
        elif type(x) is Node:
            if dtype == 'sub':
                print('\t', end="")
            print('Subgraph: ', x.name)
        elif type(x) is Task or type(x) is DataObj or type(x) is Annotation:
            if dtype=='sub':
                print('\t', end="")
            print(type(x).__name__,': ',x.name)
        elif type(x) is list:
            if dtype == 'sub':
                print('\t', end="")
            printParsed(x,'sub')
        #else:
            #print(type(x),': ',x)

getStart()
printParsed(parsing,'main')
