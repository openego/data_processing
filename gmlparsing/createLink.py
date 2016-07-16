from gmlparsing.EdgeClass import Edge

nodes = ["y","a","x","z","l"]
edges = []
alledges = [None] * len(nodes)

edges.append(Edge("l","y"))
edges.append(Edge("y","a"))
edges.append(Edge("a","z"))
edges.append(Edge("a","x"))
parsing = ([None] * len(nodes)) + ([None] * len(edges))

nIndex = -1
pIndex = -1
for n in nodes:
    nIndex = nIndex+1
    for e in edges:
        if(n in e.source):
            if(alledges[nIndex] is None):  #objects with multiple outgoing edges
                alledges[nIndex] = e
            else:
                tmpobj = alledges[nIndex]
                alledges[nIndex] = []
                alledges[nIndex].append(tmpobj)
                alledges[nIndex].append(e)


withincoming=[]
print("Parsing:")

for x in range(len(nodes)):
    if (alledges[x] is not None):              #fields with edges
        if(isinstance(alledges[x],list)):
            for y in alledges[x]:
                withincoming.append(y.target)
        else:
            withincoming.append(alledges[x].target)

noincoming = list(set(nodes) - set(withincoming)) #objects that can be the source
for n in noincoming:
    pIndex+=1
    parsing[pIndex] = n

    for src in alledges:                 #for starting the parsing
        if (isinstance(src, list)):
            for y in src:
                if n in y.source:
                    pIndex += 1
                    parsing[pIndex] = y
        else:
            if src is not None and n in src.source:
                pIndex += 1
                parsing[pIndex] = src

withincomingSorted = [None] * (len(nodes))
withincomingSorted[0] = parsing[1].target # source is determined
wsIndex = 1
ctr = 1
for x in range(1,len(withincomingSorted)-1):
    for ae in alledges:
        if ae is not None:
            if (isinstance(ae, list)):
                for y in ae:
                    if (withincomingSorted[x - ctr] in y.source):
                        withincomingSorted[x] = y.target
                        x += 1
                        ctr += 1
            else:

                if(withincomingSorted[x-1] is ae.source):
                    withincomingSorted[x ] =  ae.target
                    wsIndex += 1

pIndex=1
for w in withincomingSorted:
    if w is not None:
        pIndex+=1
        parsing[pIndex] = w

        for src in alledges:                 #for starting the parsing
            if (isinstance(src, list)):
                for y in src:
                    if w in y.source:
                        pIndex += 1
                        parsing[pIndex] = y
            else:
                if src is not None and w in src.source:
                    pIndex += 1
                    parsing[pIndex] = src

for p in parsing:            #execution print
    if type(p) is Edge:
        print(p.source,"to",p.target)
    else:
        print(p)