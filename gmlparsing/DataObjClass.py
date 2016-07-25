from gmlparsing.NodeClass import Node

class DataObj(Node):
   'Common base class for all Data Objects'
   dataObjCount = 0

   def __init__(self, name, position):
      super().__init__(name, position)
      self.name = self.name.replace('\n', ' ').replace('\r', '')
      DataObj.dataObjCount += 1
      #DataObj.displayName(self)

   def displayName(self):
      print("Data Object Label : ", self.name,' at ',self.position.name)

