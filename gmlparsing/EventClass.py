from gmlparsing.NodeClass import Node

class Event(Node):
   'Common base class for all Events'
   eventCount = 0

   def __init__(self, name, type, innode):
      self.name = name
      self.type = type
      self.position = innode
      #super().__init__(innode.name,1)
      Event.eventCount += 1
      #Event.displayName(self)

   def displayName(self):
      if "EVENT_CHARACTERISTIC_START" == self.type:
         print("\n");
      print("Event Label : ", self.name," of type ",self.type, " under node ",self.position.name)
      #print("Event Label : ", self.name, " of type ", self.type, " under node ", super().name)
