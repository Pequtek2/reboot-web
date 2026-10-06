extends CharacterBody2D

var grid: AStarGrid2D
var tilemap: TileMapLayer
var selector: Sprite2D
var path: Array[Vector2] = []
var last_anim = "idle_down"
var hidden_walls: Array[Sprite2D] = []
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Game.player = self
	tilemap = get_tree().current_scene.get_node("TileMapLayer")
	selector = get_tree().current_scene.get_node("TileSelector")
	if Game.return_position:
		global_position = Vector2(Game.state.position[0], Game.state.position[1])
		Game.return_position = false
	setup_grid.call_deferred()

func _exit_tree() -> void:
	if Game.player == self: Game.player = null

func setup_grid() -> void:
	grid = AStarGrid2D.new()
	grid.region = tilemap.get_used_rect()
	grid.cell_size = tilemap.tile_set.tile_size
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	for x in range(grid.region.position.x, grid.region.end.x):
		for y in range(grid.region.position.y, grid.region.end.y):
			var p = Vector2i(x, y)
			var data = tilemap.get_cell_tile_data(p)
			grid.set_point_solid(p, data == null or data.get_custom_data("is_wall"))
	# Reject stale saved positions which are outside the authored walkable map.
	var start = tilemap.local_to_map(tilemap.to_local(global_position))
	if not grid.is_in_boundsv(start) or grid.is_point_solid(start): global_position = Vector2(259, 188)

func move_to(target: Vector2) -> void:
	if grid == null or Overlay.is_open: return
	var start = tilemap.local_to_map(tilemap.to_local(global_position))
	var end = tilemap.local_to_map(tilemap.to_local(target))
	if not grid.is_in_boundsv(start) or not grid.is_in_boundsv(end): return
	if grid.is_point_solid(end):
		var queue = [end]
		var seen = {end: true}
		var tries = 0
		while not queue.is_empty() and tries < 100:
			var current: Vector2i = queue.pop_front()
			tries += 1
			if not grid.is_point_solid(current):
				end = current
				break
			for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var n: Vector2i = current + direction
				if grid.is_in_boundsv(n) and not seen.has(n):
					seen[n] = true
					queue.append(n)
	if grid.is_point_solid(end): return
	path.clear()
	for p in grid.get_id_path(start, end): path.append(tilemap.to_global(tilemap.map_to_local(p)))
	if not path.is_empty(): path.pop_front()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		move_to(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if Overlay.is_open:
		path.clear()
		velocity = Vector2.ZERO
	elif not path.is_empty():
		var distance = global_position.distance_to(path[0])
		if distance <= 200 * delta:
			global_position = path.pop_front()
			velocity = Vector2.ZERO
		else:
			velocity = global_position.direction_to(path[0]) * 200
			move_and_slide()
	else: velocity = Vector2.ZERO
	animate()
	update_walls()
	var cell = tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))
	selector.visible = not Overlay.is_open and tilemap.get_cell_source_id(cell) != -1
	selector.global_position = tilemap.to_global(tilemap.map_to_local(cell))

func animate() -> void:
	var anim = last_anim.replace("walk_", "idle_")
	if velocity.length() > 0.1:
		if velocity.x > 0: anim = "walk_down" if velocity.y > 0 else "walk_right"
		else: anim = "walk_left" if velocity.y > 0 else "walk_up"
	if sprite.sprite_frames.has_animation(anim): sprite.play(anim)
	last_anim = anim

func update_walls() -> void:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position + Vector2(0, -30)
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_areas = true
	var next: Array[Sprite2D] = []
	for hit in get_world_2d().direct_space_state.intersect_point(query, 32):
		var wall = hit.collider.get_parent()
		if wall.name.begins_with("Wall") and wall.has_node("Sprite2D"):
			var image: Sprite2D = wall.get_node("Sprite2D")
			next.append(image)
			image.modulate.a = 0.4
	for image in hidden_walls:
		if is_instance_valid(image) and image not in next: image.modulate.a = 1
	hidden_walls = next
