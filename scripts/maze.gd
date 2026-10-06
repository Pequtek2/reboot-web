extends Control

var state: MazeState
var level_index = 0
var levels: Array
var board: Control
var stats: Label
var feedback: Label
var complete = false
var frame: Panel

func _ready() -> void:
	theme = PixelUI.theme()
	levels = JSON.parse_string(FileAccess.get_file_as_string("res://data/maze_levels.json"))
	level_index = mini(Game.state.levels, 2)
	Audio.play_music("terminal")
	build_level()
	if not Game.state.tutorial: tutorial()

func build_level() -> void:
	if Overlay.is_open: return
	if is_instance_valid(frame):
		remove_child(frame)
		frame.queue_free()
	complete = false
	state = MazeState.new(levels[level_index])
	frame = PixelUI.panel(self, Rect2(20, 20, 1360, 740))
	frame.add_theme_stylebox_override("panel", PixelUI.box(Color("0b1914"), Color("376455")))
	PixelUI.rect(PixelUI.label(frame, "BAZA DANYCH / ODZYSKIWANIE", 32, PixelUI.ACCENT), 24, 20, 1060, 42)
	PixelUI.rect(PixelUI.label(frame, "SEKTOR 0%d / 03    >    %s" % [level_index + 1, state.level.title], 24, PixelUI.GOLD), 24, 74, 1100, 40)
	PixelUI.rect(PixelUI.button(frame, "Esc  Pauza", Overlay.pause), 1110, 20, 224, 52)
	feedback = PixelUI.paragraph(frame, state.level.brief, 24)
	feedback.add_theme_color_override("font_color", PixelUI.ACCENT)
	PixelUI.rect(feedback, 24, 123, 1310, 60)
	board = preload("res://scripts/maze_board.gd").new()
	board.state = state
	frame.add_child(board)
	PixelUI.rect(board, 24, 190, 834, 420)
	board.cell_clicked.connect(func(cell): move(cell - state.player))
	PixelUI.rect(PixelUI.label(frame, "STEROWANIE I SYMBOLE", 24, PixelUI.ACCENT), 890, 196, 420, 34)
	var legends = [["Packet", "Twój pakiet — nim poruszasz"], ["Data", "Chip — zbierz wszystkie"],
		["Exit", "Wyjście — po wykonaniu celu"], ["Block", "Skrzynia — możesz ją pchać"],
		["Socket", "Gniazdo — ustaw tu skrzynię"], ["Key", "Klucz — otwiera bramę"],
		["Gate", "Brama — wymaga klucza"], ["Hazard", "Awaria — omijaj to pole"]]
	for i in legends.size():
		var icon = PuzzleIcon.new()
		icon.symbol = legends[i][0]
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		frame.add_child(icon)
		PixelUI.rect(icon, 890, 238 + i * 35, 32, 32)
		PixelUI.rect(PixelUI.label(frame, legends[i][1], 21), 934, 238 + i * 35, 400, 34)
	PixelUI.rect(PixelUI.button(frame, "Jak grać?", tutorial), 890, 550, 202, 52)
	PixelUI.rect(PixelUI.button(frame, "Podpowiedź", hint), 1108, 550, 202, 52)
	stats = PixelUI.label(frame, "", 22, PixelUI.ACCENT)
	PixelUI.rect(stats, 24, 618, 840, 32)
	PixelUI.rect(PixelUI.label(frame, "Ruch: strzałki / WASD   |   Z: cofnij   |   R: restart", 20, PixelUI.MUTED), 24, 664, 840, 40)
	PixelUI.rect(PixelUI.button(frame, "Cofnij [Z]", undo), 890, 636, 202, 52)
	PixelUI.rect(PixelUI.button(frame, "Restart [R]", build_level), 1108, 636, 202, 52)
	update_board()

func move(direction: Vector2i) -> void:
	if complete or Overlay.is_open: return
	var before = state.moves
	var message = state.move(direction)
	if message:
		feedback.text = message
		feedback.add_theme_color_override("font_color", Color("f08d85") if before == state.moves else PixelUI.ACCENT)
		if before == state.moves: Audio.cue("error")
	update_board()
	if state.won:
		complete = true
		Game.complete_level(level_index)
		Audio.cue("success")
		Overlay.message("BAZA PRZYWRÓCONA" if level_index == 2 else "SEKTOR ODZYSKANY",
			"Wszystkie trzy sektory są sprawne. Wróć do Jadwigi i zdaj raport." if level_index == 2 else "Dane kompletne, indeksy poprawne.\nRuchy: %d. Postęp zapisany." % state.moves,
			"Wróć do fabryki" if level_index == 2 else "Następny sektor", advance)
		Overlay.on_escape = Callable()

func advance() -> void:
	if not complete: return
	if level_index == 2: Game.return_to_hub()
	else:
		level_index += 1
		build_level()

func undo() -> void:
	if complete or Overlay.is_open: return
	state.undo()
	feedback.text = "Cofnięto ruch." if state.moves else "Początek sektora."
	feedback.add_theme_color_override("font_color", PixelUI.ACCENT)
	update_board()

func update_board() -> void:
	var filled = 0
	for socket in state.sockets:
		if socket in state.blocks: filled += 1
	stats.text = "DANE: %d do zebrania    GNIAZDA: %d/%d    RUCHY: %d" % [state.data.size(), filled, state.sockets.size(), state.moves]
	board.queue_redraw()

func tutorial() -> void:
	Overlay.message("JAK GRAĆ / KONSOLA SERWISOWA",
		"Przesuwasz pakiet po labiryncie sektorów. Zbierz wszystkie chipy i dotrzyj do wyjścia ze strzałką.\n\nSkrzynie pchaj na gniazda. Klucz otwiera bramę. Omijaj uszkodzone pola. Skrzyń nie można ciągnąć.\n\nWASD / strzałki / klik sąsiedniego pola — ruch\nZ — cofnij ruch   /   R — zacznij sektor od nowa", "Rozumiem", func():
			Game.state.tutorial = true
			Game.save_game())

func hint() -> void:
	Overlay.message("PODPOWIEDŹ / SEKTOR %d" % (level_index + 1), state.level.brief + "\n\n" + state.level.hint)

func _input(event: InputEvent) -> void:
	if Overlay.is_open or complete or not event is InputEventKey or not event.pressed or event.echo: return
	var key = event.physical_keycode if event.physical_keycode else event.keycode
	match key:
		KEY_W, KEY_UP: move(Vector2i.UP)
		KEY_S, KEY_DOWN: move(Vector2i.DOWN)
		KEY_A, KEY_LEFT: move(Vector2i.LEFT)
		KEY_D, KEY_RIGHT: move(Vector2i.RIGHT)
		KEY_Z: undo()
		KEY_R: build_level()
		KEY_ESCAPE: Overlay.pause()
		_: return
	get_viewport().set_input_as_handled()
