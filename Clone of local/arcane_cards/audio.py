import pygame
pygame.mixer.init()
class Audio:
    def __init__(self):
        self.sounds={}
    def load_sound(self,name,path):
        try:self.sounds[name]=pygame.mixer.Sound(path)
        except:self.sounds[name]=None
    def play(self,name):
        if self.sounds.get(name):self.sounds[name].play()
