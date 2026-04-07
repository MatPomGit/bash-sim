# -*- coding: utf-8 -*-
from terrain import get_terrain_by_symbol

class City:
    """Klasa reprezentująca pojedyncze miasto."""
    
    def __init__(self, position, game_map):
        self.position = position  # (x, y)
        self.population = 3       # początkowa populacja miasta
        self.game_map = game_map
    
    def collect_resources(self, game_map):
        """Zbiera surowce z pól w promieniu 2 od miasta."""
        food = 0
        wood = 0
        stone = 0
        x0, y0 = self.position
        radius = 2
        for dx in range(-radius, radius+1):
            for dy in range(-radius, radius+1):
                x = x0 + dx
                y = y0 + dy
                if 0 <= x < len(game_map) and 0 <= y < len(game_map[0]):
                    symbol = game_map[x][y]
                    terrain = get_terrain_by_symbol(symbol)
                    # Mnożnik przez populację miasta (im więcej ludzi, tym więcej zbiorów)
                    multiplier = max(1, self.population // 2)
                    food += terrain.food * multiplier
                    wood += terrain.wood * multiplier
                    stone += terrain.stone * multiplier
        return food, wood, stone