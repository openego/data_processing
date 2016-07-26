from gmlparsing.NodeClass import Node

class Annotation(Node):
   'Common base class for all Annotations'
   dataObjCount = 0

   def __init__(self, name, position):
      super().__init__(name, position)
      self.name = self.name.replace('\n', ' ').replace('\r', '')
      Annotation.dataObjCount += 1
      #Annots.displayName(self)

   def displayName(self):
      print("Annotation Label : ", self.name,'@',self.position.name)

