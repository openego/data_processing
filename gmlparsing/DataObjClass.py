from gmlparsing.NodeClass import Node

class DataObj(Node):
   'Common base class for all Data Objects'
   dataObjCount = 0

   def __init__(self, name, position,ns):
      super().__init__(name, position,ns)
      self.name = self.name.replace('\n', ' ').replace('\r', '')
      DataObj.dataObjCount += 1
      #DataObj.displayName(self)

   def displayName(self):
      print("Data Object Label : ", self.name,' at ',self.position.name)

