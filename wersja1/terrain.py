# -*- coding: utf-8 -*-
"""Definicje typów terenu."""

class Terrain:
    def __init__(self, name, symbol, food, wood, stone, color_code, passable=True):
        self.name = name          # nazwa po polsku
        self.symbol = symbol      # znak ASCII na mapie
        self.food = food          # produkcja żywności
        self.wood = wood          # produkcja drewna
        self.stone = stone        # produkcja kamienia
        self.color = color_code   # kod ANSI koloru
        self.passable = passable  # czy można założyć miasto

# Stałe tereny
TERRAINS = {
    'plains': Terrain("Równina", "R", 2, 1, 0, "\033[92m", True),     # zielony
    'forest': Terrain("Las", "L", 1, 3, 0, "\033[32m", True),         # ciemnozielony
    'mountain': Terrain("Góry", "G", 0, 0, 3, "\033[37m", False),     # biały
    'water': Terrain("Woda", "W", 0, 0, 0, "\033[34m", False),        # niebieski
    'swamp': Terrain("Bagno", "B", 1, 1, 0, "\033[36m", True)         # cyjan
}

def get_terrain_by_symbol(symbol):
    for t in TERRAINS.values():
        if t.symbol == symbol:
            return t
    return TERRAINS['plains']