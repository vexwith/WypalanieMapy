## Wypalanie Mapy 2
gra typu puzzle zrobiona w 3 dni na game jam https://itch.io/jam/prgj

link do gry - https://vex2137.itch.io/wypalanie-mapy-2

## Architektura projektu

```
WypalanieMapy/ 
├── game_manager.gd # Główny system zarządzający grą 
├── Globals.gd # Globalne zmienne stanu gry 
├── SignalBus.gd # Event bus dla komunikacji między systemami 
├── project.godot # Konfiguracja projektu Godot 
│ 
├── Mapa/ # Podstawowe kawałki mapy, ich zbiory oraz zasoby graficzne
  └── BlueMap
  └── FireMap
  └── kawałek1
  .
  .
  └── kawałek33
  └── MetaMap
  └── NonEuclideanMap
├── GUI/ # Elementy interfejsu użytkownika 
  └── CzyNaPtak/
  └── Endings/
├── UI/ # Sceny UI (menu, etc.) 
  └── VolSettings/
├── Items/ # Obiekty interaktywne
  └── Messages/ # Kartki do zbierania
├── CustomPieces/ # Elementy mapy ze specjalnymi zasadami
├── Ognik/ # Kursor
├── Tutorial/ # Sceny tutorialowe 
├── MrocznaWioska/
│ 
├── Wavs/ # Ścieżka dźwiękowa i efekty dźwiękowe 
├── *.ttf / *.otf # Czcionki (AutourOne, PixelFraktur, Silver, Get Now) 
└── [czcionki i ikony] # Zasoby graficzne
```

## Cel gry

Oryginalnie wypalanie mapy pochodzi z gry Reksio i Skarb Piratów. W jednej z minigierek gracz musiał odkryć co widnieje na mapie napisanej atramentem sympatycznym poprzez zbliżanie ognia do poszczególnych jej elementów.

Każde kliknięcie zwiększa widoczność wybranego kawałka w znacznym stopniu, a także kawałków obok niego o mniejszą wartość. Celem jest doprowadzenie mapy do stanu, w którym wszystko jest widoczne i w kolorze, jednocześnie uważając żeby nie wypalić dziury w papierze.

## Kontrolki

- **LPM / 1** - Kliknij pole
- **PPM / 2** - Użyj łapy (po odblokowaniu)
- **R** - Restart
- **Z** - Cofanie ruchów o jedno kliknięcie (Rewind)
- **C** - Ponowienie ruchów (Redo)
- **Ctrl** - Tryb szczegółowy
- **Esc** - Menu

## Funkcje zaawansowane

- **Saver/Loader** - Gra zapisuje postęp (zaszyfrowany JSON)
- **Rewind System** - Pełna historia ruchów z możliwością cofania/ponawiania
- **Dynamiczny BGM** - Muzyka zmienia tempo w zależności od stanu gry
- **System dialogów** - Rozbudowany system dialogowy z wieloma opcjami i wieloma endingami
