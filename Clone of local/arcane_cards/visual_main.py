import pygame,sys
from cards import load_imgs,random_card
from audio import Audio
from scenes import SceneManager
from visuals import text,bar

pygame.init()
screen=pygame.display.set_mode((1100,700))
font=pygame.font.SysFont("arial",20)
big=pygame.font.SysFont("arial",40)

audio=Audio()
scene=SceneManager()
imgs=load_imgs()

player_hp=30
enemy_hp=30
hand=[random_card(imgs) for _ in range(5)]
turn="player"

clock=pygame.time.Clock()

while True:
    screen.fill((255,255,255))

    if scene.is_scene("menu"):
        text(screen,"Arcane Cards Arena",big,350,200)
        text(screen,"Click to Start",font,450,300)

    elif scene.is_scene("game"):
        bar(screen,20,650,player_hp,30)
        bar(screen,20,20,enemy_hp,30)
        for i,c in enumerate(hand):
            c.rect.topleft=(100+i*130,450)
            c.draw(screen,font)
        text(screen,"Your Turn" if turn=="player" else "Enemy",big,400,300)

    for e in pygame.event.get():
        if e.type==pygame.QUIT:pygame.quit();sys.exit()
        if e.type==pygame.MOUSEBUTTONDOWN:
            if scene.is_scene("menu"):
                scene.set("game")
            elif scene.is_scene("game"):
                for c in hand:
                    if c.rect.collidepoint(pygame.mouse.get_pos()):
                        if c.power>=0:enemy_hp-=c.power
                        else:player_hp-=c.power
                        hand.remove(c)
                        hand.append(random_card(imgs))
                        turn="enemy"

    if scene.is_scene("game") and turn=="enemy":
        pygame.time.delay(400)
        player_hp-=3
        turn="player"

    if player_hp<=0 or enemy_hp<=0:
        scene.set("menu")
        player_hp=30;enemy_hp=30

    pygame.display.flip()
    clock.tick(60)
