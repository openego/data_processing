from gmlparsing.NodeClass import Node

class Event(Node):
   'Common base class for all Events'
   eventCount = 0

   def __init__(self, name, type):
      self.name = name
      self.type = type
      #super().__init__(name)
      Event.eventCount += 1
      #Event.displayName(self)

   def displayName(self):
      print("Event Label : ", self.name," of type ",self.type)

