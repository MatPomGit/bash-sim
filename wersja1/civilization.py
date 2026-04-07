# -*- coding: utf-8 -*-
import random
from city import City
from terrain import TERRAINS, get_terrain_by_symbol

class Civilization:
    """Klasa reprezentująca cywilizację gracza."""
    
    def __init__(self, name, start_pos, game_map):
        self.name = name
        self.cities = []
        self.technologies = set()
        self.food = 50
        self.wood = 20
        self.stone = 10
        self.population = 5
        self.tech_level = 0
        self.game_map = game_map
        self.map_size = len(game_map)
        
        self.technologies.add("Rolnictwo")
    
    def add_city(self, position):
        if not self._is_valid_city_position(position):
            return False
        city = City(position, self.game_map)
        self.cities.append(city)
        self._recalculate_population()
        return True
    
    def _is_valid_city_position(self, pos):
        x, y = pos
        symbol = self.game_map[x][y]
        terrain = get_terrain_by_symbol(symbol)
        return terrain.passable and not self._is_city_at(pos)
    
    def _is_city_at(self, pos):
        return any(city.position == pos for city in self.cities)
    
    def _recalculate_population(self):
        self.population = sum(city.population for city in self.cities)
    
    def _get_climate_zone(self, x):
        """Zwraca strefę klimatyczną na podstawie wiersza x (0-góra, rozmiar-dół)."""
        if x < self.map_size // 3:
            return 'cold'       # górna część mapy – zimno
        elif x < 2 * self.map_size // 3:
            return 'temperate'  # środkowa – umiarkowana
        else:
            return 'warm'       # dolna – ciepła
    
    def consume_wood_for_heating(self):
        """W zimnych strefach miasta zużywają drewno na opał. Brak powoduje spadek populacji."""
        total_wood_needed = 0
        for city in self.cities:
            x, _ = city.position
            zone = self._get_climate_zone(x)
            pop = city.population
            if zone == 'cold':
                need = (pop + 1) // 2   # 1 drewna na 2 osoby (zaokrąglenie w górę)
            elif zone == 'temperate':
                need = (pop + 3) // 4   # 1 drewna na 4 osoby
            else:  # warm
                need = 0
            total_wood_needed += need
        
        # Modyfikatory zdarzeń
        if hasattr(self, 'wood_heating_modifier'):
            total_wood_needed = int(total_wood_needed * self.wood_heating_modifier)
        
        if self.wood >= total_wood_needed:
            self.wood -= total_wood_needed
        else:
            deficit = total_wood_needed - self.wood
            self.wood = 0
            # Brak drewna powoduje spadek populacji (1 osoba na każde 2 brakujące drewna)
            deaths = (deficit + 1) // 2
            self.change_population(-deaths)
            # Komunikat zostanie wyświetlony przez UI (można dodać w game.py)
            print(f"❄️ Brak drewna na opał! {deaths} osób zamarzło.")
    
    def gather_resources(self, game_map):
        food_gathered = 0
        wood_gathered = 0
        stone_gathered = 0
        
        for city in self.cities:
            f, w, s = city.collect_resources(game_map)
            food_gathered += f
            wood_gathered += w
            stone_gathered += s
        
        if "Rolnictwo" in self.technologies:
            food_gathered = int(food_gathered * 1.2)
        if "Górnictwo" in self.technologies:
            stone_gathered = int(stone_gathered * 1.5)
        if "Tartak" in self.technologies:
            wood_gathered = int(wood_gathered * 1.3)
        
        # Modyfikatory zdarzeń (np. fala upałów)
        if hasattr(self, 'food_modifier'):
            food_gathered = int(food_gathered * self.food_modifier)
        
        self.change_food(food_gathered)
        self.change_wood(wood_gathered)
        self.change_stone(stone_gathered)
    
    def consume_food(self):
        consumption = self.population * 2
        self.change_food(-consumption)
    
    def grow_population(self):
        if self.food > 20 and self.population > 0:
            growth = min(2, self.food // 15)
            self.change_population(growth)
            self.change_food(-growth * 10)
            if self.cities:
                self.cities[0].population += growth
    
    def auto_found_city(self, ui):
        """Automatyczne zakładanie nowego miasta, gdy populacja jest wysoka i są surowce."""
        # Warunki: populacja >= 15, co najmniej 30 drewna i 50 żywności, oraz nie za dużo miast
        if self.population < 15:
            return
        if self.wood < 30 or self.food < 50:
            return
        # Ograniczenie liczby miast (np. max 1 miasto na 5 populacji)
        if len(self.cities) >= self.population // 5:
            return
        
        # Znajdź odpowiednie miejsce w pobliżu istniejących miast
        new_pos = None
        for city in self.cities:
            x0, y0 = city.position
            for dx in range(-5, 6):
                for dy in range(-5, 6):
                    x = x0 + dx
                    y = y0 + dy
                    if 0 <= x < self.map_size and 0 <= y < self.map_size:
                        if self._is_valid_city_position((x, y)):
                            new_pos = (x, y)
                            break
                if new_pos:
                    break
            if new_pos:
                break
        
        if not new_pos:
            return  # brak wolnego miejsca
        
        # Znajdź miasto z największą populacją (źródło osadników)
        source_city = max(self.cities, key=lambda c: c.population)
        if source_city.population < 3:
            return
        
        # Koszt: 30 drewna, 50 żywności, 3 populacji
        self.change_wood(-30)
        self.change_food(-50)
        source_city.population -= 3
        self._recalculate_population()
        
        # Załóż nowe miasto
        self.add_city(new_pos)
        # Nowe miasto ma początkową populację 3 (już dodane przez add_city, ale tam jest 3)
        # Znajdź nowo dodane miasto i ustaw jego populację na 3 (bo add_city daje domyślnie 3)
        for city in self.cities:
            if city.position == new_pos:
                city.population = 3
                break
        
        ui.show_message(f"🏙️ Autonomiczni osadnicy z miasta {source_city.position} założyli nowe miasto na pozycji {new_pos}!")
    
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
        if self.cities and self.population > 0:
            self.cities[0].population = self.population  # uproszczenie – cała populacja w pierwszym mieście
    
    def apply_technology_bonuses(self):
        if "Urbanizacja" in self.technologies:
            # Zmniejszenie konsumpcji żywności o 20% (można dodać później)
            pass
    
    def research_technology(self, ui):
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
            if self.cities:
                self.cities[0].population -= 3
            ui.show_message(f"Założono nowe miasto na pozycji ({x},{y})!")
        else:
            ui.show_message("Nie można założyć miasta na wodzie, górach lub w miejscu istniejącego miasta.")
    
    def is_defeated(self):
        return self.population <= 0 or len(self.cities) == 0

    def research_technology_auto(self, tech_name):
        """Automatyczne badanie technologii (bez interakcji z UI)."""
        techs_available = {
            "Górnictwo": {"cost": 30, "stone": 30},
            "Tartak": {"cost": 25, "wood": 25},
            "Urbanizacja": {"cost": 50, "food": 40, "stone": 20}
        }
        if tech_name not in techs_available or tech_name in self.technologies:
            return
        cost = techs_available[tech_name]
        # Sprawdź, czy stać
        for res in cost:
            if res != 'cost' and getattr(self, res, 0) < cost[res]:
                return
        # Zapłać
        for res in cost:
            if res != 'cost':
                setattr(self, res, getattr(self, res) - cost[res])
        self.technologies.add(tech_name)