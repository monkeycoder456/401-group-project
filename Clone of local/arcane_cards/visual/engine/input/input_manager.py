import pygame
class InputManager:
    def __init__(self):
        self.mouse=(0,0)
        self.click=False
    def update(self):
        self.mouse=pygame.mouse.get_pos()
        self.click=pygame.mouse.get_pressed()[0]
