from constants import STARTING_HEALTH, MAX_MANA

class Player:
    def __init__(self, name):
        self.name = name
        self.health = STARTING_HEALTH
        self.mana = 0
        self.hand = []
        self.deck = None
        self.buff = 0
        self.shield = 0
        self.status_effects = []

    def draw_cards(self, amount=1):
        for _ in range(amount):
            card = self.deck.draw()
            if card:
                self.hand.append(card)

    def process_effects(self):
        for effect in self.status_effects[:]:
            effect.apply(self)
            if effect.duration <= 0:
                self.status_effects.remove(effect)

    def take_damage(self, dmg):
        self.health -= dmg

    def heal(self, amount):
        self.health += amount

    def apply_buff(self, amount):
        self.buff += amount

    def reset_turn(self):
        self.mana = min(self.mana + 1, MAX_MANA)
        self.process_effects()
