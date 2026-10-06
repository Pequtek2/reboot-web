extends Node

const HUB = "res://scenes/Main/FactoryHub.tscn"
var save_path = "user://progress-v1.json"
var state: Dictionary
var load_error = ""
var return_position = false
var player: CharacterBody2D
var database: Dictionary

func _ready() -> void:
	database = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogues.json"))
	reset_state()
	get_tree().auto_accept_quit = false

func reset_state() -> void:
	state = {"version": 1, "levels": 0, "unlocked": false, "fixed": false,
		"reported": false, "tutorial": false, "intro": false, "tags": [],
		"position": [259.0, 188.0], "has_position": false}
	return_position = false

func new_game() -> void:
	reset_state()
	save_game()
	change_scene(HUB)

func has_save() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path + ".bak")

func validate(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 1: return false
	if not data.get("levels") is float and not data.get("levels") is int: return false
	if data.levels != int(data.levels) or data.levels < 0 or data.levels > 3: return false
	for key in ["unlocked", "fixed", "reported", "tutorial", "intro", "has_position"]:
		if not data.get(key) is bool: return false
	if not data.get("tags") is Array or not data.get("position") is Array: return false
	if data.position.size() != 2: return false
	for n in data.position:
		if (not n is float and not n is int) or not is_finite(n) or abs(n) > 10000: return false
	if data.fixed != (data.levels == 3) or (data.reported and not data.fixed): return false
	return true

func load_game() -> bool:
	for path in [save_path, save_path + ".bak"]:
		if not FileAccess.file_exists(path): continue
		var data = parse_save(path)
		if validate(data):
			state = data
			state.levels = int(state.levels)
			return_position = state.has_position
			load_error = ""
			return true
	load_error = "Nie udało się odczytać zapisu. Możesz rozpocząć nową grę."
	return false

func parse_save(path: String) -> Variant:
	var json = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK: return null
	return json.data

func capture_position() -> void:
	if is_instance_valid(player):
		state.position = [player.global_position.x, player.global_position.y]
		state.has_position = true

func save_game() -> bool:
	capture_position()
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		load_error = "Zapis jest niedostępny w tej przeglądarce."
		return false
	file.store_string(JSON.stringify(state))
	file.close()
	if FileAccess.file_exists(save_path):
		var previous = parse_save(save_path)
		if validate(previous):
			DirAccess.copy_absolute(save_path, save_path + ".bak")
	var error = DirAccess.rename_absolute(save_path + ".tmp", save_path)
	load_error = "" if error == OK else "Nie udało się zapisać postępu."
	return error == OK

func change_scene(path: String) -> void:
	Overlay.close()
	var error = get_tree().change_scene_to_file(path)
	if error != OK: Overlay.message("Nie udało się otworzyć sceny", error_string(error))

func enter_maze() -> void:
	save_game()
	return_position = true
	change_scene("res://scenes/maze.tscn")

func return_to_hub() -> void:
	save_game()
	return_position = state.has_position
	change_scene(HUB)

func complete_level(index: int) -> void:
	state.levels = maxi(state.levels, index + 1)
	state.fixed = state.levels == 3
	save_game()

func goal() -> String:
	if state.reported: return "Baza działa! Ukończono pierwszy etap wersji Web."
	if state.fixed: return "Wróć do Jadwigi i zdaj raport."
	if state.unlocked: return "Uruchom bazę danych obok Jadwigi. [E]"
	return "Porozmawiaj z Jadwigą przy serwerach. [E]"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if get_tree().current_scene and get_tree().current_scene.scene_file_path != "res://scenes/menu.tscn": save_game()
		get_tree().quit()
