class Event:
   'Common base class for all Events'
   eventCount = 0

   def __init__(self, name, type):
      self.name = name
      self.type = type
      Event.eventCount += 1


   def displayName(self):
      print(self.position," Event Label : ", self.name)

