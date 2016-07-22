from gmlparsing.NodeClass import Node

class Gateway(Node):
   'Common base class for all Gateways'
   gatewayCount = 0

   def __init__(self, name, type,pos):
      self.name = name
      self.type = type
      self.position = pos
      #super().__init__(name)
      Gateway.gatewayCount += 1
      #Gateway.displayName(self)
      
   def displayName(self):
      print("Gateway type ",self.type," under node ",self.position.name)
