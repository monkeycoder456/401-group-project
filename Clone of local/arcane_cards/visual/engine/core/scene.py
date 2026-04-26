class Scene:
    def __init__(self):
        self.objects=[]
    def add(self,o):
        self.objects.append(o)
    def update(self,dt):
        for o in self.objects:
            o.update(dt)
