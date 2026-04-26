import pygame
class Renderer:
    def __init__(self,screen):
        self.screen=screen
    def rect(self,color,r):
        pygame.draw.rect(self.screen,color,r)
