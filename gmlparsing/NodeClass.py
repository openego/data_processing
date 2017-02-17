from gmlparsing.GraphClass import Graph

class Node(Graph):
   'Common base class for all nodes'
   nodeCount = 0


   def __init__(self, name, position,ns):
      self.name = name.replace('\n', ' ').replace('\r', '')
      self.position = position
      self.parents = []
      self.children = []

      Node.nodeCount += 1
      #Node.displayName(self)

   def displayName(self):
      print("Node ",self.nodeCount,". Label= ", self.name,' at ',self.position)

   def getParents(self, alledges):
      for ae in alledges:
         if ae.target == self.position.name and self.position.name not in self.parents:
            self.parents.append(ae.source)
            # Gateway.displayName(self)

   def getChildren(self, alledges):
      for ae in alledges:
         if ae.source == self.position.name and self.position.name not in self.children:
            self.children.append(ae.target)
            # Gateway.displayName(self)


