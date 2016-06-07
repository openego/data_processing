class Event:
   'Common base class for all Events'
   eventCount = 0

   def __init__(self, name, type):
      self.name = name
      self.type = type
      Event.eventCount += 1
      #Event.displayName(self)

   def displayName(self):
      print("Event Label : ", self.name," of type ",self.type)

