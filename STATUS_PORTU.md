# Status portu Re:boot → Web

Stan na **6 października 2026**. Nowy projekt: `/Users/pequtek/reboot/reboot-web`. Oryginał: `/Users/pequtek/reboot/re-boot`, punkt odniesienia `5f0de6713ae6668480d8577a95733379cf078cc8`.

**Gotowy jest pierwszy grywalny etap: menu → hala → Jadwiga → trzy sektory bazy danych → powrót → raport. Pełna gra nie jest jeszcze przeniesiona.**

„100%” poniżej oznacza ukończenie **konkretnie opisanego zakresu**, potwierdzone porównaniem danych lub testami. Nie oznacza zgodności całego systemu z wersją desktopową ani działania we wszystkich przeglądarkach. Samo skopiowanie grafiki, dialogów lub ikon nie oznacza przeniesienia ich mechaniki. Nie podajemy procentu całej gry, ponieważ rozmiary pozostałych zadań są różne.

## 1. Przeniesione w 100% w podanym zakresie

| Element | Co jest gotowe | Gdzie |
| --- | --- | --- |
| Trzy mapy konsoli serwisowej | Oryginalne układy pól, nazwy, opisy celów i podpowiedzi wszystkich sektorów. | `data/maze_levels.json` |
| Reguły konsoli | Ruch o jedno pole, ściany, uszkodzone sektory, zbieranie danych, pchanie skrzyń, gniazda, klucz, zamknięta i otwarta brama oraz pełne warunki zwycięstwa. | `scripts/maze_state.gd` |
| Cofanie i restart konsoli | Cofanie przywraca gracza, skrzynie, dane, klucz i licznik ruchów; restart odtwarza bieżący sektor. | `scripts/maze_state.gd`, `scripts/maze.gd` |
| Grywalna sekwencja trzech sektorów | Przejście sektorów 1 → 2 → 3; baza zostaje naprawiona dopiero po trzecim. Oryginalne rozwiązania działają. | `scripts/maze.gd`, `scripts/game.gd` |
| Dane pikselowych ikon | Wszystkie 12 oryginalnych matryc symboli 16 × 16 zachowano bez zmian. Ikony wykorzystywane przez konsolę są renderowane. Obecność ikon robota nie oznacza gotowej minigry robota. | `data/puzzle_icons.json`, `scripts/puzzle_icon.gd` |
| Lista autorów | Pełna treść napisów autorów z oryginału, dostępna w przewijanym oknie „Twórcy”. | `data/credits.txt`, `scripts/overlay.gd` |

**Gotowe dodatkowo dla etapu 1:** osobne repozytorium, projekt Godot 4.5.1 bez C#/.NET, działający eksport Web bez wątków, lokalny serwer i paczka ZIP. To nowa infrastruktura portu, nie przeniesiona funkcja oryginału.

## 2. Częściowo przeniesione — do dokończenia

| Obszar | Już działa | Co pozostaje |
| --- | --- | --- |
| Hala fabryczna | Oryginalna mapa, dekoracje, ściany i postacie; kamera, ruch po kliknięciu i wyszukiwanie drogi; ściany zasłaniające gracza stają się przezroczyste. | Pełne zachowanie wszystkich stanowisk i interakcji, znaczniki zadań zależne od tagów, wygląd maszyn zepsutych/naprawionych, porównanie zachowania z oryginałem. Zasięg interakcji obecnie wybiera najbliższą postać/maszynę w promieniu 76 jednostek zamiast oryginalnych stref. |
| Sterowana postać | Ruch i kierunkowe animacje jednego zestawu postaci. | Wybór postaci, drugi zestaw animacji i zapis wyboru. |
| Menu główne | Nowa gra, potwierdzenie zastąpienia zapisu, kontynuacja, ustawienia, pełny ekran, autorzy i animowane tło. | Intro SKNI, linki SKNI/uczelni oraz zgodność pozostałych zachowań i detali z oryginałem. Przycisk wyjścia z aplikacji celowo nie jest odtwarzany w przeglądarce. |
| Dialogi | Działają rozmowy Jadwigi przed naprawą i po niej, stopniowe wyświetlanie tekstu oraz komendy potrzebne do jej zadania. Dane pozostałych dialogów są skopiowane. | Ogólny silnik warunków, tagów i wszystkich komend; podłączenie reszty NPC; portrety i ich animacja; obsługa pełnej sekwencji wydarzeń. Obecne rozmowy z innymi NPC pokazują informację o zakresie etapu. |
| Zadanie Jadwigi | Rozmowa odblokowuje konsolę; trzy sektory naprawiają bazę; powrót i raport kończą zadanie. | Przywrócenie wymaganej kolejności fabularnej: zadanie Gerwazego powinno poprzedzać Jadwigę. Integracja z pełnym `QuestManager`, `TagManager` i głównym zadaniem fabryki. |
| Dziennik i cel | Wyświetlają cel naprawy bazy, liczbę odzyskanych sektorów i zakończenie etapu. | Lista wszystkich zadań, etapy, liczniki, zaznaczanie zadań i pełna obsługa ukończonych zleceń. Obecny dziennik jest pojedynczym oknem zadania Jadwigi. |
| Prezentacja konsoli | Plansza, symbole, legenda, sterowanie WASD/strzałkami/myszą, instrukcja, podpowiedzi, komunikaty i okna wyników. Okna blokują ruch i restart. | Pełna zgodność komunikatów, kategorii informacji i dźwięków z oryginałem. Gotowość reguł i poziomów nie oznacza identycznej oprawy całej minigry. |
| Zapis | Zapis pozycji, etapu bazy, odblokowania/naprawy/raportu i instrukcji; kontynuacja, walidacja i kopia zapasowa. Sprawdzono odświeżenie strony po pierwszym sektorze i wznowienie od drugiego. | Stan pozostałych minigier, pełne zadania, flagi fabularne, tagi, obejrzane dialogi i wybór postaci. Czytelne zgłaszanie błędów zapisu w trakcie rozgrywki. Format Web jest osobny; zapis desktopowy nie jest importowany. |
| Pauza i okna | Wznowienie, ustawienia, powrót z konsoli do hali, zapis i wyjście do menu; Esc zamyka odpowiednie okna. | Zgodność powrotu z ustawień do pauzy i obsługa nowych minigier. Blokada jest obecnie oparta na otwartym oknie, nie na globalnej pauzie drzewa scen. |
| Ustawienia | Osobna głośność muzyki i efektów, zapis w `user://settings.cfg`. | Wybór postaci, procentowe etykiety i pozostałe detale oryginalnego interfejsu. |
| Muzyka | Dwie ścieżki menu, dwie hali i dwie konsoli; playlisty, Ogg Vorbis, start po interakcji użytkownika. | Pozostałe dwie ścieżki hali i muzyka innych minigier/finału; wznowienie muzyki hali od miejsca przerwania, przejścia głośności i ściszanie podczas rozmów. Obecnie powrót do hali rozpoczyna jej playlistę od początku. |
| Efekty dźwiękowe | Pliki oryginalnych efektów są skopiowane; podłączono m.in. kliknięcia, otwieranie okien, blokadę ruchu i sukces konsoli. | Pełne przypisanie efektów do zdarzeń, hover, zamykanie, pisanie, zadania, przedmioty, osiągnięcia oraz dźwięki pozostałych minigier. Sam plik audio w folderze nie oznacza aktywnego efektu. |
| Testy | 46 sprawdzeń regresyjnych i przejście eksportu w Chrome na macOS; sprawdzono też menu w mniejszym oknie, ustawienia i autorów. | Przeniesienie odpowiednich testów całej gry, dalsze scenariusze zapisu i nawigacji, sprawdzenie pełnego ekranu oraz dodatkowych przeglądarek. |

## 3. Nieruszone funkcjonalnie w wersji Web

| Element | Zakres pozostałej pracy / źródło |
| --- | --- |
| Cyber-Elektryk — minigra 1 | Cztery układy, dobór elementów, przeciąganie, walidacja, wskazówki, przejścia i zaliczenie. Oryginał: `Scripts/Adam/`, `Scenes/Adam/`. |
| Wycinarka — minigra 2 | Trzy etapy konturów, współrzędne, powiększanie/przesuwanie, tryb względny, zakończenie i dodatkowe efekty. Oryginał: `Scripts/A_J/`, `Scenes/A_J/`. |
| Robot-przewodnik — minigra 4 | Trzy misje, klocki, drag-and-drop, kompilator pętli i zagnieżdżeń, limity, krokowe i automatyczne wykonanie, błędy i zaliczenie. Oryginał: `Scripts/fasolaaa/Okej.cs` i robotowa część `Scripts/Puzzles/`. |
| Pełne zadania Mareczka, Gerwazego i Johnnego | Rozmowy, odblokowania, naprawy, raporty i ich wpływ na dalszą fabułę. Obecność postaci na mapie nie oznacza działającego zadania. |
| Ogólny system questów, tagów i wydarzeń | Pełne odpowiedniki `QuestManager`, `QuestData`, `TagManager`, `StoryEventHandler`. Obecny stan kilku pól dla Jadwigi nie zastępuje tego systemu. |
| Pełne zakończenie | Warunek naprawy całej fabryki, rozmowa z Prezesem, nagroda i sekwencja końcowa. Oryginał: `Scripts/Main/EndingScreen.cs`, `Scenes/Main/EndingScreen.tscn`. Sama lista autorów jest już dostępna w menu. |
| Powiadomienia | Kompaktowe powiadomienia o zadaniach, przedmiotach i osiągnięciach. Oryginał: `Scripts/Main/NotificationUI.cs`. |
| Konsola debugowania | Oryginał: `Scripts/Main/DebugConsole.cs`. |
| Pozostałe skrypty urządzeń | `Scripts/Main/machines/`, `InstantFix` i inne zachowania poza obsługiwaną trasą. Najpierw ustalić, które są rzeczywiście wykorzystywane w obecnym desktopowym przebiegu. |
| Starsze sceny minigry bazy | `Antywirus`, `BazaDanych`, `WprowadzenieDanych`, `Usuwanie`, `Transitioner` i ich sceny. Nie są częścią aktualnie przeniesionej trójsektorowej konsoli. Przed portem ustalić, czy nadal są potrzebne — nie przenosić automatycznie nieużywanego kodu. |
| Sterowanie dotykowe | Gra obecnie wymaga myszy i klawiatury; brak mobilnego interfejsu sterowania. |
| Pozostałe przeglądarki i platformy | Brak potwierdzonych testów Safari, Firefox, iOS i Android. |
| Publikacja | Brak publicznego wdrożenia i konfiguracji docelowego hostingu. Jest lokalny podgląd i gotowy ZIP do późniejszego wdrożenia. |

## 4. Świadome uproszczenia etapu 1

- Zaczynamy od Jadwigi; nie trzeba wcześniej naprawić elektroniki i wycinarki. Warunek rozpoczęcia jej rozmowy zmieniono w danych kopii Web.
- Wstęp Dyspozytora i pasek celu opisują etap przeglądarkowy. Pełny oryginalny wstęp pozostaje w danych, ale nie jest uruchamiany.
- Pozostałe trzy maszyny oraz inni NPC pokazują informację o niedostępnym jeszcze zakresie. Nie przyznają pozornego zaliczenia.
- Raport Jadwigi kończy ten etap komunikatem. Nie uruchamia finału całej fabryki.
- Skopiowano zasoby potrzebne w tym etapie, a nie całe repozytorium oryginału. W starym projekcie nie zmieniano plików.

## 5. Proponowana kolejność dalszych prac

1. Przenieść robota: czyste reguły i kompilator, następnie UI klocków, trzy misje i testy.
2. Przenieść Cyber-Elektryka i wycinarkę z kompletnymi warunkami zaliczenia.
3. Wprowadzić ogólny stan maszyn, zadań, tagów i flag; rozszerzyć format zapisu oraz obsłużyć migrację istniejącego zapisu etapu 1.
4. Podłączyć wszystkich NPC i oryginalną kolejność fabularną; usunąć komunikaty zastępcze i uproszczony wstęp.
5. Dokończyć portrety, wybór postaci, markery, wizualny stan maszyn, powiadomienia, dźwięki i finał.
6. Przejść całą grę od nowej gry do zakończenia, także z zapisem/wczytaniem na każdym etapie; przetestować dodatkowe przeglądarki i przygotować publikację.

## 6. Potwierdzone wyniki i pliki

- Regresja: **46 sprawdzeń, 0 błędów**. Kod: `tests/regression.gd`.
- Chrome/macOS: menu, rzeczywisty ruch po hali, rozmowa, trzy sektory, powrót i raport zakończone bez błędów konsoli w obserwowanym przebiegu.
- Odświeżenie po sektorze 1: przycisk Kontynuuj odczytuje zapis; ponowne wejście do konsoli otwiera sektor 2.
- Zrzuty eksportu: `docs/menu.png`, `docs/hub.png`, `docs/terminal.png`, `docs/completed.png`.
- Projekt Godota: `project.godot`; instrukcja pracy: `README.md`.
- Eksport: `builds/web/index.html`; paczka: `builds/reboot-web.zip` (około 22 MB).
- Podgląd: `python3 tools/serve.py`, potem `http://127.0.0.1:8060`.

Przy kolejnych zmianach aktualizować ten dokument na podstawie kodu i wykonanych testów. Element trafia do „100%” dopiero po ukończeniu i sprawdzeniu całego zakresu opisanego w jego wierszu.
