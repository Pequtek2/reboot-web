extends Control

func _ready() -> void:
	theme = PixelUI.theme()
	add_child(preload("res://scripts/backdrop.gd").new())
	PixelUI.rect(PixelUI.label(self, "SKNI / FABRYKA W REMONCIE", 20, PixelUI.GOLD), 160, 106, 600, 32)
	PixelUI.rect(PixelUI.label(self, "Re:boot", 104), 156, 156, 600, 126)
	PixelUI.rect(PixelUI.paragraph(self, "Produkcja stanęła.\nCzas przywrócić fabrykę do życia.", 30), 164, 304, 530, 90)
	PixelUI.rect(PixelUI.label(self, "POROZMAWIAJ. NAPRAW. URUCHOM.", 20, PixelUI.MUTED), 164, 406, 560, 36)
	var card = PixelUI.panel(self, Rect2(810, 100, 430, 568))
	PixelUI.rect(PixelUI.label(card, "GOTOWY DO PRACY?", 28, PixelUI.GOLD), 28, 24, 374, 42)
	PixelUI.rect(PixelUI.paragraph(card, "Wersja Web · etap 1\nHala i konsola serwisowa Jadwigi", 22), 28, 78, 374, 68)
	var buttons = VBoxContainer.new()
	card.add_child(buttons)
	PixelUI.rect(buttons, 28, 168, 374, 370)
	var continue_button = PixelUI.button(buttons, "Kontynuuj", continue_game, true)
	continue_button.disabled = not Game.has_save()
	var new_button = PixelUI.button(buttons, "Nowa gra", new_game, not Game.has_save())
	PixelUI.button(buttons, "Ustawienia", Overlay.settings)
	PixelUI.button(buttons, "Pełny ekran", fullscreen)
	PixelUI.button(buttons, "Twórcy", Overlay.credits)
	PixelUI.rect(PixelUI.label(self, "ETAP 1 / 3 SEKTORY DO ODZYSKANIA", 18, PixelUI.ACCENT), 160, 712, 780, 30)
	PixelUI.rect(PixelUI.label(self, "Mysz + klawiatura  ·  Postęp zapisuje się lokalnie", 18, PixelUI.MUTED), 160, 746, 900, 26)
	(continue_button if Game.has_save() else new_button).grab_focus()
	Audio.play_music("menu")

func new_game() -> void:
	if Game.has_save():
		Overlay.confirm("NOWA GRA", "Rozpocząć od nowa?\nObecny zapis zostanie zastąpiony.", Game.new_game)
	else: Game.new_game()

func continue_game() -> void:
	if Game.load_game(): Game.change_scene(Game.HUB)
	else: Overlay.message("ZAPIS GRY", Game.load_error)

func fullscreen() -> void:
	var mode = DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(mode)
