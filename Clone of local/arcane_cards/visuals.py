import pygame
def text(screen,t,font,x,y):
    screen.blit(font.render(t,1,(0,0,0)),(x,y))
def bar(screen,x,y,v,m):
    pygame.draw.rect(screen,(180,180,180),(x,y,200,20))
    pygame.draw.rect(screen,(200,50,50),(x,y,int(200*(v/m)),20))
