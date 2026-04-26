import random
from card import generate_random_card

class Deck:
    def __init__(self):
        self.cards = [generate_random_card() for _ in range(30)]

    def shuffle(self):
        random.shuffle(self.cards)

    def draw(self):
        if self.cards:
            return self.cards.pop()
        return None
