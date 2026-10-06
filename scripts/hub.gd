extends Node2D

var actors = []
var hud: CanvasLayer
var goal_label: Label
var labels: Array[PanelContainer] = []
var dialogue_lines: Array = []
var dialogue_index = 0
var dialogue_label: Label
var dialogue_name: Label
var auto_save = 0.0
var nearest: Node2D

func _ready() -> void:
	Audio.play_music("factory")
	hud = CanvasLayer.new()
	hud.layer = 10
	add_child(hud)
	var root = Control.new()
	root.theme = PixelUI.theme()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel = PixelUI.panel(root, Rect2(24, 24, 700, 90))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PixelUI.rect(PixelUI.label(panel, "OBECNY CEL / WERSJA WEB", 16, PixelUI.GOLD), 16, 10, 660, 24)
	goal_label = PixelUI.label(panel, "", 24)
	PixelUI.rect(goal_label, 16, 38, 666, 40)
	PixelUI.rect(PixelUI.button(root, "J  Dziennik", journal), 24, 704, 210, 52)
	PixelUI.rect(PixelUI.button(root, "K  Sterowanie", controls), 246, 704, 232, 52)
	PixelUI.rect(PixelUI.button(root, "Esc  Pauza", Overlay.pause), 1160, 24, 216, 52)
	var info = PixelUI.label(root, "Kliknij podłogę, aby się przemieścić", 20, PixelUI.MUTED)
	PixelUI.rect(info, 830, 718, 546, 32)
	actors = [
		{"node": $NPC, "name": "Mareczek", "id": "mareczek"},
		{"node": $NPC2, "name": "Gerwazy", "id": "negan"},
		{"node": $NPC3, "name": "Jadwiga", "id": "dorotka"},
		{"node": $NPC4, "name": "Johnny", "id": "muciak"},
		{"node": $NPC5, "name": "Prezes", "id": "prezes"},
		{"node": $Machine_1, "name": "Układy elektroniczne", "id": "machine_1"},
		{"node": $Machine_2, "name": "Wycinarka", "id": "machine_2"},
		{"node": $Machine_3, "name": "Baza danych", "id": "machine_3"},
		{"node": $Machine_4, "name": "Robot-przewodnik", "id": "machine_4"}]
	for actor in actors:
		for child in actor.node.get_children():
			if child is Label or child.name in ["QuestMarker", "QuestMarker2", "IconE"]: child.hide()
		var tag = PanelContainer.new()
		tag.theme = PixelUI.theme()
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag.add_theme_stylebox_override("panel", PixelUI.box(Color("152330eb"), PixelUI.EDGE, 5))
		hud.add_child(tag)
		var label = PixelUI.label(tag, actor.name, 18, PixelUI.ACCENT if actor.id in ["dorotka", "machine_3"] else PixelUI.TEXT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labels.append(tag)
	start_intro.call_deferred()

func start_intro() -> void:
	if not Game.state.intro:
		play_lines([
			{"name": "Dyspozytor", "text": "Witaj w fabryce! W tej wersji przeglądarkowej pomożesz Jadwidze odzyskać bazę danych. Pozostałe trzy naprawy dołączą w kolejnych etapach."},
			{"name": "Dyspozytor", "text": "Klikaj podłogę, aby się poruszać. Jadwiga czeka przy serwerach w górnej części hali. Podejdź i naciśnij E. Dziennik otworzysz klawiszem J, a pomoc klawiszem K."}])
		Game.state.intro = true

func _process(delta: float) -> void:
	goal_label.text = Game.goal()
	if is_instance_valid(dialogue_label) and Overlay.is_open:
		dialogue_label.visible_ratio = minf(1, dialogue_label.visible_ratio + delta * 1.5)
	if not is_instance_valid(Game.player): return
	nearest = null
	var best = INF
	for actor in actors:
		var distance = Game.player.global_position.distance_to(actor.node.global_position)
		var in_range = distance < 76
		if in_range and distance < best:
			best = distance
			nearest = actor.node
	for i in actors.size():
		var actor: Dictionary = actors[i]
		var is_near = nearest == actor.node
		var tag = labels[i]
		var title = actor.name
		if actor.id == "machine_3" and Game.state.fixed: title += " · naprawiona"
		elif is_near: title += " · E"
		tag.get_child(0).text = title
		tag.reset_size()
		var offset = Vector2(0, -65) if actor.id.begins_with("machine") else Vector2(0, -42)
		var point: Vector2 = actor.node.get_global_transform_with_canvas() * offset
		tag.position = (point - Vector2(tag.size.x / 2, tag.size.y)).round()
		tag.visible = not Overlay.is_open and point.x > 0 and point.x < 1400 and point.y > 125 and point.y < 675
		if not actor.id.begins_with("machine"):
			var sprite: AnimatedSprite2D = actor.node.find_children("*", "AnimatedSprite2D", false, false)[0]
			var direction = Game.player.global_position - actor.node.global_position
			if is_near:
				if abs(direction.x) > abs(direction.y): sprite.play("idle_right" if direction.x > 0 else "idle_left")
				else: sprite.play("idle_down" if direction.y > 0 else "idle_up")
	auto_save += delta
	if auto_save > 5 and not Overlay.is_open:
		auto_save = 0
		Game.save_game()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if Overlay.is_open:
		if not dialogue_lines.is_empty() and event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
			next_line()
			get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_ESCAPE: Overlay.pause()
		KEY_J: journal()
		KEY_K: controls()
		KEY_E:
			if nearest: interact(nearest)
		_: return
	get_viewport().set_input_as_handled()

func interact(actor: Node2D) -> void:
	if actor == $NPC3:
		for branch in Game.database.dorotka:
			if conditions(branch.get("requires", "")):
				play_lines(branch.lines)
				return
	elif actor == $Machine_3:
		if Game.state.fixed: Overlay.message("BAZA DZIAŁA", "Wszystkie sektory zostały odzyskane. Wróć do Jadwigi i zdaj raport.")
		elif Game.state.unlocked: Overlay.confirm("KONSOLA SERWISOWA", "Odzyskaj dane, odbuduj indeksy i napraw rdzeń bazy. Uruchomić konsolę?", Game.enter_maze)
		else: Overlay.message("BRAK ZLECENIA", "Porozmawiaj najpierw z Jadwigą obok serwerów. [E]")
	else:
		Overlay.message("HALA FABRYCZNA", "To stanowisko dołączy w kolejnym etapie wersji Web.\n\nTeraz pomóż Jadwidze przy bazie danych — czeka przy serwerach w górnej części hali.")

func conditions(requirements: String) -> bool:
	for condition in requirements.split(",", false):
		match condition.strip_edges():
			"quest_done:main_quest_3":
				if not Game.state.reported: return false
			"quest_active:main_quest_3":
				if not Game.state.unlocked or Game.state.reported: return false
			"machine_fixed:machine_3":
				if not Game.state.fixed: return false
			_: return false
	return true

func play_lines(lines: Array) -> void:
	dialogue_lines = lines
	dialogue_index = 0
	var panel = Overlay.open_panel("ROZMOWA", Vector2(1040, 370))
	dialogue_name = PixelUI.label(panel, "", 30, PixelUI.ACCENT)
	PixelUI.rect(dialogue_name, 28, 78, 984, 42)
	dialogue_label = PixelUI.paragraph(panel, "", 28)
	PixelUI.rect(dialogue_label, 28, 132, 984, 146)
	var button = PixelUI.button(panel, "Dalej [E / Enter]", next_line, true)
	PixelUI.rect(button, 660, 290, 352, 52)
	button.grab_focus()
	Overlay.on_escape = Callable()
	Overlay.trap_focus()
	show_line()

func show_line() -> void:
	var line: Dictionary = dialogue_lines[dialogue_index]
	dialogue_name.text = line.get("name", "")
	dialogue_label.text = line.get("text", "")
	dialogue_label.visible_ratio = 0
	for command in line.get("command", "").split(",", false):
		match command.strip_edges():
			"unlock_machine:machine_3", "start_quest:main_quest_3": Game.state.unlocked = true
			"finish_quest:main_quest_3": Game.state.reported = true

func next_line() -> void:
	if dialogue_label.visible_ratio < 1:
		dialogue_label.visible_ratio = 1
		return
	dialogue_index += 1
	if dialogue_index < dialogue_lines.size(): show_line()
	else:
		dialogue_lines = []
		dialogue_label = null
		Overlay.close()
		Game.save_game()
		if Game.state.reported:
			Overlay.message("PIERWSZA NAPRAWA ZA TOBĄ", "Baza danych znów działa! Ukończono pierwszy etap wersji przeglądarkowej.\n\nPostęp został zapisany. Układy, wycinarka i robot pozostają do przeniesienia.")

func journal() -> void:
	Overlay.message("DZIENNIK / BAZA KAPUT", "Jadwiga potrzebuje pomocy przy naprawie bazy danych.\n\n" + Game.goal() + "\n\nOdzyskane sektory: %d / 3" % Game.state.levels)

func controls() -> void:
	Overlay.message("STEROWANIE", "Kliknięcie podłogi — ruch\nE — rozmowa lub uruchomienie maszyny\nJ — dziennik   /   K — pomoc   /   Esc — pauza\n\nW konsoli: WASD lub strzałki, Z — cofnij, R — restart. Możesz też klikać sąsiednie pola.")
