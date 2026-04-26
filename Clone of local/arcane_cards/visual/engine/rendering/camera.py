class Camera:
    def __init__(self):
        self.x=0; self.y=0
    def apply(self,r):
        return r.move(-self.x,-self.y)
