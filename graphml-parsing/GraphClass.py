class Graph:
   'Common base class for all nodes'
   graphCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      Graph.graphCount += 1
      Graph.displayName(self)

   def displayName(self):
      print("Graph ",self.graphCount,". Label= ", self.name)

