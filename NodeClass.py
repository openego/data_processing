class Node:
   'Common base class for all nodes'
   nodeCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      Node.nodeCount += 1


   def displayName(self):
      print(self.position," Node Label : ", self.name)

