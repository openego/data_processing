class Task:
   'Common base class for all Tasks'
   taskCount = 0

   def __init__(self, name, position):
      self.name = name
      self.position = position
      Task.taskCount += 1
      #Task.displayName(self)

   def displayName(self):
      print(" Task Label : ", self.name)

