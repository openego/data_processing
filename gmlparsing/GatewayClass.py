from gmlparsing.NodeClass import Node

class Gateway(Node):
    'Common base class for all Gateways'
    gatewayCount = 0

    def __init__(self, name, type,pos,ns):
      self.name = name
      self.type = type
      self.position = pos
      self.parents = []
      self.children = []

      Gateway.gatewayCount += 1

    def getParents(self, alledges):
        for ae in alledges:
            if ae.target == self.position.name and self.position.name not in self.parents:
                self.parents.append(ae.source)
        #Gateway.displayName(self)

    def getChildren(self, alledges):
        for ae in alledges:
            if ae.source == self.position.name and self.position.name not in self.children:
                self.children.append(ae.target)
        #Gateway.displayName(self)

    def displayName(self):
          print("Gateway type ",self.type," under node ",self.position.name)
          print('Parent/s: ',self.parents)
          print('Child/ren: ', self.children)