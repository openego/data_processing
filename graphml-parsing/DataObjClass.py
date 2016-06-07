class DataObj:
   'Common base class for all Data Objectss'
   dataObjCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      DataObj.dataObjCount += 1
      #DataObj.displayName(self)

   def displayName(self):
      print("Data Object Label : ", self.name)

