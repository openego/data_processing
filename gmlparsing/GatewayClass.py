from NodeClass import Node

class Gateway(Node):
   'Common base class for all Gateways'
   gatewayCount = 0

   def __init__(self, name, type):
      self.name = name
      self.type = type
      #super().__init__(name)
      Gateway.gatewayCount += 1
      #Gateway.displayName(self)
      
   def displayName(self):
      print("Gateway Name : ", self.name," of type ",self.type)
