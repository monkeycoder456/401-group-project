class Script:
    def __init__(self,owner):
        self.owner=owner
    def update(self,dt):
        pass

class ScriptEngine:
    def __init__(self):
        self.scripts=[]
    def add(self,s):
        self.scripts.append(s)
    def update(self,dt):
        for s in self.scripts:
            s.update(dt)
