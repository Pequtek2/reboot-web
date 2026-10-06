extends Control

signal cell_clicked(cell: Vector2i)
var state: MazeState
var cell_size: float:
	get: return floor(minf(size.x / state.level.map[0].length(), size.y / state.level.map.size()))
var origin: Vector2:
	get: return ((size - Vector2(state.level.map[0].length(), state.level.map.size()) * cell_size) / 2).floor()

func _ready() -> void:
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	resized.connect(queue_redraw)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not Overlay.is_open:
		cell_clicked.emit(Vector2i(((event.position - origin) / cell_size).floor()))
		accept_event()

func _draw() -> void:
	if not state: return
	var edge = Color("376455")
	for y in state.level.map.size():
		for x in state.level.map[y].length():
			var p = Vector2i(x, y)
			var tile = state.tile(p)
			var r = Rect2(origin + Vector2(x, y) * cell_size + Vector2.ONE * 2, Vector2.ONE * (cell_size - 4))
			draw_rect(r, edge.darkened(0.25) if tile == "#" else Color("10251e"))
			if tile == "#":
				draw_line(r.position, r.position + Vector2(r.size.x, 0), edge, 2)
				draw_line(r.position + Vector2(0, r.size.y - 5), r.end - Vector2(0, 5), edge.darkened(0.5), 3)
				draw_rect(Rect2(r.position + Vector2.ONE * 6, Vector2(4, 4)), edge)
				continue
			draw_rect(r, edge.darkened(0.45), false, 1)
			var symbol = ""
			match tile:
				"D": symbol = "Data" if p in state.data else ""
				"K": symbol = "Key" if not state.has_key else ""
				"E": symbol = "Exit"
				"O": symbol = "Socket"
				"X": symbol = "Hazard"
				"G": symbol = "OpenGate" if state.has_key else "Gate"
			if tile == "E": draw_rect(r.grow(-3), PixelUI.ACCENT.darkened(0.8))
			if p in state.blocks:
				if p in state.sockets: draw_rect(r.grow(-2), PixelUI.ACCENT, false, 3)
				symbol = "Block"
			if symbol: PuzzleIcon.paint(self, symbol, r.grow(-1))
	var center = origin + Vector2(state.player) * cell_size + Vector2.ONE * cell_size / 2
	PuzzleIcon.paint(self, "Packet", Rect2(center - Vector2.ONE * 16, Vector2.ONE * 32))
