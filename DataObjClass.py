class DataObj:
   'Common base class for all Data Objectss'
   dataObjCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      DataObj.dataObjCount += 1


   def displayName(self):
      print(self.position," Data Object Label : ", self.name)

