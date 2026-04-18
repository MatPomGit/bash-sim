# -*- coding: utf-8 -*-
import random
from terrain import TERRAINS

class MapGenerator:
    """Generator mapy 2D z różnymi typami terenu."""
    
    def __init__(self, size):
        self.size = size  # rozmiar (size x size)
    
    def generate(self):
        """Generuje mapę jako listę list znaków terenu."""
        # Najpierw wypełnij wodą
        map_data = [['water' for _ in range(self.size)] for _ in range(self.size)]
        
        # Dodaj kilka losowych punktów lądowych i rozrastaj
        num_land = max(3, self.size // 3)
        for _ in range(num_land):
            x = random.randint(2, self.size-3)
            y = random.randint(2, self.size-3)
            self._grow_land(map_data, x, y, self.size // 4)
        
        # Zamień typy terenu na symbole
        for i in range(self.size):
            for j in range(self.size):
                if map_data[i][j] != 'water':
                    # Losuj typ lądu z prawdopodobieństwem
                    rand = random.random()
                    if rand < 0.5:
                        map_data[i][j] = 'plains'
                    elif rand < 0.7:
                        map_data[i][j] = 'forest'
                    elif rand < 0.85:
                        map_data[i][j] = 'mountain'
                    else:
                        map_data[i][j] = 'swamp'
        
        # Zamień na symbole (dla wygody w grze przechowujemy symbole)
        symbol_map = []
        for i in range(self.size):
            row = []
            for j in range(self.size):
                terrain_type = map_data[i][j]
                row.append(TERRAINS[terrain_type].symbol)
            symbol_map.append(row)
        
        return symbol_map
    
    def _grow_land(self, map_data, x, y, radius):
        """Rozrastanie lądu od punktu (x,y) w promieniu radius."""
        for i in range(max(0, x-radius), min(self.size, x+radius)):
            for j in range(max(0, y-radius), min(self.size, y+radius)):
                if random.random() < 0.6:
                    map_data[i][j] = 'plains'  # tymczasowo równina