import random
import math
from collections import defaultdict

class Vec2:
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y
    def add(self, o):
        self.x += o.x
        self.y += o.y
    def sub(self, o):
        return Vec2(self.x - o.x, self.y - o.y)
    def length(self):
        return math.hypot(self.x, self.y)
    def normalize(self):
        l = self.length()
        if l > 0:
            self.x /= l
            self.y /= l
        return self

class Status:
    def __init__(self, name, value, duration):
        self.name = name
        self.value = value
        self.duration = duration
    def apply(self, entity):
        if self.name == "burn":
            entity.hp -= self.value
        elif self.name == "regen":
            entity.hp += self.value
        elif self.name == "slow":
            entity.speed *= (1 - self.value)
        self.duration -= 1
    def active(self):
        return self.duration > 0

class StatusManager:
    def __init__(self):
        self.effects = []
    def add(self, status):
        self.effects.append(status)
    def update(self, entity):
        for s in self.effects[:]:
            s.apply(entity)
            if not s.active():
                self.effects.remove(s)

class BaseEnemy:
    def __init__(self, name):
        self.name = name
        self.hp = 100
        self.pos = Vec2(random.randint(0,100), random.randint(0,100))
        self.cooldown = 0
        self.status = StatusManager()
        self.state = "idle"
    def alive(self):
        return self.hp > 0
    def update_base(self):
        self.status.update(self)
        if self.cooldown > 0:
            self.cooldown -= 1

class Witch(BaseEnemy):
    def __init__(self):
        super().__init__("Witch")
        self.mana = 120
    def choose(self):
        if self.mana > 80:
            return "burst"
        elif self.mana > 40:
            return "drain"
        return "recover"
    def burst(self, target):
        dmg = random.randint(10, 20)
        target.hp -= dmg
        self.mana -= 25
    def drain(self, target):
        val = random.randint(5, 10)
        target.hp -= val
        self.hp += val
        self.mana -= 15
    def recover(self):
        self.mana += 10
    def update(self, target):
        self.update_base()
        if self.cooldown > 0:
            return
        action = self.choose()
        if action == "burst":
            self.burst(target)
        elif action == "drain":
            self.drain(target)
        else:
            self.recover()
        self.cooldown = 2

class GraveyardKeeper(BaseEnemy):
    def __init__(self):
        super().__init__("GraveyardKeeper")
        self.souls = 0
        self.shield = 20
    def collect(self):
        gain = random.randint(1,3)
        self.souls += gain
        self.hp += gain
    def defend(self):
        self.shield += random.randint(2,5)
    def slam(self, target):
        dmg = self.souls * 2
        target.hp -= dmg
        self.souls = 0
    def decay(self):
        if self.shield > 0:
            self.shield -= 1
    def update(self, target):
        self.update_base()
        choice = random.randint(0,3)
        if choice == 0:
            self.collect()
        elif choice == 1:
            self.defend()
        elif choice == 2:
            self.slam(target)
        else:
            self.decay()

class Spider(BaseEnemy):
    def __init__(self):
        super().__init__("Spider")
        self.webs = {}
        self.hunger = 0
    def move(self):
        dx = random.choice([-1,0,1])
        dy = random.choice([-1,0,1])
        self.pos.x += dx * 2
        self.pos.y += dy * 2
    def spin(self):
        key = (self.pos.x, self.pos.y)
        self.webs[key] = random.randint(3,7)
    def decay_webs(self):
        new = {}
        for k,v in self.webs.items():
            if v > 1:
                new[k] = v - 1
        self.webs = new
    def trap(self, target):
        for (wx,wy),p in self.webs.items():
            if abs(target.pos.x - wx) < 4 and abs(target.pos.y - wy) < 4:
                target.hp -= p
    def bite(self, target):
        dmg = random.randint(4,9)
        target.hp -= dmg
        self.hunger = 0
    def update(self, target):
        self.update_base()
        self.hunger += 1
        if self.hunger > 6:
            self.bite(target)
        elif len(self.webs) < 5:
            self.spin()
        else:
            self.move()
        self.trap(target)
        self.decay_webs()

class Target:
    def __init__(self):
        self.hp = 300
        self.pos = Vec2(50,50)

class EventBus:
    def __init__(self):
        self.listeners = defaultdict(list)
    def subscribe(self, key, fn):
        self.listeners[key].append(fn)
    def emit(self, key, data=None):
        for fn in self.listeners[key]:
            fn(data)

class Logger:
    def __init__(self):
        self.logs = []
    def log(self, text):
        self.logs.append(text)
    def dump(self):
        for l in self.logs:
            print(l)

class EnemyManager:
    def __init__(self):
        self.enemies = [Witch(), GraveyardKeeper(), Spider()]
    def update(self, target):
        for e in self.enemies:
            e.update(target)

class Simulation:
    def __init__(self):
        self.target = Target()
        self.manager = EnemyManager()
        self.logger = Logger()
        self.events = EventBus()
        self.events.subscribe("damage", lambda d: self.logger.log(f"Damage: {d}"))
    def step(self):
        before = self.target.hp
        self.manager.update(self.target)
        after = self.target.hp
        if after < before:
            self.events.emit("damage", before - after)
    def run(self, steps=150):
        for i in range(steps):
            self.step()
            if self.target.hp <= 0:
                print("Target defeated at step", i)
                break

if __name__ == "__main__":
    sim = Simulation()
    sim.run()
