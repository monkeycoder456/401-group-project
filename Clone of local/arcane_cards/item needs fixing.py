import random
import math
from collections import defaultdict

class EventBus:
    def __init__(self):
        self.listeners = defaultdict(list)
    def subscribe(self, event, fn):
        self.listeners[event].append(fn)
    def emit(self, event, data=None):
        for fn in self.listeners[event]:
            fn(data)

class Effect:
    def __init__(self, name, value, duration=1):
        self.name = name
        self.value = value
        self.duration = duration
    def apply(self, target):
        if self.name == "damage":
            target.hp -= self.value
        elif self.name == "heal":
            target.hp += self.value
        elif self.name == "burn":
            target.hp -= self.value
        elif self.name == "poison":
            target.hp -= self.value
        elif self.name == "shield":
            target.shield += self.value
        elif self.name == "buff":
            target.power += self.value
        elif self.name == "debuff":
            target.power -= self.value
        self.duration -= 1
    def active(self):
        return self.duration > 0

class EffectManager:
    def __init__(self):
        self.effects = []
    def add(self, effect, target):
        self.effects.append((effect, target))
    def update(self):
        for e, t in self.effects[:]:
            e.apply(t)
            if not e.active():
                self.effects.remove((e, t))

class Item:
    def __init__(self, name, effects):
        self.name = name
        self.effects = effects
    def use(self, user, target, manager, event_bus):
        for e in self.effects:
            manager.add(e, target)
        event_bus.emit("item_used", {"user": user.name, "item": self.name})

class ItemFactory:
    def create(self):
        pool = [
            lambda: Item("Fire Orb", [Effect("damage", 8), Effect("burn", 2, 3)]),
            lambda: Item("Heal Stone", [Effect("heal", 10)]),
            lambda: Item("Poison Dagger", [Effect("poison", 3, 4)]),
            lambda: Item("Shield Charm", [Effect("shield", 5, 2)]),
            lambda: Item("Rage Potion", [Effect("buff", 3, 3)]),
            lambda: Item("Curse Totem", [Effect("debuff", 2, 3)])
        ]
        return random.choice(pool)()

class Entity:
    def __init__(self, name):
        self.name = name
        self.hp = random.randint(80, 120)
        self.power = random.randint(5, 15)
        self.shield = 0
        self.inventory = []
    def attack(self, target):
        raw = random.randint(1, self.power)
        dmg = max(0, raw - target.shield)
        target.hp -= dmg
        target.shield = max(0, target.shield - raw)
        return dmg
    def add_item(self, item):
        self.inventory.append(item)
    def use_item(self, target, manager, bus):
        if self.inventory:
            item = self.inventory.pop(0)
            item.use(self, target, manager, bus)

class AI:
    def decide(self, entity, enemies, manager, bus):
        if entity.inventory and random.random() < 0.5:
            target = random.choice(enemies)
            entity.use_item(target, manager, bus)
            return f"{entity.name} used item"
        else:
            target = random.choice(enemies)
            dmg = entity.attack(target)
            return f"{entity.name} attacked {target.name} ({dmg})"

class Logger:
    def __init__(self):
        self.logs = []
    def log(self, text):
        self.logs.append(text)
    def dump(self):
        for l in self.logs:
            print(l)

class TurnEngine:
    def __init__(self, entities):
        self.entities = entities
        self.turn = 0
    def next(self):
        self.turn += 1
        return self.turn

class Battle:
    def __init__(self, count=6):
        self.entities = [Entity(f"E{i}") for i in range(count)]
        self.effects = EffectManager()
        self.ai = AI()
        self.factory = ItemFactory()
        self.logger = Logger()
        self.turns = TurnEngine(self.entities)
        self.events = EventBus()
        self.events.subscribe("item_used", lambda d: self.logger.log(f"{d['user']} used {d['item']}"))
        for e in self.entities:
            for _ in range(random.randint(1,3)):
                e.add_item(self.factory.create())
    def alive(self):
        return [e for e in self.entities if e.hp > 0]
    def step(self):
        alive = self.alive()
        for e in alive:
            enemies = [x for x in alive if x != e]
            if not enemies:
                continue
            action = self.ai.decide(e, enemies, self.effects, self.events)
            self.logger.log(action)
        self.effects.update()
        self.turns.next()
    def run(self):
        while len(self.alive()) > 1:
            self.step()
        winner = self.alive()[0]
        self.logger.log(f"Winner: {winner.name}")
        return winner

class Economy:
    def __init__(self):
        self.gold = defaultdict(int)
    def reward(self, entity):
        amount = random.randint(10, 25)
        self.gold[entity.name] += amount

class Progression:
    def level_up(self, entity):
        entity.hp += 15
        entity.power += 3

class Simulation:
    def __init__(self):
        self.battle = Battle()
        self.economy = Economy()
        self.progress = Progression()
    def run(self):
        winner = self.battle.run()
        self.economy.reward(winner)
        self.progress.level_up(winner)
        return winner

class DifficultyScaler:
    def scale(self, turn):
        return 1 + math.log(turn + 1)

class ComboTracker:
    def __init__(self):
        self.combo = 0
    def register(self, action):
        if "attacked" in action:
            self.combo += 1
        else:
            self.combo = 0

class StatsTracker:
    def __init__(self):
        self.stats = defaultdict(int)
    def record(self, key):
        self.stats[key] += 1

if __name__ == "__main__":
    sim = Simulation()
    for i in range(3):
        winner = sim.run()
        print(f"Run {i}: Winner = {winner.name}")
