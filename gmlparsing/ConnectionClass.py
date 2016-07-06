from EdgeClass import Edge

class Connection(Edge):
   'Common base class for all Connection type'
   connectionTypeCount = 0

   def __init__(self, name, type):
      self.name = name
      self.type = type
      #super().__init__(name, position)
      Connection.connectionTypeCount += 1
      #Connection.displayName(self)
      
   def displayName(self):
      print("--------------Connection Name : ", self.name," of type ",self.type)
