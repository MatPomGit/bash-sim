# -*- coding: utf-8 -*-
import random
from map_generator import MapGenerator
from civilization import Civilization
from ui import UI
from automation import Automation

class Game:
    """Główna klasa zarządzająca rozgrywką."""

    def __init__(self):
        self.ui = UI()
        self.map = None
        self.civ = None
        self.turn = 0
        self.automation = None

    def run(self):
        self.ui.show_title()
        while True:
            choice = self.ui.main_menu()
            if choice == '1':
                self.new_game()
                break
            elif choice == '2':
                self.ui.show_message("Funkcja wczytywania gry nie jest jeszcze dostępna.")
                continue
            else:
                return

        while not self.is_game_over():
            self.turn += 1
            self.ui.show_turn(self.turn)
            self.ui.show_map(self.map, self.civ)
            self.ui.show_resources(self.civ)
            self.ui.show_cities(self.civ)
            self.process_turn()
            if not self.is_game_over():
                if not self.automation.enabled['full_auto']:
                    input("\nNaciśnij Enter, aby kontynuować...")

        self.ui.show_game_over(self.civ)

    def new_game(self):
        size = self.ui.choose_map_size()
        generator = MapGenerator(size)
        self.map = generator.generate()
        start_pos = self.ui.choose_start_position(self.map)
        self.civ = Civilization("Polanie", start_pos, self.map)
        self.civ.add_city(start_pos)
        self.automation = Automation(self.civ, self.map, self.ui)

    def process_turn(self):
        # Zbieranie surowców
        self.civ.gather_resources(self.map)
        # Zużycie drewna na opał (temperatura)
        self.civ.consume_wood_for_heating()
        # Konsumpcja żywności
        self.civ.consume_food()
        # Automatyzacja (handel, migracje, badania)
        if self.automation.enabled['full_auto']:
            self.automation.auto_full_turn()
        else:
            self.automation.auto_trade()
            self.automation.auto_migration()
            self.automation.auto_research()
        # Wzrost populacji
        self.civ.grow_population()
        # Automatyczne zakładanie miast (zawsze włączone)
        self.civ.auto_found_city(self.ui)
        # Produkcja (technologie)
        self.civ.apply_technology_bonuses()
        # Losowe zdarzenie
        self.random_event()
        # Akcje gracza (pomijane w trybie full_auto)
        if not self.automation.enabled['full_auto']:
            self.ui.show_actions()
            action = self.ui.get_action()
            self.handle_action(action)

    def handle_action(self, action):
        if action == '1':
            self.civ.found_city(self.map, self.ui)
        elif action == '2':
            self.civ.research_technology(self.ui)
        elif action == '3':
            self.ui.show_detailed_map(self.map, self.civ)
        elif action == '4':
            self.automation_menu()
        else:
            self.ui.show_message("Nieznana akcja.")

    def automation_menu(self):
        self.ui.show_message("\n=== USTAWIENIA AUTOMATYZACJI ===")
        features = list(self.automation.enabled.keys())
        for idx, feature in enumerate(features, 1):
            status = "WŁ" if self.automation.enabled[feature] else "WYŁ"
            self.ui.show_message(f"{idx}. {feature}: {status}")
        self.ui.show_message("0. Powrót")
        choice = self.ui.get_number("Wybierz funkcję do przełączenia: ", 0, len(features))
        if choice == 0:
            return
        feature = features[choice - 1]
        self.automation.toggle_auto(feature)

    def random_event(self):
        """Generuje losowe zdarzenie (co 5 tur, 40% szans)."""
        if self.turn % 5 == 0 and random.random() < 0.4:
            events = [
                ("🌾 Powódź! Zniszczyła część plonów.",
                 lambda: self.civ.change_food(-self.civ.food // 4)),
                ("🔥 Susza! Spadła produkcja żywności.",
                 lambda: setattr(self.civ, 'food', max(0, self.civ.food - 12))),
                ("✨ Odkryto złoża kamienia! +15 kamienia.",
                 lambda: self.civ.change_stone(15)),
                ("⚔️ Najazd barbarzyńców! Straciliśmy 2 populację.",
                 lambda: self.civ.change_population(-2)),
                ("🌡️ Fala upałów! Plony spadają o 30% na 2 tury.",
                 lambda: setattr(self.civ, 'food_modifier', 0.7)),
                ("❄️ Sroga zima! Zużycie drewna na opał wzrasta o 50% na 2 tury.",
                 lambda: setattr(self.civ, 'wood_heating_modifier', 1.5)),
                ("🦗 Plaga szarańczy! -20 żywności.",
                 lambda: self.civ.change_food(-20)),
                ("🏹 Odkryto nowe pastwiska! +15 żywności.",
                 lambda: self.civ.change_food(15)),
                ("🌋 Trzęsienie ziemi! Zniszczyło 10 kamienia.",
                 lambda: self.civ.change_stone(-10)),
                ("🔥 Pożar lasu! -15 drewna.",
                 lambda: self.civ.change_wood(-15))
            ]
            desc, effect = random.choice(events)
            self.ui.show_message(f"⚠️ ZDARZENIE: {desc}")
            effect()
            if hasattr(self.civ, 'food_modifier') and random.random() < 0.2:
                delattr(self.civ, 'food_modifier')
            if hasattr(self.civ, 'wood_heating_modifier') and random.random() < 0.2:
                delattr(self.civ, 'wood_heating_modifier')
            if self.civ.population <= 0:
                self.civ.population = 0

    def is_game_over(self):
        return self.civ.population <= 0 or len(self.civ.cities) == 0