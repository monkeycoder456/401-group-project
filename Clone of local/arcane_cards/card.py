import random
from effects import StatusEffect

class Card:
    def __init__(self, name, card_type, power, cost, effect=None):
        self.name = name
        self.card_type = card_type
        self.power = power
        self.cost = cost
        self.effect = effect

    def __str__(self):
        return f"{self.name} [{self.card_type}] Power:{self.power} Cost:{self.cost}"

def generate_random_card():
    roll = random.randint(1, 5)

    if roll == 1:
        return Card("Fireball", "attack", 6, 3, StatusEffect("burn", 2, 2))
    elif roll == 2:
        return Card("Poison Strike", "attack", 4, 2, StatusEffect("poison", 3, 1))
    elif roll == 3:
        return Card("Heal", "heal", 5, 2)
    elif roll == 4:
        return Card("Shield Up", "buff", 0, 2, StatusEffect("shield", 2, 3))
    else:
        return Card("Heavy Slash", "attack", 8, 4)
