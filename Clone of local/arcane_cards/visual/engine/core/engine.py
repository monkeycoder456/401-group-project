import pygame
from .scene import Scene

class Engine:
    def __init__(self,w,h):
        pygame.init()
        self.screen=pygame.display.set_mode((w,h))
        self.clock=pygame.time.Clock()
        self.scene=Scene()
        self.running=True

    def run(self):
        while self.running:
            dt=self.clock.tick(60)/1000
            for e in pygame.event.get():
                if e.type==pygame.QUIT:
                    self.running=False
            self.screen.fill((255,255,255))
            self.scene.update(dt)
            pygame.display.flip()
        pygame.quit()
