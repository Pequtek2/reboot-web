extends Node

var music: AudioStreamPlayer
var effects: AudioStreamPlayer
var playlist: Array = []
var index = 0
var active = ""
var music_volume = 0.55
var sfx_volume = 0.7
var enabled = false

func _ready() -> void:
	music = AudioStreamPlayer.new()
	effects = AudioStreamPlayer.new()
	add_child(music)
	add_child(effects)
	music.finished.connect(next_track)
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_volume = clampf(float(config.get_value("audio", "music", 0.55)), 0, 1)
		sfx_volume = clampf(float(config.get_value("audio", "sfx", 0.7)), 0, 1)
	apply_volume()

func unlock() -> void:
	if enabled: return
	enabled = true
	if not playlist.is_empty(): play_current()

func play_music(context: String) -> void:
	if context == active: return
	active = context
	playlist = [context, context + "2"]
	index = 0
	if enabled: play_current()

func play_current() -> void:
	music.stream = load("res://audio/%s.ogg" % playlist[index])
	music.play()

func next_track() -> void:
	index = (index + 1) % playlist.size()
	play_current()

func cue(name: String = "click") -> void:
	if not enabled: return
	var path = "res://audio/ui-%s.wav" % name
	if not ResourceLoader.exists(path): return
	effects.stream = load(path)
	effects.play()

func apply_volume() -> void:
	music.volume_db = linear_to_db(music_volume * 0.55)
	effects.volume_db = linear_to_db(sfx_volume)

func save_settings() -> void:
	apply_volume()
	var config = ConfigFile.new()
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.save("user://settings.cfg")
