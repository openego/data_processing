from gmlparsing.NodeClass import Node

class Lane(Node):
   'Common base class for all lanes'
   laneCount = 0

   def __init__(self, name, parentpool,position,ns):
      #self.name = name
      self.parentname = parentpool
      #self.position = position
      super().__init__(name, position,ns)
      Lane.laneCount += 1
      #Lane.displayName(self)

   def displayName(self):
      print("Lane Label : ", self.name," under ",self.parentname)

