import xml.etree.ElementTree as ET
import psycopg2
import copy
import sys
import itertools
import random


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


parsing = []
parsing_nodes = []
starts = []
s = Stack()
sForSub = Stack()
sublist = []
sublist2 = []
sgFor = None
sgIndex = 0
sg = False
COSrerun = 0
tempStack = Stack()
otherstarts = []
par_path = []
permCount = 0
permCount2 = 0
repetition = 1
run_counter = 1
gw_child_seq = []
endGateways = []
activeStates = []
restartWith = []
incomplete_gw = ()

allStartEv = []
alltasks = []
alledges = []
alldos = []
allanns = []
allGateways = []
allObj = []
allpnodes = []
allPool = []


def clear_for_start():
    global parsing
    global parsing_nodes
    global sublist
    global sublist2
    global sgForNone
    global sgIndex
    global sgFalse
    global COSrerun
    global otherstarts
    global permCount
    global permCount2
    global endGateways
    global activeStates
    global restartWith
    global allStartEv


    parsing = []
    parsing_nodes = []
    starts = []
    s = Stack()
    sForSub = Stack()
    sublist = []
    sublist2 = []
    sgFor = None
    sgIndex = 0
    sg = False
    COSrerun = 0
    tempStack = Stack()
    otherstarts = []
    par_path = []
    permCount = 0
    permCount2 = 0
    endGateways = []
    activeStates = []
    restartWith = []
    
def execGraphmlFile(myFileName):
    global repetition
    global run_counter

    print("My file Name------------>", myFileName)
    tree = ET.parse(myFileName)
    root = tree.getroot()

    ns = {'gml': 'http://graphml.graphdrawing.org/xmlns',
          'tn': 'http://www.yworks.com/xml/graphml'}
    makeGraph(None, root, ns)
    #for rep in range(0,repetition):
    getStart()
    printParsed(parsing, 'main')
    for rep in range(0,repetition-1):
        clear_for_start()

        run_counter += 1
        getStart()
        printParsed(parsing, 'main')



def makeGraph(graphs, root, ns):
    nodeArray = []
    edgeArray = []
    if graphs is None:
        graphs = root.findall('gml:graph', ns)

    for gIterator in graphs:
        nodes = gIterator.findall('gml:node', ns)

        size = len(nodes)
        if (size > 0):
            nodeArray.extend(makeNode(nodes, root, ns))

        edges = gIterator.findall('gml:edge', ns)
        size = len(edges)
        if (size > 0):
            makeConnectionType(edges, ns)
            if size == 1:
                edgeArray = makeEdge(edges, ns)
            else:
                edgeArray.extend(makeEdge(edges, ns))
            alledges.extend(edgeArray)
        Graph(gIterator.attrib["id"], nodeArray, edgeArray, ns)


def makeNode(nodes, root, ns):
    tmpArray = []
    lvl5 = None
    for nIterator in nodes:
        nodename = nIterator.attrib["id"]

        if nIterator.find('tn:NodeLabel', ns):
            nodename = nIterator.find('tn:NodeLabel', ns).text
        tmpArray.append(Node(nodename, nIterator.attrib["id"], ns))

        if 'yfiles.foldertype' in nIterator.attrib:
            for groups in nIterator.iter('{http://www.yworks.com/xml/graphml}GenericGroupNode'):
                labels = groups.findall('tn:NodeLabel', ns)
                for l in labels:
                    if l.text and tmpArray[-1] not in allpnodes:  # and ':' in nIterator.attrib["id"]:
                        tmpArray[-1].name = l.text.replace('\n', ' ').replace('\r', '')
                        allpnodes.append(tmpArray[-1])

        graphs = nIterator.findall('gml:graph', ns)
        if (len(graphs) > 0):
            makeGraph(graphs, root, ns)  # mutual recursion

        data = nIterator.findall('gml:data', ns)
        for d in data:
            activities = d.findall('tn:GenericNode', ns)
            if (activities):
                allStartEv.extend(makeEvent(activities, tmpArray[-1], ns))
                alldos.extend(makeDataObj(activities, tmpArray[-1], 1, ns))
                allanns.extend(makeDataObj(activities, tmpArray[-1], 2, ns))
                alltasks.extend(makeTask(activities, tmpArray[-1], ns))
                allGateways.extend(makeGateway(activities, tmpArray[-1], ns))

        pools = d.findall('tn:TableNode', ns)
        if (pools):
            allPool.extend(makePool(pools, tmpArray[-1].name, ns))
    return tmpArray


def makeEdge(edges, ns):
    tmpArray = []
    for eIterator in edges:
        tmpArray.append(Edge(eIterator.attrib["source"], eIterator.attrib["target"], ns))
    return tmpArray


def makeConnectionType(edges, ns):
    tmpArray = []
    for cIterator in edges:
        connectionData = cIterator.findall('gml:data', ns)
        for d in connectionData:
            connections = d.findall('tn:GenericEdge', ns)
            for cIterator in connections:
                if "com.yworks.bpmn.Connection" in cIterator.attrib.values():
                    connectionNames = cIterator.findall('tn:StyleProperties', ns)
                    for x in connectionNames:
                        for property in x:
                            if "CONNECTION_TYPE" in property.attrib["value"]:
                                cobj = Connection(property.attrib["name"], property.attrib["value"], ns)
                                tmpArray.append(cobj)

    return tmpArray


def makeTask(activities, pos, ns):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Activity.withShadow" in aIterator.attrib.values():
            name = aIterator.find('tn:NodeLabel', ns).text
            tmpArray.append(Task(name, pos, ns))
    return tmpArray


def makeDataObj(activities, pos, num, ns):
    tmpArray1 = []
    tmpArray2 = []
    name = ""
    for aIterator in activities:
        if "com.yworks.bpmn.Artifact.withShadow" in aIterator.attrib.values():
            obj = aIterator.find('tn:NodeLabel', ns)

            if obj is not None and obj.text is not None:

                name = obj.text.replace('\n', ' ').replace('\r', '')

            obj2 = aIterator.find('tn:StyleProperties', ns).findall('tn:Property', ns)

            for anns in obj2:
                    if "ARTIFACT_TYPE_ANNOTATION" in anns.attrib.values():
                        tmpArray2.append(Annotation(name, pos, ns))
                    if obj is not None and "ARTIFACT_TYPE_DATA_OBJECT" in anns.attrib.values():
                        if len(name.strip()) > 0:
                            tmpArray1.append(DataObj(name, pos, ns))
    if num == 1:
        return tmpArray1
    else:
        return tmpArray2


def makeEvent(activities, innode, ns):
    tmpArray = []
    for aIterator in activities:
        if "com.yworks.bpmn.Event.withShadow" in aIterator.attrib.values():
            eventnames = aIterator.findall('tn:StyleProperties', ns)
            for x in eventnames:
                for property in x:
                    if "EVENT_CHARACTERISTIC" in property.attrib["value"]:
                        eobj = Event(property.attrib["name"], property.attrib["value"], innode, ns)
                        tmpArray.append(eobj)
    return tmpArray


def makeGateway(activities, pos, ns):
    tmpArray = []
    for gIterator in activities:
        if "com.yworks.bpmn.Gateway.withShadow" in gIterator.attrib.values():
            gatewayNames = gIterator.findall('tn:StyleProperties', ns)
            for x in gatewayNames:
                for property in x:
                    if "GATEWAY_TYPE" in property.attrib["value"]:
                        gobj = Gateway(property.attrib["name"], property.attrib["value"], pos, ns)
                        tmpArray.append(gobj)
    return tmpArray


def makePool(pools, pos, ns):
    tmpArray = []
    laneArray = []
    for pIterator in pools:
        if "com.yworks.bpmn.Pool" in pIterator.attrib.values():
            completePool = pIterator.findall('tn:NodeLabel', ns)
            name = completePool[0].text
            tmpArray.append(Pool(name, pos, ns))
            completePool.remove(completePool[0])
            laneArray.append(makeLane(completePool, name, ns))

    return tmpArray


def makeLane(lanes, parent, ns):
    tmpArray = []
    for pIterator in lanes:
        name = pIterator.text
        if (len(name.strip()) > 0):
            tmpArray.append(Lane(name, parent, 1, ns))
    return tmpArray


def runSqlFile(filename, conn):  # Function to execute sql scripts
    file = open(filename, 'r')
    sql = " ".join(file.readlines())
    cur = conn.cursor()
    # cur.execute("DROP SCHEMA IF EXISTS	orig_geo_opsd CASCADE");
    # cur.execute("CREATE SCHEMA orig_geo_opsd");
    try:
        cur.execute(sql);
    except psycopg2.Error as e:
        print(str(e))
        pass
        # sys.exit(1)
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
    print("Records created successfully")


def connectToPostgres(filename):  # Function to connect postgres
    conn = psycopg2.connect(database="OpenEgo", user="oeuser", password="sql", host="localhost", port="5432")
    print("Opened database successfully")
    runSqlFile(filename, conn)
    conn.close()


def getStart():  # fixed start and end at events
    currInd = -1
    sgFor = None
    sgIndex = 0
    sgIndex2 = 0
    sg = False
    sg2 = False
    newSub = '-'
    gwCount = 0

    for ase in allStartEv:

        if type(ase) is Event and ase.type == 'EVENT_CHARACTERISTIC_START' and ase.position.name not in parsing_nodes:

            starts.append(ase.position.name)
            parsing.append(ase)
            parsing_nodes.append(ase.position.name)

            if sgFor and sgFor in ase.position.name:
                sublist.insert(0, parsing[-1])
                del parsing[-1]
                sg = True
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
                if ae.source == ase.position.name:  # if current item has outgoing edge
                    for ap in allpnodes:
                        if ae.target == ap.position:
                            sgFor = ap.position

                            currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist2, s, COSrerun)
                            while not s.is_empty():
                                parsing.append(s.pop())
                                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')
                            parsing.append(ap)
                            assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')

                            allAnnots = getAnnot(ap)
                            if allAnnots is not None:
                                parsing.append(allAnnots)
                                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')
                            # print(allAnnots.name)
                            # if allAnnots is not None:
                            #    connectToPostgres(allAnnots.name)

                            sgIndex = parsing.index(ap) + 1
                            parsing_nodes.append(ap.position)

                            sub = checkNext(ae.target, currInd, sg, sublist, sg2, sublist2, s)
                            if sub is not None:
                                newSub = sub
                            break

                    for t in alltasks:
                        if ae.target == t.position.name:
                            currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist2, s, COSrerun)

                            while not s.is_empty():
                                parsing.append(s.pop())
                                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')
                            parsing.append(t)
                            assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')

                            allAnnots = getAnnot(t)
                            if allAnnots is not None:
                                parsing.append(allAnnots)
                            # if allAnnots is not None:
                            # print(allAnnots.name)
                            #    connectToPostgres(allAnnots.name)
                                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')

                            parsing_nodes.append(t.position.name)
                            # allStartEv.insert(currInd + 1, t)  # dynamic list tht has all parsing elements
                            # currInd += 1

                            sub = checkNext(ae.target, currInd, sg, sublist, sg2, sublist2, s)

                            if sub is not None:
                                newSub = sub

                    if sg == True:
                        parsing.insert(sgIndex, sublist)
                        #assign(sg, sg2, sublist, sublist2, newSub, ase, 'chnext')

        if type(ase) is Event and (
                ase.type == 'EVENT_CHARACTERISTIC_INTERMEDIATE_CATCHING' or ase.type == 'EVENT_CHARACTERISTIC_END'):

            if (ase.position.name not in parsing_nodes):
                parsing.append(ase)
                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')
                parsing_nodes.append(ase.position.name)
                currInd += 1


def assign(sg, sg2, sublist, sublist2, newSub, ase, callfrom):
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
                    # connectToPostgres(answer.name)
                    break
    return answer

# def findEnd(activeStates):
#     activetypes = []
#     over = False
#     for st in activeStates:
#         #activetypes.append(type(st))
#         if type(st) is Gateway:
#             over = True
#             break
#     return over

def rotate(l, n):
    return l[n:] + l[:n]

def checkNextParallel3( curr_gw, currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2):
    global activeStates
    curr_gw.name = 'Gateway ' + curr_gw.position.name

    #remove any parents if in list
    allAct = []
    if set(curr_gw.parents).issubset(parsing_nodes):
        for allAS in activeStates:
            allAct.append(allAS.position.name)
        activeStates = [x for x in activeStates if x.position.name not in (allAct and curr_gw.parents)]

        parsing_nodes.append(curr_gw.position.name)
        if currInd >= 0:
            activeStates.insert(currInd, curr_gw)
        else:
            activeStates.append(curr_gw)
        printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)

    # It is a fork
        if len(curr_gw.parents) == 1:
            #remove gateway and replace by it's successors
            otherstarts = []
            temp_starts = []
            new_pos = activeStates.index(curr_gw)
            activeStates.remove(curr_gw)

            for eachChild in curr_gw.children:
                currobj = getFullElement(eachChild)

                if currobj not in activeStates:
                    temp_starts = checkTopStart(eachChild, currInd, sg, sublist, sg2, sublist2, s, 0, temp_starts)

                    if len(temp_starts) == 0:
                        #activeStates.append(currobj)
                        activeStates.insert(new_pos, currobj)
                      #  currInd += 1
                        parsing_nodes.append(currobj.position.name)
                    else:
                        otherstarts.extend(temp_starts)
                        for t in temp_starts:
                            parsing_nodes.append(t.position.name)
                        temp_starts.clear()



            # displaying states
            if len(otherstarts) > 0:
                #activeStates.extend(otherstarts)
                activeStates[new_pos:new_pos] = otherstarts
                #currInd += len(otherstarts)
                new_pos += len(otherstarts)
                printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)

                otherstarts.clear()
            else:
                printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)

            ######### taking steps until the end
            while len(activeStates) > 1:
                for state in activeStates:
                    if isinstance(parsing[-1],str) and 'Gateway' in parsing[-1]:
                        return activeStates
                    if isDeadEnd(state):
                        activeStates.remove(state)
                        continue
                    takeStep2( state, currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2)


        else:
            #it is a join (and fork)
            weiter = False
            for eachParent in curr_gw.parents:
                if eachParent in parsing_nodes:
                    weiter = True
                else:
                    weiter = False
                    break

            #if it is active
            if weiter is True:

                #it is a fork as well
                if len(curr_gw.children) > 1:
                    for eachChild in curr_gw.children:
                        takeStep2( getFullElement(eachChild), currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2)
                #it is a join
               # else:
                    #ap#  activeStates.remove(curr_gw)


    # else:
    #     return
    return activeStates

def takeStep2( state,currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2):
    global activeStates
    global incomplete_gw

    flag = 0
    it = 0
    for ae2 in alledges:
        if ae2.source == state.position.name:
            for iter in activeStates:
                if(iter.position.name==state.position.name):

                    prev = getFullElement(ae2.source)
                    nextObj = getFullElement(ae2.target)
                    new_pos = it

                    if nextObj is None or type(nextObj) is Gateway:
                        if parsing [-1] is str and nextObj.position.name in parsing[-1]:
                            return activeStates
                        if type(nextObj) is Gateway:
                            if len(nextObj.parents) == 0:
                                Gateway.getParents(nextObj, alledges)
                            if len(nextObj.children) == 0:
                                Gateway.getChildren(nextObj, alledges)


                            signal = check_if_active2( prev, nextObj, new_pos,
                                                                      sg, sublist, sg2, sublist2, s, permCount, permCount2)
                            if len(restartWith) == 0:
                                # display end
                                return activeStates
                         #   else:
                          #      activeStates = copy.copy(restartWith)
                    else:
                        # replace prev step by current task
                        if 'Gateway' in parsing[-1] and len(activeStates) < parsing[-1].count('-'):
                            flag = 1
                            list_inc_gw = list(incomplete_gw)
                            activeStates.insert(list_inc_gw[1], list_inc_gw[0])
                            if list_inc_gw[1] < it:
                                it = it + 1

                        del activeStates[it]
                        temp_starts = []
                        temp_starts = checkTopStart(nextObj.position.name, currInd, sg, sublist, sg2, sublist2, s, 0, temp_starts)

                        if len(temp_starts) == 0:
                                parsing_nodes.append(nextObj.position.name)

                                Node.getParents(nextObj, alledges)
                                signal = check_if_active2( prev, nextObj, new_pos, sg, sublist,
                                                                            sg2, sublist2, s, permCount, permCount2)


                                activeStates.insert(it, copy.deepcopy(nextObj))
                                printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)


                        else:
                            otherstarts.extend(temp_starts)

                            for t in temp_starts:
                                Node.getParents(t, alledges)
                                signal = check_if_active2( prev, t, new_pos, sg, sublist,
                                                                          sg2, sublist2, s, permCount, permCount2)
                                parsing_nodes.append(t.position.name)
                            temp_starts.clear()


                            activeStates[it:it] = otherstarts
                            printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)

                            activeStates = [x for x in activeStates if x not in otherstarts]
                            otherstarts.clear()


                            activeStates.insert(it, copy.deepcopy(nextObj))
                            printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext', permCount, permCount2)
                           # currInd += 1

                        if flag == 1:
                            # remove gw
                            list_inc_gw = list(incomplete_gw)
                            if(list_inc_gw[0]) in activeStates:
                                activeStates.remove(list_inc_gw[0])
                            flag = 0
                        break
                else:
                    it = it + 1
            break
    return  activeStates

# def checkNextParallel2(activeStates, curr_gw, currInd, sg, sublist, sg2, sublist2, s):
#     #getting parallelly active states
#     for ae2 in alledges:
#         if ae2.source == curr_gw.position.name:
#             currobj = getFullElement(ae2.target)
#             if currobj not in activeStates:
#                 parsing_nodes.append(curr_gw.position.name)
#                 activeStates.append(currobj)
#
#     # displaying states
#     printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext')
#
#     #taking steps
#     for state in activeStates:
#        takeStep(activeStates, state, currInd, sg, sublist, sg2, sublist2, s)
#
#     weiter = False
#     for state in activeStates:
#         if(type(state) is not Gateway):
#             takeStep(activeStates, state, currInd, sg, sublist, sg2, sublist2, s)
#
#     for state in activeStates:
#         if (type(state) is Gateway):
#             state.name = 'Gateway' + state.position.name
#             weiter = True
#         else:
#             weiter = False
#
#
#     if weiter is True:
#         checkNext(state.position.name, currInd, sg, sublist, sg2, sublist2, s)
#         #for state in activeStates:
#          #   children = get_outgoing(state)
#           #  print('Gateway ',state.name,' has ',children, ' children')
#         #checkNext(state.position.name, currInd, sg, sublist, sg2, sublist2, s)
#         #checkNextParallel2(state, currInd, sg, sublist, sg2, sublist2, s)
#         return
#
# def get_outgoing (node):
#     num = 0
#     for ae3 in alledges:
#         if ae3.source == node.position.name:
#             num+=1
#     return num

def printActiveStates(activeStates,sg, sg2, sublist, sublist2, newSub, ase, callFrom, permCount, permCount2):
    line = '{'
    for state in activeStates:
        line += state.name + " - "
        parsing_nodes.append(state.position.name)
    line += '}'

    #pe_count = permCount.__str__()
    pe_count = run_counter.__str__()
    if permCount2 > 0:
        pe_count += "." + permCount2.__str__()


    line = 'Parallel execution option '+ pe_count + ': ' + line

    if parsing[-1] is not None:
        if not isinstance(parsing[-1], str) or (sg2==True and line not in sublist2[-1]) or (line not in parsing[-1]):

            parsing.append(line)
            assign(sg, sg2, sublist, sublist2, newSub, ase, 'chnext')

            #strip brackets, space and last '-'
            line = line[1:-3]
            par_path.append(line)

# def takeStep(activeStates, state,currInd, sg, sublist, sg2, sublist2, s):
#
#     it = 0
#
#     for ae2 in alledges:
#         if ae2.source == state.position.name:
#
#             for iter in activeStates:
#                 #replace prev step by current task
#                 if(iter.position.name==state.position.name):
#                     activeStates[it] = copy.deepcopy(getFullElement((ae2.target)))
#
#                     if type(getFullElement(ae2.target)) is Gateway:
#                         activeStates[it].name = state.name
#                         signal = check_if_active(activeStates, getFullElement(ae2.target), currInd, sg, sublist, sg2, sublist2, s)
#
#                         if signal == 'go':
#
#                             return
#
#                         break
#                     printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext')
#                     break
#                 else:
#                     it = it + 1
#     return
#
# def is_gateway():
#     result = False
#     for state in activeStates:
#         if 'Gateway' in state.name:
#             result = state
#             break
#     return  result

def check_if_active2(prev, element, currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2):
    global restartWith
    global activeStates
    global incomplete_gw

    signal = 'wait'
    allactive = []
    allinputs = []

    for allAS in activeStates:
        allactive.append(allAS.position.name)

    for allAI in element.parents:
        allinputs.append(allAI)

    # replace multiple inputs by next gateway

    if set(allinputs).issubset(set(allactive)) or (parsing[-1] is str and element.position.name in parsing[-1]):
        signal = 'go'
        permCount2 = 0
        if prev in activeStates:
            new_pos = activeStates.index(prev)
        else:
            #new_pos = len(activeStates)
            new_pos = copy.copy(currInd)
        activeStates = [x for x in activeStates if x.position.name not in allinputs]

        if type(element) is Gateway:
                incomplete_gw = (element, new_pos)

                if len(element.children) == 1:
                     if len(restartWith) > 0:
                         #display end
                         element.name = 'Gateway '+element.position.name
                         activeStates.insert(new_pos,element)
                         printActiveStates(activeStates, sg, sg2, sublist, sublist2, None, None, 'chnext', permCount,   permCount2)


                         #restart
                         activeStates = copy.copy(restartWith)


                     else:
                        checkNextParallel3( element, new_pos, sg, sublist, sg2, sublist2, s,
                                                      permCount, permCount2)
                else:
                    restartWith = copy.copy(activeStates)

                    child_counter = 0
                    for combo2 in itertools.permutations(element.children):
                         child_counter += 1
                         each_combo2 = list(combo2)

                         if permCount2 > 0:
                             element.children = each_combo2
                         permCount2 += 1

                         if child_counter == len(element.children):
                             restartWith.clear()

                         checkNextParallel3( element, new_pos, sg, sublist, sg2, sublist2, s,
                                                           permCount, permCount2)

    else:
        signal = 'wait'
        if type(element) is Gateway:
            nonActiveStates = [x for x in allactive if x not in allinputs]

            if len(nonActiveStates) == 0 and len(allactive) < len(allinputs):
                nonActiveStates = [x for x in allinputs if x not in allactive]
        else:
            nonActiveStates = [x for x in allactive if x not in parsing_nodes]


        if len(nonActiveStates) == 0:
            signal = 'go'
        else:

            for x in nonActiveStates:

                ele_to_insert = getFullElement(x)
                if type(ele_to_insert) is Gateway:
                    activeStates.insert(currInd, ele_to_insert)
                else:

                    takeStep2( ele_to_insert, currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2)



    return signal


# def check_if_active(activeStates,gateway, currInd, sg, sublist, sg2, sublist2, s):
#     allinputs = []
#     allactive = []
#
#     for ae3 in alledges:
#         if ae3.target == gateway.position.name:
#             allinputs.append(getFullElement(ae3.source).name)
#
#     for allAS in activeStates:
#         allactive.append(allAS.name)
#
#     #replace multiple inputs by next gateway
#     if set(allinputs).issubset(set(allactive)):
#         activeStates = [x for x in activeStates if x.name not in allinputs]
#
#         gateway.name = 'Gateway '+gateway.position.name
#         activeStates.append(gateway)
#         printActiveStates(activeStates,sg, sg2, sublist, sublist2, None, None, 'chnext')
#
#         #check for multiple gateways
#         multi_gateway = len(activeStates)
#         signal = 'wait'
#         if multi_gateway > 1:
#             weiter = check_all_g(activeStates)
#
#             if weiter is True:
#                 for state in activeStates:
#                      children = get_outgoing(state)
#                      print('Gateway ',state.name,' has ',children, ' children')
#                      if children <= 1:
#                          checkNext(state.position.name, currInd, sg, sublist, sg2, sublist2, s)
#                      else:
#                          checkNextParallel2(state, currInd, sg, sublist, sg2, sublist2, s)
#
#             else:
#                 for state in activeStates:
#                     if type(state) is not Gateway:
#                         takeStep(activeStates, state, currInd, sg, sublist, sg2, sublist2, s)
#
#         else:
#             signal = 'go'
#         return signal
# def check_all_g(ctiveStates):
#     weiter = False
#     for state in activeStates:
#         if type(state) is Gateway:
#             weiter = True
#         else:
#             weiter = False
#     return weiter
#
# def checkNextParallel(curr_gw, currInd, sg, sublist, sg2, sublist2, s):
#     for ae2 in alledges:
#         if ae2.source == curr_gw.position.name:
#             newObj = getFullElement(ae2.target)
#
#             if type(newObj) is Task or type(newObj) is DataObj:
#
#                 checkOtherStarts(newObj.position.name, currInd, sg, sublist, sg2, sublist2, s, COSrerun)
#                 while not s.is_empty():
#                     newElement = s.pop()
#                     parsing.append(newElement)
#                     assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
#                     parsing_nodes.append(newElement.position.name)
#
#                 if newObj.name not in parsing_nodes:
#                     # print(newObj.name)
#                     parsing_nodes.append(newObj.position.name)
#                     parsing.append(newObj)
#                     assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
#                 checkNextParallel(newObj, currInd, sg, sublist, sg2, sublist2, s)
#
#
#             else:
#                 if type(newObj) is Gateway:
#                     newObj.name = 'end of Parallel Execution'
#                     parsing.append(newObj)
#                     assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
#                     parsing_nodes.append(newObj.position.name)

def isDeadEnd(state):
    isLast = True
    for ae in alledges:
        if state.position.name in ae.source:
            isLast = False
            break
    return isLast

def getFactorial(n):
    if n == 0:
        return 1
    else:
        return n * getFactorial(n - 1)

def checkNext(next, currInd, sg, sublist, sg2, sublist2, s):
    global activeStates
    global repetition
    global gw_child_seq
    global run_counter

    sub = None
    for ae in alledges:
        if ae.source == next:
            newObj = getFullElement(ae.target)
            if type(newObj) is Gateway:
                if len(newObj.parents) == 0:
                    Gateway.getParents(newObj, alledges)
                if len(newObj.children) == 0:
                    Gateway.getChildren(newObj, alledges)

                chk = [pars for pars in parsing if type(pars) is str and "Gateway" in pars]
                permCount = 0
                rep_gw = newObj

                if run_counter == 1:
                    all_combinations = list(itertools.permutations(rep_gw.children))
                    repetition += len(all_combinations) - 1 #-1 for first run

                    for combo in all_combinations:
                        #print('add children globally: ',combo)
                        gw_child_seq.append(combo)
                #            each_combo = list(combo)
                 #           if repetition > 0:
                 #               repetition += 1
                #                rep_gw.children = each_combo
                 #               activeStates.clear()
                 #           permCount += 1

                rep_gw.children = list(gw_child_seq[run_counter - 1])
                permCount += 1
                checkNextParallel3( rep_gw, -1 , sg, sublist, sg2, sublist2, s, permCount, permCount2)


              #  else:
              #      parsing.append('run 2')

               #     checkNextParallel3( newObj, currInd, sg, sublist, sg2, sublist2, s, permCount, permCount2)

                gw_pos = activeStates[-1].position.name
                checkNext( gw_pos, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is DataObj and newObj.position.name not in parsing_nodes:
                currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist2, s, COSrerun)

                while not s.is_empty():
                    other_start = s.pop()
                    # print('starts',other_start )
                    parsing.append(other_start)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                parsing.append(newObj)
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                parsing_nodes.append(newObj.position.name)
                checkNext(newObj.position.name, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is Task and newObj.position.name not in parsing_nodes:

                currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist, s, COSrerun)
                while not s.is_empty():
                    if newObj.name not in parsing_nodes:
                        poppedEle = s.pop()
                        parsing.append(poppedEle)
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                        parsing_nodes.append(poppedEle.position.name)

                if newObj.name not in parsing_nodes:
                    parsing.append(newObj)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing_nodes.append(newObj.position.name)

                    allAnnots = getAnnot(newObj)
                    if allAnnots is not None:
                        parsing.append(allAnnots)

                    # print(allAnnots.name)
                    # connectToPostgres(allAnnots.name)
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                checkNext(newObj.position.name, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is Node and newObj.position not in parsing_nodes:
                currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist2, s, COSrerun)
                while not s.is_empty():
                    parsing.append(s.pop())
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                parsing.append(newObj)
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                sgIndex = parsing.index(newObj) + 1

                sub = newObj.position
                parsing_nodes.append(newObj.position)

                #allAnnots = getAnnot(newObj)
                #assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

  #              if allAnnots is not None:
 #                    parsing.append(allAnnots)
#                     connectToPostgres(allAnnots.name)
                # print(allAnnots.name)
                # connectToPostgres(allAnnots.name)
                #assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

                parsing.insert(sgIndex, sublist2)
                checkNext(newObj.position, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is Event and newObj.position.name not in parsing_nodes:
                parsing.append(newObj)
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                parsing_nodes.append(newObj.position.name)
                checkNext( newObj.position.name, currInd, sg, sublist, sg2, sublist2, s)
                break
    return sub

def checkTopStart(target, ind, sg, sublist, sg2, sublist2, s, COSrerun,otherstarts):
    for ae in alledges:
        if (ae.target == target and ae.source not in starts):
            newElement = getFullElement(ae.source)
            newType = type(newElement)

            if newElement != '' or newElement is not None:
                #if newType is DataObj and newElement.position.name not in parsing_nodes:
                if newType is DataObj:
                    if (COSrerun == 0):
                        otherstarts.append(newElement)
                    else:
                        tempStack.push(newElement)
                    otherstarts = checkTopStart(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun,otherstarts)

                elif newType is Gateway:
                    continue

                elif newType is Task and newElement.position.name not in parsing_nodes:
                    COSrerun = 1
                    otherstarts = checkTopStart(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun, otherstarts)

                    if tempStack.stacklen() == 0:
                        otherstarts.append(newElement)
                    else:
                        #do not add element only its parents
                        while not tempStack.is_empty():
                            eleToAppend = tempStack.pop()
                            otherstarts.append(eleToAppend)


                elif newType is Node and newElement.position not in parsing_nodes:
                    otherstarts = checkTopStart(newElement.position, ind, sg, sublist, sg2, sublist2, s, COSrerun, otherstarts)
                    otherstarts.append(newElement)

    return otherstarts

def checkOtherStarts(target, ind, sg, sublist, sg2, sublist2, s, COSrerun):
    for ae in alledges:
        if (ae.target == target and ae.source not in starts):
            newElement = getFullElement(ae.source)
            newType = type(newElement)

            if newElement != '' or newElement is not None:
                if newType is DataObj and newElement.position.name not in parsing_nodes:
                    if (COSrerun == 0):
                        s.push(newElement)
                    else:
                        tempStack.push(newElement)
                    parsing_nodes.append(newElement.position.name)
                    ind = checkOtherStarts(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun)

                elif newType is Gateway:
                    continue

                elif newType is Task and newElement.position.name not in parsing_nodes:
                    COSrerun = 1
                    ind = checkOtherStarts(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun)

                    # parsing.append(newElement)
                    s.push(newElement)
                    while not tempStack.is_empty():
                        eleToAppend = tempStack.pop()
                        # parsing.append(eleToAppend)
                        s.push(eleToAppend)
                      #  assign(sg, sg2, sublist, sublist2, None, None, 'chnext')


                    parsing_nodes.append(newElement.position.name)

                elif newType is Node and newElement.position not in parsing_nodes:
                    ind = checkOtherStarts(newElement.position, ind, sg, sublist, sg2, sublist2, s, COSrerun)
                    # parsing.append(newElement)
                    s.push(newElement)
                    while not s.is_empty():
                        parsing.append(s.pop())
                        assign(sg, sg2, sublist, sublist2, None, None, 'chnext')

               #     assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    parsing_nodes.append(newElement.position)

    return ind


def getFullElement(input):
    answer = ''
    for d in alldos:
        if input == d.position.name:
            answer = d
            break

    if answer == '':
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

def printAlternatePaths(par_path):
    perm = False
    all_paths = []
    alt = []
    for item in par_path:
        if perm is False:
            #fork
            if 'Gateway' in item:
                perm = True
                alt.append(item)
        elif perm is True:
            #if 'Gateway' not in item:
            alt.append(item)
            #join
            if 'Gateway' in item:
                perm = False


    pathsToShuffle = []
    c = []
    for item in alt:
        if 'Gateway' not in item:
            eachItem = item.split('-')
            pathsToShuffle = itertools.permutations(eachItem)

            num = 0
            for pts in pathsToShuffle:
                #becuse first one is already added
                if num == 0:
                    num+=1
                    continue
                else:
                    print(pts)
        else:
            print(item)


    # par_path2 = itertools.permutations(curr_step)
        # for every_option in par_path2:
        #     print(every_option)

def printParsed(toPrint, dtype):
    for x in toPrint:
        if type(x) is str:
            if dtype == 'sub':
                print('\t', end="")
            print(x)
        elif type(x) is Event:
            if x.type == 'EVENT_CHARACTERISTIC_START' and dtype == 'main':
                print('')
            if dtype == 'sub':
                print('\t', end="")
            print('Event: ', x.type)
        elif type(x) is Gateway:
            if dtype == 'sub':
                print('\t', end="")
            print('Gateway: ', x.name)
        elif type(x) is Node:
            if dtype == 'sub':
                print('\t', end="")
            print('Subgraph: ', x.name)
        elif type(x) is Task or type(x) is DataObj or type(x) is Annotation:
            if dtype == 'sub':
                print('\t', end="")
            print(type(x).__name__, ': ', x.name)
        elif type(x) is list:
            if dtype == 'sub':
                print('\t', end="")
            printParsed(x, 'sub')
            # else:
            # print(type(x),': ',x)

    #printAlternatePaths(par_path)



#getStart()
#printParsed(parsing, 'main')