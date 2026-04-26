import pygame
import sys
import random

pygame.init()

WIDTH, HEIGHT = 900, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Arcane Cards Arena")

font = pygame.font.SysFont("arial", 20)

# COLORS
WHITE = (255,255,255)
BLACK = (0,0,0)
RED = (200,50,50)
GREEN = (50,200,50)
BLUE = (50,50,200)

# PLAYER
player_hp = 30
enemy_hp = 30

# CARD CLASS
class Card:
    def __init__(self, name, power, cost, color):
        self.name = name
        self.power = power
        self.cost = cost
        self.color = color
        self.rect = pygame.Rect(0,0,100,150)

    def draw(self, x, y):
        self.rect.topleft = (x,y)
        pygame.draw.rect(screen, self.color, self.rect)
        pygame.draw.rect(screen, BLACK, self.rect, 2)

        text = font.render(self.name, True, BLACK)
        screen.blit(text, (x+5, y+5))

        power = font.render(f"P:{self.power}", True, BLACK)
        screen.blit(power, (x+5, y+40))

# GENERATE CARDS
def generate_card():
    types = [
        ("Fireball", 6, RED),
        ("Strike", 4, BLUE),
        ("Heal", -5, GREEN)
    ]
    name, power, color = random.choice(types)
    return Card(name, power, 1, color)

player_hand = [generate_card() for _ in range(5)]

turn = "player"

def draw_ui():
    screen.fill(WHITE)

    # HP
    p_text = font.render(f"Player HP: {player_hp}", True, BLACK)
    e_text = font.render(f"Enemy HP: {enemy_hp}", True, BLACK)

    screen.blit(p_text, (20, 500))
    screen.blit(e_text, (20, 20))

    # Cards
    for i, card in enumerate(player_hand):
        card.draw(100 + i*120, 350)

def enemy_turn():
    global player_hp
    dmg = random.randint(3,7)
    player_hp -= dmg

running = True
clock = pygame.time.Clock()

while running:
    draw_ui()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

if event.type == pygame.MOUSEBUTTONDOWN and turn == "player":
    global enemy_hp, player_hp   

    mouse_pos = pygame.mouse.get_pos()

    for card in player_hand:
        if card.rect.collidepoint(mouse_pos):

            if card.power >= 0:
                enemy_hp -= card.power
            else:
                player_hp -= card.power  4

            player_hand.remove(card)
            player_hand.append(generate_card())

            turn = "enemy"

    if turn == "enemy":
        pygame.time.delay(500)
        enemy_turn()
        turn = "player"

    # GAME OVER
    if player_hp <= 0 or enemy_hp <= 0:
        screen.fill(WHITE)
        result = "YOU WIN!" if enemy_hp <= 0 else "YOU LOSE!"
        text = font.render(result, True, BLACK)
        screen.blit(text, (400,300))
        pygame.display.flip()
        pygame.time.delay(2000)
        running = False

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()
