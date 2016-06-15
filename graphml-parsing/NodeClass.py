from GraphClass import Graph

class Node(Graph):
   'Common base class for all nodes'
   nodeCount = 0

   def __init__(self, name, position):
      #self.name = name
      #self.position = position
      super().__init__(name, position)
      Node.nodeCount += 1
      #Node.displayName(self)

   def displayName(self):
      print("Node ",self.nodeCount,". Label= ", self.name)


