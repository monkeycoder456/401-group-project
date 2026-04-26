class GameLogger:
    def __init__(self):
        self.logs = []

    def log(self, message):
        self.logs.append(message)
        print("[LOG]", message)

    def show_history(self):
        print("\n--- Game Log ---")
        for log in self.logs:
            print(log)
