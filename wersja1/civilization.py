# -*- coding: utf-8 -*-
from city import City
from terrain import TERRAINS, get_terrain_by_symbol

class Civilization:
    """Klasa reprezentująca cywilizację gracza."""
    
    def __init__(self, name, start_pos, game_map):
        self.name = name
        self.cities = []          # lista obiektów City
        self.technologies = set() # posiadane technologie
        self.food = 50
        self.wood = 20
        self.stone = 10
        self.population = 5       # całkowita populacja (suma z miast)
        self.tech_level = 0       # poziom technologii (0-5)
        self.game_map = game_map
        
        # Podstawowa technologia
        self.technologies.add("Rolnictwo")
    
    def add_city(self, position):
        """Dodaje nowe miasto w podanej pozycji (x,y)."""
        if not self._is_valid_city_position(position):
            return False
        city = City(position, self.game_map)
        self.cities.append(city)
        self._recalculate_population()
        return True
    
    def _is_valid_city_position(self, pos):
        """Sprawdza czy można założyć miasto (teren nie może być wodą/górami)."""
        x, y = pos
        symbol = self.game_map[x][y]
        terrain = get_terrain_by_symbol(symbol)
        return terrain.passable and not self._is_city_at(pos)
    
    def _is_city_at(self, pos):
        for city in self.cities:
            if city.position == pos:
                return True
        return False
    
    def _recalculate_population(self):
        self.population = sum(city.population for city in self.cities)
    
    def gather_resources(self, game_map):
        """Zbiera surowce ze wszystkich pól należących do miast."""
        food_gathered = 0
        wood_gathered = 0
        stone_gathered = 0
        
        for city in self.cities:
            f, w, s = city.collect_resources(game_map)
            food_gathered += f
            wood_gathered += w
            stone_gathered += s
        
        # Modyfikatory technologii
        if "Rolnictwo" in self.technologies:
            food_gathered = int(food_gathered * 1.2)
        if "Górnictwo" in self.technologies:
            stone_gathered = int(stone_gathered * 1.5)
        if "Tartak" in self.technologies:
            wood_gathered = int(wood_gathered * 1.3)
        
        self.change_food(food_gathered)
        self.change_wood(wood_gathered)
        self.change_stone(stone_gathered)
    
    def consume_food(self):
        """Każda jednostka populacji zużywa 2 żywności na turę."""
        consumption = self.population * 2
        self.change_food(-consumption)
    
    def grow_population(self):
        """Jeśli nadwyżka żywności > 10, wzrost populacji."""
        if self.food > 20 and self.population > 0:
            growth = min(2, self.food // 15)
            self.change_population(growth)
            self.change_food(-growth * 10)
            # Dodaj nową populację do pierwszego miasta
            if self.cities:
                self.cities[0].population += growth
    
    def change_food(self, delta):
        self.food += delta
        if self.food < 0:
            self.food = 0
    
    def change_wood(self, delta):
        self.wood += delta
        if self.wood < 0:
            self.wood = 0
    
    def change_stone(self, delta):
        self.stone += delta
        if self.stone < 0:
            self.stone = 0
    
    def change_population(self, delta):
        self.population += delta
        if self.population < 0:
            self.population = 0
        # Aktualizuj populację w miastach proporcjonalnie
        if self.cities and self.population > 0:
            # Prosty podział – pierwsze miasto dostaje całość
            self.cities[0].population = self.population
    
    def apply_technology_bonuses(self):
        """Efekty technologii (poza surowcami)."""
        if "Urbanizacja" in self.technologies:
            # Zmniejszenie konsumpcji żywności o 20% (nie implementujemy tu)
            pass
    
    def research_technology(self, ui):
        """Pozwala graczowi na badanie nowej technologii."""
        techs_available = {
            "Górnictwo": {"cost": 30, "stone": 30},
            "Tartak": {"cost": 25, "wood": 25},
            "Urbanizacja": {"cost": 50, "food": 40, "stone": 20}
        }
        available = []
        for tech, cost in techs_available.items():
            if tech not in self.technologies:
                affordable = True
                if "stone" in cost and self.stone < cost["stone"]:
                    affordable = False
                if "wood" in cost and self.wood < cost["wood"]:
                    affordable = False
                if "food" in cost and self.food < cost["food"]:
                    affordable = False
                if affordable:
                    available.append(tech)
        
        if not available:
            ui.show_message("Brak dostępnych technologii do badania lub brak surowców.")
            return
        
        ui.show_message("Dostępne technologie do badania:")
        for i, tech in enumerate(available, 1):
            cost = techs_available[tech]
            cost_str = f"kamień: {cost.get('stone',0)}, drewno: {cost.get('wood',0)}, żywność: {cost.get('food',0)}"
            ui.show_message(f"{i}. {tech} (koszt: {cost_str})")
        
        choice = ui.get_number("Wybierz technologię (0 aby anulować): ", 0, len(available))
        if choice == 0:
            return
        tech = available[choice-1]
        cost = techs_available[tech]
        if "stone" in cost:
            self.change_stone(-cost["stone"])
        if "wood" in cost:
            self.change_wood(-cost["wood"])
        if "food" in cost:
            self.change_food(-cost["food"])
        self.technologies.add(tech)
        ui.show_message(f"✅ Odkryto technologię: {tech}!")
    
    def found_city(self, game_map, ui):
        """Zakłada nowe miasto (wymaga 50 drewna i 3 populacji)."""
        if self.wood < 50 or self.population < 3:
            ui.show_message("Brak surowców: potrzeba 50 drewna i 3 populacji.")
            return
        ui.show_message("Podaj współrzędne nowego miasta (wiersz, kolumna):")
        x = ui.get_number("Wiersz: ", 0, len(game_map)-1)
        y = ui.get_number("Kolumna: ", 0, len(game_map[0])-1)
        pos = (x, y)
        if self._is_valid_city_position(pos):
            self.add_city(pos)
            self.change_wood(-50)
            self.change_population(-3)
            # Przesuń populację z pierwszego miasta
            if self.cities:
                self.cities[0].population -= 3
            ui.show_message(f"Założono nowe miasto na pozycji ({x},{y})!")
        else:
            ui.show_message("Nie można założyć miasta na wodzie, górach lub w miejscu istniejącego miasta.")
    
    def is_defeated(self):
        return self.population <= 0 or len(self.cities) == 0