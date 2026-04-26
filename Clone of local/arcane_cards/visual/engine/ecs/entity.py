class Entity:
    def __init__(self):
        self.components={}
    def add(self,c):
        self.components[type(c)]=c
    def get(self,t):
        return self.components.get(t)
