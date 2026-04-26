from player import Player
from deck import Deck
from ai import SmartAI
from effects import apply_card
from state_manager import GameStateManager
from logger import GameLogger

class Game:
    def __init__(self):
        self.state = GameStateManager()
        self.logger = GameLogger()

        self.player = Player("You")
        self.enemy = Player("AI")

        self.player.deck = Deck()
        self.enemy.deck = Deck()

        self.player.deck.shuffle()
        self.enemy.deck.shuffle()

        self.ai = SmartAI()
        self.turn = 1

        self.setup()

    def setup(self):
        self.player.draw_cards(5)
        self.enemy.draw_cards(5)

    def player_turn(self):
        self.player.reset_turn()
        self.player.draw_cards(1)

        print("\nYour Turn")
        self.show_hand()

        choice = input("Choose card index or 'skip': ")

        if choice.isdigit():
            idx = int(choice)
            if 0 <= idx < len(self.player.hand):
                card = self.player.hand[idx]
                if card.cost <= self.player.mana:
                    self.player.mana -= card.cost
                    apply_card(card, self.player, self.enemy)
                    self.logger.log(f"You played {card.name}")
                    self.player.hand.pop(idx)

    def enemy_turn(self):
        self.enemy.reset_turn()
        self.enemy.draw_cards(1)

        print("\nEnemy Turn")

        card = self.ai.choose_card(self.enemy, self.player)

        if card:
            self.enemy.mana -= card.cost
            apply_card(card, self.enemy, self.player)
            self.logger.log(f"Enemy played {card.name}")
            self.enemy.hand.remove(card)

    def show_hand(self):
        for i, card in enumerate(self.player.hand):
            print(f"{i}: {card}")

    def is_game_over(self):
        return self.player.health <= 0 or self.enemy.health <= 0

    def show_winner(self):
        print("\n🏆 Game Over!")
        if self.player.health > 0:
            print("YOU WIN")
        else:
            print("YOU LOSE")

    def run(self):
        self.state.change_state("playing")

        while not self.is_game_over():
            print(f"\n--- Turn {self.turn} ---")
            print(f"Your HP: {self.player.health} | Enemy HP: {self.enemy.health}")

            self.player_turn()
            if self.is_game_over():
                break

            self.enemy_turn()
            self.turn += 1

        self.show_winner()
        self.logger.show_history()
