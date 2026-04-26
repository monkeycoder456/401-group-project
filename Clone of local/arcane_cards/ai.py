class SmartAI:
    def choose_card(self, player, opponent):
        playable = [c for c in player.hand if c.cost <= player.mana]

        if not playable:
            return None

        for card in playable:
            if card.card_type == "attack" and card.power >= opponent.health:
                return card

        if player.health < 10:
            heals = [c for c in playable if c.card_type == "heal"]
            if heals:
                return max(heals, key=lambda c: c.power)

        attacks = [c for c in playable if c.card_type == "attack"]
        if attacks:
            return max(attacks, key=lambda c: c.power)

        return playable[0]
