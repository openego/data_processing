class Lane:
   'Common base class for all lanes'
   laneCount = 0

   def __init__(self, name, parentpool,position):
      self.name = name
      self.parentname = parentpool
      self.position = position
      Lane.laneCount += 1
      #Lane.displayName(self)

   def displayName(self):
      print("Lane Label : ", self.name," under ",self.parentname)

