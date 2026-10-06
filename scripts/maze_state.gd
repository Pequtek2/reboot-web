class_name MazeState
extends RefCounted

var level: Dictionary
var player: Vector2i
var blocks: Array[Vector2i] = []
var data: Array[Vector2i] = []
var sockets: Array[Vector2i] = []
var has_key = false
var moves = 0
var history: Array = []
var won: bool:
	get:
		if tile(player) != "E" or not data.is_empty(): return false
		for socket in sockets:
			if socket not in blocks: return false
		return true

func _init(definition: Dictionary) -> void:
	level = definition
	for y in level.map.size():
		for x in level.map[y].length():
			var p = Vector2i(x, y)
			match tile(p):
				"S": player = p
				"B": blocks.append(p)
				"D": data.append(p)
				"O": sockets.append(p)

func tile(p: Vector2i) -> String:
	if p.y < 0 or p.y >= level.map.size() or p.x < 0 or p.x >= level.map[p.y].length(): return "#"
	return level.map[p.y][p.x]

func solid(p: Vector2i) -> bool:
	return tile(p) in ["#", "X"] or (tile(p) == "G" and not has_key)

func move(direction: Vector2i) -> String:
	if won or abs(direction.x) + abs(direction.y) != 1: return ""
	var next = player + direction
	if solid(next): return "Brama zamknięta. Odszukaj złoty klucz." if tile(next) == "G" else "Przejście zablokowane."
	var pushing = next in blocks
	var beyond = next + direction
	if pushing and (solid(beyond) or beyond in blocks or tile(beyond) in ["D", "K", "E"]):
		return "Brak miejsca na blok. Podejdź z innej strony."
	history.append([player, blocks.duplicate(), data.duplicate(), has_key])
	if pushing:
		blocks.erase(next)
		blocks.append(beyond)
	player = next
	moves += 1
	var collected = next in data
	data.erase(next)
	if tile(next) == "K": has_key = true
	if won: return "Integralność potwierdzona. Sektor odzyskany!"
	if tile(next) == "E": return "Brakuje danych lub bloków w oznaczonych gniazdach."
	if collected: return "Fragment odzyskany."
	if pushing: return "Przesunięto blok indeksu."
	return "Pakiet w drodze..."

func undo() -> void:
	if history.is_empty() or won: return
	var previous = history.pop_back()
	player = previous[0]
	blocks.assign(previous[1])
	data.assign(previous[2])
	has_key = previous[3]
	moves -= 1
