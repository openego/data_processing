from NodeClass import Node

class DataObj(Node):
   'Common base class for all Data Objectss'
   dataObjCount = 0

   def __init__(self, name, position):
      super().__init__(name, position)
      DataObj.dataObjCount += 1
      #DataObj.displayName(self)

   def displayName(self):
      print("Data Object Label : ", self.name)

