# -*- coding: utf-8 -*-
import os
from terrain import TERRAINS, get_terrain_by_symbol

class UI:
    """Interfejs użytkownika w terminalu."""
    
    RESET = "\033[0m"
    
    def clear(self):
        os.system('cls' if os.name == 'nt' else 'clear')
    
    def show_title(self):
        self.clear()
        print("=" * 50)
        print("   CYWilizacja: POCZĄTEK   ".center(50))
        print("   Symulacja rozwoju cywilizacji   ".center(50))
        print("=" * 50)
    
    def main_menu(self):
        print("\n1. Nowa gra")
        print("2. Wczytaj grę (niedostępne)")
        print("3. Wyjście")
        return input("Wybierz opcję: ")
    
    def choose_map_size(self):
        print("\nWybierz rozmiar mapy:")
        print("1. Mała (10x10)")
        print("2. Średnia (20x20)")
        print("3. Duża (30x30)")
        choice = input("Opcja: ")
        if choice == '1':
            return 10
        elif choice == '2':
            return 20
        else:
            return 30
    
    def choose_start_position(self, game_map):
        """Gracz wybiera miejsce startowe."""
        self.show_map(game_map, None)
        print("\nWybierz pozycję startową dla swojej stolicy.")
        while True:
            try:
                x = int(input("Podaj wiersz (0-{}): ".format(len(game_map)-1)))
                y = int(input("Podaj kolumnę (0-{}): ".format(len(game_map[0])-1)))
                symbol = game_map[x][y]
                terrain = get_terrain_by_symbol(symbol)
                if terrain.passable:
                    return (x, y)
                else:
                    print("Nie można założyć miasta na wodzie lub górach. Wybierz inny teren.")
            except (ValueError, IndexError):
                print("Nieprawidłowe współrzędne.")
    
    def show_map(self, game_map, civ):
        """Wyświetla mapę z oznaczeniem miast."""
        self.clear()
        print("Mapa świata (legenda: R=Równina, L=Las, G=Góry, W=Woda, B=Bagno, M=Miasto):\n")
        # Nagłówek z numerami kolumn
        print("   ", end="")
        for j in range(len(game_map[0])):
            print(f"{j:2}", end="")
        print()
        for i, row in enumerate(game_map):
            print(f"{i:2} ", end="")
            for j, symbol in enumerate(row):
                if civ and any(city.position == (i, j) for city in civ.cities):
                    char = "M"
                    color = "\033[93m"  # żółty
                else:
                    char = symbol
                    terrain = get_terrain_by_symbol(symbol)
                    color = terrain.color
                print(f"{color}{char:2}{self.RESET}", end="")
            print()
        print("\n" + "="*50)
    
    def show_detailed_map(self, game_map, civ):
        """Pokazuje mapę z informacją o typie terenu pod kursorem (uproszczone)."""
        self.show_map(game_map, civ)
        print("Naciśnij Enter, aby wrócić.")
        input()
    
    def show_resources(self, civ):
        print(f"\n📦 Zasoby: Żywność: {civ.food} | Drewno: {civ.wood} | Kamień: {civ.stone}")
        print(f"👥 Populacja całkowita: {civ.population}")
        print(f"🔬 Technologie: {', '.join(civ.technologies) if civ.technologies else 'brak'}")
    
    def show_cities(self, civ):
        if not civ.cities:
            print("🏙️ Brak miast!")
        else:
            print("🏙️ Miasta:")
            for idx, city in enumerate(civ.cities, 1):
                print(f"   {idx}. Pozycja {city.position}, populacja: {city.population}")
    
    def show_turn(self, turn):
        print(f"\n📅 TURA {turn}")
    
    def show_actions(self):
        print("\nDostępne akcje:")
        print("1. Załóż nowe miasto (koszt: 50 drewna, 3 populacji)")
        print("2. Badaj technologię")
        print("3. Przeglądaj mapę")
        print("0. Zakończ turę (brak akcji)")
    
    def get_action(self):
        return input("Wybierz akcję: ")
    
    def get_number(self, prompt, min_val, max_val):
        while True:
            try:
                val = int(input(prompt))
                if min_val <= val <= max_val:
                    return val
                print(f"Podaj liczbę z zakresu {min_val}-{max_val}.")
            except ValueError:
                print("To nie jest liczba.")
    
    def show_message(self, msg):
        print(msg)
    
    def show_game_over(self, civ):
        self.clear()
        print("=" * 50)
        if civ.population <= 0:
            print("GRA SKOŃCZONA – TWOJA CYWILIZACJA WYMIZARŁA Z GŁODU!")
        else:
            print("GRA SKOŃCZONA – TWOJE OSTATNIE MIASTO LEGŁO W GRUZACH!")
        print(f"Przetrwałeś {civ.tech_level} poziomów technologii.")
        print("Dziękujemy za grę!")
        print("=" * 50)