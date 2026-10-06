extends CanvasLayer

var root: Control
var panel: Panel
var on_escape: Callable
var prior_focus: WeakRef
var is_open: bool:
	get: return is_instance_valid(root)

func _ready() -> void:
	layer = 100

func open_panel(title: String, dimensions: Vector2 = Vector2(800, 480)) -> Panel:
	close()
	var focus = get_viewport().gui_get_focus_owner()
	prior_focus = weakref(focus) if focus else null
	root = Control.new()
	root.theme = PixelUI.theme()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim = ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.07, 0.88)
	root.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PixelUI.panel(root, Rect2((Vector2(1400, 780) - dimensions) / 2, dimensions))
	PixelUI.rect(PixelUI.label(panel, title, 32, PixelUI.GOLD), 28, 24, dimensions.x - 56, 44)
	on_escape = close
	Audio.cue("open")
	return panel

func close() -> void:
	if is_open:
		remove_child(root)
		root.queue_free()
	root = null
	panel = null
	on_escape = Callable()
	if prior_focus and is_instance_valid(prior_focus.get_ref()): prior_focus.get_ref().grab_focus()
	prior_focus = null

func message(title: String, text: String, button_text: String = "Powrót", action: Callable = Callable()) -> void:
	var p = open_panel(title)
	PixelUI.rect(PixelUI.paragraph(p, text), 28, 96, 744, 262)
	var button = PixelUI.button(p, button_text, func():
		close()
		if action.is_valid(): action.call(), true)
	PixelUI.rect(button, 28, 396, 744, 56)
	button.grab_focus()
	trap_focus()

func confirm(title: String, text: String, action: Callable) -> void:
	var p = open_panel(title, Vector2(680, 340))
	PixelUI.rect(PixelUI.paragraph(p, text), 28, 96, 624, 132)
	var cancel = PixelUI.button(p, "Anuluj", close)
	PixelUI.rect(cancel, 28, 258, 300, 54)
	PixelUI.rect(PixelUI.button(p, "Rozpocznij", func(): close(); action.call(), true), 340, 258, 312, 54)
	cancel.grab_focus()
	trap_focus()

func trap_focus() -> void:
	var controls: Array[Control] = []
	for node in panel.find_children("*", "Control", true, false):
		if node.focus_mode == Control.FOCUS_ALL and node.is_visible_in_tree(): controls.append(node)
	for i in controls.size():
		controls[i].focus_next = controls[i].get_path_to(controls[(i + 1) % controls.size()])
		controls[i].focus_previous = controls[i].get_path_to(controls[(i - 1 + controls.size()) % controls.size()])

func settings() -> void:
	var p = open_panel("USTAWIENIA", Vector2(680, 400))
	for i in 2:
		PixelUI.rect(PixelUI.label(p, "Muzyka" if i == 0 else "Efekty", 26), 28, 102 + i * 94, 180, 40)
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = Audio.music_volume if i == 0 else Audio.sfx_volume
		p.add_child(slider)
		PixelUI.rect(slider, 225, 108 + i * 94, 420, 36)
		slider.value_changed.connect(func(value):
			if i == 0: Audio.music_volume = value
			else: Audio.sfx_volume = value
			Audio.save_settings())
	var button = PixelUI.button(p, "Zapisz i wróć", close, true)
	PixelUI.rect(button, 28, 318, 624, 54)
	button.grab_focus()
	trap_focus()

func credits() -> void:
	var p = open_panel("TWÓRCY", Vector2(800, 650))
	var text = RichTextLabel.new()
	text.text = FileAccess.get_file_as_string("res://data/credits.txt")
	text.add_theme_font_size_override("normal_font_size", 24)
	text.scroll_active = true
	text.focus_mode = Control.FOCUS_ALL
	p.add_child(text)
	PixelUI.rect(text, 28, 92, 744, 442)
	var button = PixelUI.button(p, "Powrót", close, true)
	PixelUI.rect(button, 28, 568, 744, 54)
	button.grab_focus()
	trap_focus()

func pause() -> void:
	var p = open_panel("PRZERWA W PRACY", Vector2(620, 480))
	var list = VBoxContainer.new()
	p.add_child(list)
	PixelUI.rect(list, 28, 104, 564, 340)
	PixelUI.button(list, "Wznów", close, true).grab_focus()
	PixelUI.button(list, "Ustawienia", settings)
	if get_tree().current_scene.scene_file_path != Game.HUB:
		PixelUI.button(list, "Wróć do fabryki", Game.return_to_hub)
	PixelUI.button(list, "Zapisz i wróć do menu", func(): Game.save_game(); Game.change_scene("res://scenes/menu.tscn"))
	trap_focus()

func _input(event: InputEvent) -> void:
	if is_open and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		if on_escape.is_valid(): on_escape.call()
