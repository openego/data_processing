import xml.etree.ElementTree as ET
import psycopg2
import copy
import itertools


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
initial_rep = 0
permCount2 = 0
repetition = 1
run_counter = 1
gw_child_seq = []
endGateways = []
activeStates = []
restartWith = []
incomplete_gw = ()
following_gw_child_seq = []

allStartEv = []
alltasks = []
alledges = []
alldos = []
allanns = []
allGateways = []
allObj = []
allpnodes = []
allPool = []


gwFamily = []
parallel_opt = []
gw_chknext = None

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
    getStart()
    printParsed(parsing, 'main')
    for rep in range(0, repetition - 1):
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
    try:
        cur.execute(sql);
    except psycopg2.Error as e:
        print(str(e))
        pass
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
                                connectToPostgres(allAnnots.name)

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
                                assign(sg, sg2, sublist, sublist2, newSub, ase, 'start')
                                connectToPostgres(allAnnots.name)

                            parsing_nodes.append(t.position.name)

                            sub = checkNext(ae.target, currInd, sg, sublist, sg2, sublist2, s)

                            if sub is not None:
                                newSub = sub

                    if sg == True:
                        parsing.insert(sgIndex, sublist)

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


def checkNextParallel3(curr_ele, pos):
    global gwFamily
    global  gw_chknext
    children_list = []
    parent_list = []
    flag = False
    contflag = True

    endOfgw = curr_ele
    curr_type = type(curr_ele)


    if curr_type is Gateway:
        if len(curr_ele.parents) == 0:
            Gateway.getParents(curr_ele, alledges)
        if len(curr_ele.children) == 0:
            Gateway.getChildren(curr_ele, alledges)

        #end join
        if len(curr_ele.children) == 1:
            grandchild = getFullElement(curr_ele.children[0])
            grandchild_type = type(grandchild)
            if grandchild_type is not Gateway:
                endOfgw = curr_ele
                return endOfgw
            else:
                checkNextParallel3(grandchild, None)
    else:
        if curr_type is Task:
            if len(curr_ele.parents) == 0:
                Node.getParents(curr_ele, alledges)
            if len(curr_ele.children) == 0:
                Node.getChildren(curr_ele, alledges)

    for child in curr_ele.children:

            full_child = getFullElement(child)
            ch_type = type(full_child)

            if ch_type is Gateway:
                if len(full_child.parents) == 0:
                    Gateway.getParents(full_child, alledges)
                if len(full_child.children) == 0:
                    Gateway.getChildren(full_child, alledges)


            if ch_type is Task:
                if len(full_child.parents) == 0:
                    Node.getParents(full_child, alledges)

                for par in full_child.parents:
                    if par != curr_ele.position.name and type(getFullElement(par)) is DataObj:
                                full_child.parents.remove(par)
                                curr_ele.children[curr_ele.children.index(child)] = par
                                oldchild = copy.copy(child)
                                child = par

                                entry = ({par}, {full_child.position.name})
                                if entry not in gwFamily:
                                    gwFamily.append(entry)
                                checkNextParallel3(getFullElement(oldchild), 0)
            children_list.append(child)

            for par in full_child.parents:
                if type(getFullElement(par)) is not DataObj and par not in parent_list:
                        if len(parent_list) > 0 and type(full_child) is not Gateway:
                            entry = ({par}, {full_child.position.name})
                            if entry not in gwFamily:
                                gwFamily.append(entry)

                                fp = getFullElement(par)
                                Node.getParents(fp, alledges)
                                if len(fp.parents) > 0:
                                    for p1 in fp.parents:
                                        entry = ({p1}, {par})
                                        if entry not in gwFamily:
                                            gwFamily.append(entry)

                        else:
                            parent_list.append(par)


    #check if gatewybefore adding
    pctr = 0
    for p in parent_list:
        if pos is not 'first':
            fullp = getFullElement(p)
            if type(fullp) is Gateway:
                if len(full_child.parents) == 0:
                    Gateway.getParents(fullp, alledges)
                for p2 in fullp.parents:
                    if p2 not in parent_list:
                        parent_list.insert(pctr, p2)
                parent_list.remove(p)
            pctr+=1

        # check if gatewybefore adding
        cctr = 0
        for c in children_list:
            fullc = getFullElement(c)

            if c!= endOfgw.position.name and type(fullc) is Gateway:
                if len(fullc.children) == 0:
                    Gateway.getChildren(fullc, alledges)
                    Gateway.getChildren(fullc, alledges)

                for p in fullc.parents:
                    if type(getFullElement(p)) is Gateway:
                        flag = True
                if flag is True:
                    flag = False
                    break

                if  len(fullc.children) == 1:
                        grandchild = getFullElement(fullc.children[0])
                        grandchild_type = type(grandchild)
                        if grandchild_type is  Gateway:

                            #get other parents
                            if len(grandchild.parents) == 0:
                                Gateway.getParents(grandchild, alledges)
                            for chk_par in grandchild.parents:
                                if chk_par not in parent_list and chk_par!= c:
                                    parent_list.append(chk_par)

                for c2 in fullc.children:
                    fullc2 = getFullElement(c2)
                    if type(fullc2) is Gateway:
                        if len(fullc2.children) == 0:
                            Gateway.getChildren(fullc2, alledges)
                        if len(fullc2.children) == 1:
                            if type(getFullElement(fullc2.children[0])) is not Gateway:
                                endOfgw = fullc2
                                gw_chknext = c2
                                if c2 not in children_list:
                                    children_list.insert(cctr, c2)
                                break
                            else:
                                checkNextParallel3(fullc2, None)
                    if c2 not in children_list:
                        children_list.insert(cctr, c2)
                children_list.remove(c)
                cctr += 1

    if len(children_list)==0 and curr_type is not DataObj:
        #dead end
        children_list.append(curr_ele.children[0])
        gw_chknext = curr_ele.children[0]
        contflag = False

    children_toadd = set(children_list)
    parent_toadd = set(parent_list)
    entry = (parent_toadd, children_toadd)
    if len(parent_toadd)> 0 and entry not in gwFamily:
        gwFamily.append(entry)

    if len(parent_toadd) > 0 and contflag is True:
      for child in curr_ele.children:
        checkNextParallel3(getFullElement(child), None)

    return endOfgw


def printActiveStates(activeStates, sg, sg2, sublist, sublist2, newSub, ase, callFrom, permCount, permCount2):
    line = '{'
    for state in activeStates:
        line += state.name + " - "
        parsing_nodes.append(state.position.name)
    line += '}'

    pe_count = run_counter.__str__()
    if permCount2 > 0:
        pe_count += "." + permCount2.__str__()

    line = 'Parallel execution option ' + pe_count + ': ' + line

    if parsing[-1] is not None:
        if sg2 == True:
            if type(sublist2[-1]) is not str or line not in sublist2[-1]:
                parsing.append(line)
                assign(sg, sg2, sublist, sublist2, newSub, ase, 'chnext')
        else:
            if type(parsing[-1]) is not str or line not in parsing[-1]:
                parsing.append(line)
                assign(sg, sg2, sublist, sublist2, newSub, ase, 'chnext')

                # strip brackets, space and last '-'
                # line = line[1:-3]
                # par_path.append(line)


def assign_torun(start):
    global gwFamily
    global parallel_opt

    gwFamily_withnames = []
    ip_withnames = []
    op_withnames = []

    for (inp, out) in gwFamily:
        if len(inp)==0 or len(out)== 0:
            continue
        for i in inp:
            fulli = getFullElement(i)
            if type(fulli) is Gateway:
                displayname = 'Gateway '+i
            else:
                displayname = type(fulli).__name__+': '+fulli.name
            ip_withnames.append(displayname)
        for o in out:
            fullo = getFullElement(o)
            if type(fullo) is Gateway:
                displayname = 'Gateway ' + o
            else:
                displayname = type(fullo).__name__+': '+fullo.name
            op_withnames.append(displayname)

        ip = set(ip_withnames)
        op = set(op_withnames)
        gwFamily_withnames.append((ip,op))
        ip_withnames.clear()
        op_withnames.clear()


    parallel_opt = [[{start}]]
    changed = True
    while changed:
        new_parallel_opt = []
        for t in parallel_opt:
            changed2 = False
            for (inp, out) in gwFamily_withnames:
                if inp <= t[-1]:
                    changed2 = True
                    new_parallel_opt.append(t + [t[-1].difference(inp).union(out)])
            if not changed2:
                new_parallel_opt.append(t)
        changed = not (new_parallel_opt == parallel_opt)
        parallel_opt = new_parallel_opt


    parallel_opt = sorted(list({tuple([tuple(sorted(s)) for s in t]) for t in parallel_opt}))
    return  len(parallel_opt)


def checkNext(next, currInd, sg, sublist, sg2, sublist2, s):
    global activeStates
    global repetition
    global gw_child_seq
    global run_counter
    global initial_rep
    global parallel_opt
    global gw_chknext


    sub = None
    for ae in alledges:
        if ae.source == next:
            newObj = getFullElement(ae.target)
            if type(newObj) is Gateway:
                if run_counter == 1:
                    newObj.name = 'Gateway '+ae.target
                    checkNextParallel3(newObj, 'first')
                    allruns = assign_torun(newObj.name)
                    repetition += allruns-1

                parsing.append(parallel_opt[run_counter-1])
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                checkNext(gw_chknext, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is DataObj and newObj.position.name not in parsing_nodes:
                currInd = checkOtherStarts(ae.target, currInd, sg, sublist, sg2, sublist2, s, COSrerun)

                while not s.is_empty():
                    other_start = s.pop()
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
                        connectToPostgres(allAnnots.name)
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

                allAnnots = getAnnot(newObj)
                if allAnnots is not None:
                    parsing.append(allAnnots)
                    assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                    connectToPostgres(allAnnots.name)

                parsing.insert(sgIndex, sublist2)
                checkNext(newObj.position, currInd, sg, sublist, sg2, sublist2, s)
                break

            if type(newObj) is Event and newObj.position.name not in parsing_nodes:
                parsing.append(newObj)
                assign(sg, sg2, sublist, sublist2, None, None, 'chnext')
                parsing_nodes.append(newObj.position.name)
                checkNext(newObj.position.name, currInd, sg, sublist, sg2, sublist2, s)
                break
    return sub


def checkTopStart(target, ind, sg, sublist, sg2, sublist2, s, COSrerun, otherstarts):
    for ae in alledges:
        if (ae.target == target and ae.source not in starts):
            newElement = getFullElement(ae.source)
            newType = type(newElement)

            if newElement != '' or newElement is not None:
                if newType is DataObj:
                    if (COSrerun == 0):
                        otherstarts.append(newElement)
                    else:
                        tempStack.push(newElement)
                    otherstarts = checkTopStart(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun,
                                                otherstarts)

                elif newType is Gateway:
                    continue

                elif newType is Task and newElement.position.name not in parsing_nodes:
                    COSrerun = 1
                    otherstarts = checkTopStart(newElement.position.name, ind, sg, sublist, sg2, sublist2, s, COSrerun,
                                                otherstarts)

                    if tempStack.stacklen() == 0:
                        otherstarts.append(newElement)
                    else:
                        # do not add element only its parents
                        while not tempStack.is_empty():
                            eleToAppend = tempStack.pop()
                            otherstarts.append(eleToAppend)


                elif newType is Node and newElement.position not in parsing_nodes:
                    otherstarts = checkTopStart(newElement.position, ind, sg, sublist, sg2, sublist2, s, COSrerun,
                                                otherstarts)
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


    if answer == '':
        for g in allanns:
            if type(g) is Annotation and input == g.position.name:
                answer = g
                break

    return answer


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
        elif type(x) is tuple:
            for x2 in x:
                if dtype == 'sub':
                    print('\t', end="")
                print('Parallel execution option '+run_counter.__str__() +': ' + x2.__str__())
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