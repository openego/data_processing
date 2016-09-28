from gmlparsing.GraphClass import Graph

class Node(Graph):
   'Common base class for all nodes'
   nodeCount = 0

   def __init__(self, name, position,ns):
      self.name = name.replace('\n', ' ').replace('\r', '')
      self.position = position
      #super().__init__(name, position)
      Node.nodeCount += 1
      #Node.displayName(self)

   def displayName(self):
      print("Node ",self.nodeCount,". Label= ", self.name,' at ',self.position)


