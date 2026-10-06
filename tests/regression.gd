extends Node

const SOLUTIONS = ["DDDDRRRRRRUURRUUDDDD", "DDDDRRUURRDDRRUUUURR", "DDRDRUDDLDDLRRURRURRUURRDDRRUDLLUULLUURRRR"]
const DIRECTIONS = {"U": Vector2i.UP, "D": Vector2i.DOWN, "L": Vector2i.LEFT, "R": Vector2i.RIGHT}
var checks = 0
var failures = 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else: print("PASS: " + description)

func frames(count: int = 4) -> void:
	for i in count: await get_tree().process_frame

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	Game.save_path = "user://regression-test.json"
	get_tree().current_scene = null # Keep this runner alive across real scene changes.
	Game.reset_state()
	var levels = JSON.parse_string(FileAccess.get_file_as_string("res://data/maze_levels.json"))
	for i in 3:
		var state = MazeState.new(levels[i])
		var start = state.player
		state.move(Vector2i.UP)
		check(state.player == start and state.moves == 0, "sector %d walls block movement" % i)
		state.move(Vector2i.RIGHT)
		state.undo()
		check(state.player == start and state.moves == 0, "sector %d undo restores state" % i)
		state.move(Vector2i(2, 0))
		check(state.moves == 0, "sector %d rejects non-adjacent clicks" % i)
		for step in SOLUTIONS[i]: state.move(DIRECTIONS[step])
		check(state.won, "sector %d original solution works" % i)
	var gate = MazeState.new({"map": ["#######", "#SG.DE#", "#K#####", "#######"]})
	gate.move(Vector2i.RIGHT)
	check(gate.moves == 0, "locked gate requires a key")
	gate.move(Vector2i.DOWN)
	check(gate.has_key, "key can be collected")
	gate.undo()
	check(not gate.has_key, "undo restores key")
	var block = MazeState.new({"map": ["#######", "#SBODE#", "#######"]})
	block.move(Vector2i.RIGHT)
	check(Vector2i(3, 1) in block.blocks, "block can be pushed onto socket")
	block.undo()
	check(Vector2i(2, 1) in block.blocks, "undo restores block")
	var exit_test = MazeState.new({"map": ["#######", "#SED.O#", "#..B..#", "#######"]})
	exit_test.move(Vector2i.RIGHT)
	check(not exit_test.won, "exit cannot bypass data and sockets")
	Game.state.intro = true
	Game.change_scene(Game.HUB)
	await frames(12)
	var hub = get_tree().current_scene
	check(is_instance_valid(Game.player) and Game.player.grid != null, "original factory and pathfinding load")
	Game.player.move_to(hub.get_node("NPC3").global_position + Vector2(0, 32))
	check(not Game.player.path.is_empty(), "Jadwiga is reachable from player spawn")
	Game.player.path.clear()
	hub.interact(hub.get_node("NPC3"))
	check(Overlay.is_open and not hub.dialogue_lines.is_empty(), "talking to Jadwiga starts dialogue")
	while not hub.dialogue_lines.is_empty():
		hub.dialogue_label.visible_ratio = 1
		hub.next_line()
	check(Game.state.unlocked and not Overlay.is_open, "dialogue unlocks database")
	Game.enter_maze()
	await frames(8)
	var maze = get_tree().current_scene
	check(Overlay.is_open, "first visit opens tutorial")
	maze.move(Vector2i.RIGHT)
	check(maze.state.moves == 0, "tutorial blocks board input")
	Overlay.panel.find_children("*", "Button", true, false)[0].pressed.emit()
	check(Game.state.tutorial and not Overlay.is_open, "tutorial preference persists")
	for i in 3:
		check(maze.level_index == i, "UI sector progression %d" % i)
		maze.hint()
		var start: Vector2i = maze.state.player
		maze.move(Vector2i.RIGHT)
		maze.build_level()
		check(maze.state.player == start and maze.state.moves == 0, "hint blocks movement and restart")
		Overlay.close()
		for step in SOLUTIONS[i]: maze.move(DIRECTIONS[step])
		check(maze.state.won and Game.state.levels == i + 1, "UI completion saves sector %d" % i)
		check(Game.state.fixed == (i == 2), "repair requires all sectors")
		check(Game.load_game() and Game.state.levels == i + 1, "sector save/load round trip")
		Overlay.panel.find_children("*", "Button", true, false)[0].pressed.emit()
		await frames(8)
		if i < 2: maze = get_tree().current_scene
	check(get_tree().current_scene.scene_file_path == Game.HUB, "victory returns to factory")
	hub = get_tree().current_scene
	hub.interact(hub.get_node("NPC3"))
	while not hub.dialogue_lines.is_empty():
		hub.dialogue_label.visible_ratio = 1
		hub.next_line()
	check(Game.state.reported, "report completes Jadwiga quest")
	Overlay.close()
	check(Game.save_game() and Game.load_game(), "finished game loads")
	var file = FileAccess.open(Game.save_path, FileAccess.WRITE)
	file.store_string("{broken json")
	file.close()
	check(Game.load_game() and Game.state.fixed, "corrupt save recovers backup")
	var bad = Game.state.duplicate(true)
	bad.levels = -1
	check(not Game.validate(bad), "invalid save progress rejected")
	bad = Game.state.duplicate(true)
	bad.position = ["bad", 0]
	check(not Game.validate(bad), "invalid save position rejected")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Game.save_path + suffix)
	print("REGRESSION: %d checks, %d failures" % [checks, failures])
	Audio.music.stop()
	Audio.effects.stop()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit.call_deferred(1 if failures else 0)
