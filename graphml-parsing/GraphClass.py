import pprint
class Graph:
   'Common base class for all nodes'
   graphCount = 0

   def __init__(self, name, nodes, edges):
      self.name = name
      self.nodes = nodes
      self.edges = edges
      Graph.graphCount += 1
      Graph.displayName(self)

   def displayName(self):
      print("\nGraph ",self.graphCount,". Label= ", self.name," has nodes ")
      for x in self.nodes:
         print(x.name, end=', ')


