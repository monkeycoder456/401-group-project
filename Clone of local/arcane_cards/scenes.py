class SceneManager:
    def __init__(self):self.scene="menu"
    def set(self,s):self.scene=s
    def is_scene(self,s):return self.scene==s
