class StatusEffect:
    def __init__(self, name, duration, value):
        self.name = name
        self.duration = duration
        self.value = value

    def apply(self, target):
        if self.name == "poison":
            target.take_damage(self.value)
            print(f"{target.name} takes {self.value} poison damage!")
        elif self.name == "burn":
            target.take_damage(self.value)
            print(f"{target.name} burns for {self.value} damage!")
        elif self.name == "shield":
            target.shield += self.value
            print(f"{target.name} gains {self.value} shield!")
        self.duration -= 1

def apply_card(card, attacker, defender):
    if card.card_type == "attack":
        damage = card.power + attacker.buff
        if defender.shield > 0:
            absorbed = min(defender.shield, damage)
            defender.shield -= absorbed
            damage -= absorbed
        defender.take_damage(damage)
        print(f"{attacker.name} deals {damage} damage!")
        if card.effect:
            defender.status_effects.append(card.effect)

    elif card.card_type == "heal":
        attacker.heal(card.power)
        print(f"{attacker.name} heals {card.power}!")

    elif card.card_type == "buff":
        attacker.apply_buff(card.power)
        print(f"{attacker.name} gains buff!")
