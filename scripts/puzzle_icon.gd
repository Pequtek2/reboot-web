class_name PuzzleIcon
extends Control

static var pixels: Dictionary
var symbol = "Packet"

static func paint(canvas: CanvasItem, kind: String, bounds: Rect2) -> void:
	if pixels.is_empty(): pixels = JSON.parse_string(FileAccess.get_file_as_string("res://data/puzzle_icons.json"))
	var step = maxf(1, floor(minf(bounds.size.x, bounds.size.y) / 16))
	var origin = (bounds.get_center() - Vector2.ONE * 8 * step).floor()
	var tint = PixelUI.ACCENT
	if kind in ["Data", "Block", "Key", "Station"]: tint = PixelUI.GOLD
	if kind in ["Gate", "Hazard"]: tint = Color("f08d85")
	var rows: Array = pixels[kind]
	for y in rows.size():
		var x = 0
		while x < rows[y].length():
			var pixel: String = rows[y][x]
			var start = x
			x += 1
			while x < rows[y].length() and rows[y][x] == pixel: x += 1
			if pixel == ".": continue
			var color = tint
			if pixel == "o": color = PixelUI.INK
			elif pixel == ":": color = tint.darkened(0.55)
			elif pixel == "+": color = PixelUI.GOLD
			canvas.draw_rect(Rect2(origin + Vector2(start, y) * step, Vector2(x - start, 1) * step), color)

func _draw() -> void:
	paint(self, symbol, Rect2(Vector2.ZERO, size))
