class_name PixelUI
extends RefCounted

const INK = Color("101b26")
const PANEL = Color("1b2b3a")
const EDGE = Color("526878")
const TEXT = Color("eff0db")
const MUTED = Color("a7b6bc")
const ACCENT = Color("7dd5bb")
const GOLD = Color("e9ba71")
static var shared_theme: Theme

static func box(fill: Color, edge: Color, padding: int = 16) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.border_width_bottom = 4
	style.set_content_margin_all(padding)
	style.anti_aliasing = false
	return style

static func theme() -> Theme:
	if shared_theme: return shared_theme
	shared_theme = Theme.new()
	shared_theme.default_font = load("res://Prefabs/BoldPixels.ttf")
	shared_theme.default_font_size = 24
	shared_theme.set_color("font_color", "Label", TEXT)
	shared_theme.set_color("default_color", "RichTextLabel", TEXT)
	for type in ["Panel", "PanelContainer"]: shared_theme.set_stylebox("panel", type, box(PANEL, EDGE))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var fill = Color("345464") if state == "hover" else Color("263d4c")
		shared_theme.set_stylebox(state, "Button", box(fill, ACCENT if state == "hover" else EDGE, 12))
		shared_theme.set_color("font_" + state + "_color", "Button", TEXT)
	shared_theme.set_color("font_color", "Button", TEXT)
	shared_theme.set_color("font_disabled_color", "Button", Color("677981"))
	shared_theme.set_stylebox("focus", "Button", box(Color.TRANSPARENT, GOLD, 0))
	shared_theme.set_constant("separation", "VBoxContainer", 12)
	shared_theme.set_constant("separation", "HBoxContainer", 12)
	return shared_theme

static func rect(control: Control, x: float, y: float, w: float, h: float) -> Control:
	control.position = Vector2(x, y)
	control.size = Vector2(w, h)
	return control

static func label(parent: Node, text: String, font_size: int = 24, color: Color = TEXT) -> Label:
	var node = Label.new()
	node.text = text
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

static func paragraph(parent: Node, text: String, font_size: int = 26) -> Label:
	var node = Label.new()
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.text = text
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", TEXT)
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, action: Callable, primary: bool = false) -> Button:
	var node = Button.new()
	node.text = text
	node.custom_minimum_size.y = 52
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if primary: node.add_theme_stylebox_override("normal", box(Color("28594f"), ACCENT, 12))
	parent.add_child(node)
	node.pressed.connect(func():
		var audio = node.get_node("/root/Audio")
		audio.unlock()
		audio.cue()
		action.call())
	return node

static func panel(parent: Node, bounds: Rect2) -> Panel:
	var node = Panel.new()
	node.theme = theme()
	parent.add_child(node)
	node.position = bounds.position
	node.size = bounds.size
	return node
