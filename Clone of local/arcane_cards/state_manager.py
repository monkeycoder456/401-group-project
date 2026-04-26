class GameStateManager:
    def __init__(self):
        self.state = "menu"

    def change_state(self, new_state):
        print(f"State -> {new_state}")
        self.state = new_state

    def is_state(self, state):
        return self.state == state
