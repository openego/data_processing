class Lane:
   'Common base class for all lanes'
   laneCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      Lane.laneCount += 1


   def displayName(self):
      print(self.position," Lane Label : ", self.name)

