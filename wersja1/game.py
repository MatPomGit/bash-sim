# -*- coding: utf-8 -*-
import random
from map_generator import MapGenerator
from civilization import Civilization
from ui import UI

class Game:
    """Główna klasa zarządzająca rozgrywką."""
    
    def __init__(self):
        self.ui = UI()
        self.map = None
        self.civ = None
        self.turn = 0
    
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
        
        # Główna pętla gry
        while not self.is_game_over():
            self.turn += 1
            self.ui.show_turn(self.turn)
            self.ui.show_map(self.map, self.civ)
            self.ui.show_resources(self.civ)
            self.ui.show_cities(self.civ)
            self.process_turn()
            if not self.is_game_over():
                input("\nNaciśnij Enter, aby kontynuować...")
        
        self.ui.show_game_over(self.civ)
    
    def new_game(self):
        """Inicjalizacja nowej gry."""
        size = self.ui.choose_map_size()
        generator = MapGenerator(size)
        self.map = generator.generate()
        start_pos = self.ui.choose_start_position(self.map)
        self.civ = Civilization("Polanie", start_pos, self.map)
        self.civ.add_city(start_pos)
    
    def process_turn(self):
        """Wykonuje jedną turę gry."""
        # Zbieranie surowców
        self.civ.gather_resources(self.map)
        # Konsumpcja żywności
        self.civ.consume_food()
        # Wzrost populacji
        self.civ.grow_population()
        # Produkcja (technologie)
        self.civ.apply_technology_bonuses()
        # Losowe zdarzenie
        self.random_event()
        # Akcje gracza
        self.ui.show_actions()
        action = self.ui.get_action()
        self.handle_action(action)
    
    def handle_action(self, action):
        """Obsługa wybranej akcji gracza."""
        if action == '1':
            self.civ.found_city(self.map, self.ui)
        elif action == '2':
            self.civ.research_technology(self.ui)
        elif action == '3':
            self.ui.show_detailed_map(self.map, self.civ)
        else:
            self.ui.show_message("Nieznana akcja.")
    
    def random_event(self):
        """Generuje losowe zdarzenie (co 5 tur)."""
        if self.turn % 5 == 0 and random.random() < 0.4:
            events = [
                ("🌾 Powódź! Zniszczyła część plonów.", lambda: self.civ.change_food(-self.civ.food // 4)),
                ("🔥 Susza! Spadła produkcja żywności.", lambda: setattr(self.civ, 'food', max(0, self.civ.food - 10))),
                ("✨ Odkryto złoża kamienia! +15 kamienia.", lambda: self.civ.change_stone(15)),
                ("⚔️ Najazd barbarzyńców! Straciliśmy 2 populację.", lambda: self.civ.change_population(-2))
            ]
            desc, effect = random.choice(events)
            self.ui.show_message(f"⚠️ ZDARZENIE: {desc}")
            effect()
            # Sprawdź czy cywilizacja nie upadła
            if self.civ.population <= 0:
                self.civ.population = 0
    
    def is_game_over(self):
        """Sprawdza warunki końca gry."""
        return self.civ.population <= 0 or len(self.civ.cities) == 0