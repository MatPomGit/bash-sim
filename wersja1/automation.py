# -*- coding: utf-8 -*-
import random

class Automation:
    """Klasa odpowiedzialna za automatyczne decyzje cywilizacji."""

    def __init__(self, civ, game_map, ui):
        self.civ = civ
        self.game_map = game_map
        self.ui = ui
        self.enabled = {
            'research': True,       # automatyczne badanie technologii
            'trade': True,          # automatyczny handel surowcami
            'migration': True,      # automatyczne przesiedlenia ludności
            'full_auto': False      # pełny autopilot (wykonuje wszystkie akcje)
        }

    def toggle_auto(self, feature):
        """Przełącza stan automatyzacji danej funkcji."""
        if feature in self.enabled:
            self.enabled[feature] = not self.enabled[feature]
            self.ui.show_message(f"Automatyzacja {feature} -> {'włączona' if self.enabled[feature] else 'wyłączona'}")

    def auto_research(self):
        """Automatycznie bada technologię, jeśli są surowce."""
        if not self.enabled['research']:
            return False

        techs_available = {
            "Górnictwo": {"stone": 30},
            "Tartak": {"wood": 25},
            "Urbanizacja": {"food": 40, "stone": 20}
        }
        possible = []
        for tech, cost in techs_available.items():
            if tech not in self.civ.technologies:
                if all(getattr(self.civ, res, 0) >= cost[res] for res in cost):
                    possible.append(tech)

        if possible:
            tech = random.choice(possible)
            # Wywołanie automatycznego badania (bez UI)
            self.civ.research_technology_auto(tech)
            self.ui.show_message(f"🤖 Automatyczne badanie: {tech}")
            return True
        return False

    def auto_trade(self):
        """Automatyczny handel: zamiana nadmiaru drewna na kamień lub żywność."""
        if not self.enabled['trade']:
            return False

        if self.civ.wood > 40:
            if self.civ.stone < 10:
                self.civ.change_wood(-20)
                self.civ.change_stone(10)
                self.ui.show_message("🤝 Automatyczny handel: wymieniono 20 drewna na 10 kamienia.")
                return True
            elif self.civ.food < 20:
                self.civ.change_wood(-15)
                self.civ.change_food(15)
                self.ui.show_message("🤝 Automatyczny handel: wymieniono 15 drewna na 15 żywności.")
                return True
        return False

    def auto_migration(self):
        """Automatyczne przesiedlenie ludności z miasta przeludnionego do mniejszego."""
        if not self.enabled['migration']:
            return False
        if len(self.civ.cities) < 2:
            return False

        max_city = max(self.civ.cities, key=lambda c: c.population)
        min_city = min(self.civ.cities, key=lambda c: c.population)
        if max_city.population - min_city.population >= 4:
            max_city.population -= 1
            min_city.population += 1
            self.civ._recalculate_population()
            self.ui.show_message(f"🚶 Automatyczna migracja: 1 osoba z {max_city.position} do {min_city.position}")
            return True
        return False

    def auto_full_turn(self):
        """Pełny autopilot – wykonuje wszystkie możliwe akcje w turze."""
        if not self.enabled['full_auto']:
            return
        self.auto_trade()
        self.auto_research()
        # Automatyczne zakładanie miast jest już wywoływane w civ.auto_found_city()
        # Dodatkowo symulujemy naciśnięcie "zakończ turę" – brak dalszych akcji