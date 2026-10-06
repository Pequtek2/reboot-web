extends Control

var time = 0.0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func tile(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(Vector2(160, 480) + Vector2(x, y) * 8, Vector2(w, h) * 8), color)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), PixelUI.INK)
	for x in range(0, int(size.x), 48): draw_line(Vector2(x, 0), Vector2(x, size.y), Color("1c2c38"))
	for y in range(0, int(size.y), 48): draw_line(Vector2(0, y), Vector2(size.x, y), Color("1c2c38"))
	for i in 36:
		var p = Vector2(fposmod(i * 173.0 + time * (4 + i % 4), size.x + 16) - 8,
			fposmod(i * 97.0 - time * (9 + i % 7), size.y + 16) - 8).round()
		var color = PixelUI.GOLD if i % 4 == 0 else PixelUI.ACCENT
		color.a = 0.12
		draw_rect(Rect2(p, Vector2(4, 4)), color)
	tile(0, 6, 56, 18, Color("314857"))
	tile(5, -3, 7, 9, Color("314857"))
	tile(17, 0, 7, 6, Color("314857"))
	tile(1, 5, 55, 1, PixelUI.EDGE)
	tile(2, 24, 57, 2, PixelUI.EDGE)
	for i in 5:
		tile(4 + i * 10, 10, 6, 7, PixelUI.INK)
		tile(5 + i * 10, 11, 4, 2, PixelUI.GOLD if i == 3 else PixelUI.ACCENT)
	tile(9, 20, 2, 4, PixelUI.GOLD)
	tile(44, 19, 8, 5, PixelUI.INK)
	for chimney in 2:
		for puff in 5:
			var phase = fposmod(time * 0.12 + puff / 5.0 + chimney * 0.3, 1)
			var smoke = PixelUI.EDGE
			smoke.a = (1 - phase) * 0.35
			var origin = Vector2(160, 480) + Vector2((60 if chimney == 0 else 164) + round(phase * 6) * 4,
				(-24 if chimney == 0 else 0) - round(phase * 26) * 4)
			draw_rect(Rect2(origin, Vector2(16 + floor(phase * 3) * 8, 8)), smoke)
