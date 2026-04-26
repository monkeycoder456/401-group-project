class GameObject:
    def __init__(self):
        self.components=[]
    def add(self,c):
        self.components.append(c)
    def update(self,dt):
        for c in self.components:
            c.update(dt)
