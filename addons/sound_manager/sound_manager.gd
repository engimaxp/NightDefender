extends Node


const SoundEffectsPlayer = preload("res://addons/sound_manager/sound_effects.gd")
const MusicPlayer = preload("res://addons/sound_manager/music.gd")

@onready var MainSceneMusic = load("res://asset/music/Casual 8-bit 2.wav")
@onready var GameMusic = load("res://asset/music/Pixel adventures.mp3")
@onready var WinMusic = load("res://asset/music/8bitvictory.ogg")

@onready var SFX_Block1 = load("res://asset/sfx/Block1.ogg")
@onready var SFX_Exp1 = load("res://asset/sfx/Exp1.ogg")
@onready var SFX_Exp2 = load("res://asset/sfx/Exp2.ogg")
@onready var SFX_SExp1 = load("res://asset/sfx/SExp1.wav")
@onready var SFX_SExp2 = load("res://asset/sfx/SExp2.wav")
@onready var SFX_SExp3 = load("res://asset/sfx/SExp3.wav")
@onready var SFX_SExp4 = load("res://asset/sfx/SExp4.wav")
@onready var SFX_SExp5 = load("res://asset/sfx/SExp5.wav")
@onready var SFX_SExp6 = load("res://asset/sfx/SExp6.wav")

@onready var SFX_SExpPool = [SFX_SExp1,SFX_SExp2,SFX_SExp3,SFX_SExp4,SFX_SExp5,SFX_SExp6]

@onready var SFX_beep = load("res://asset/sfx/beep.tres")
@onready var SFX_powerup = load("res://asset/sfx/powerup.tres")
@onready var SFX_success1 = load("res://asset/sfx/success1.wav")
@onready var SFX_success2 = load("res://asset/sfx/success2.wav")
@onready var SFX_success3 = load("res://asset/sfx/success3.wav")

@onready var SFX_successPool = [SFX_success1,SFX_success2,SFX_success3]

@onready var SFX_wrong = load("res://asset/sfx/wrong.wav")
@onready var SFX_Ready = load("res://asset/sfx/ready.ogg")
@onready var SFX_Go = load("res://asset/sfx/go.ogg")

@onready var sound_effects: SoundEffectsPlayer = $SoundEffects
@onready var ui_sound_effects: SoundEffectsPlayer = $UISoundEffects
@onready var music: MusicPlayer = $Music

var sound_process_mode: ProcessMode:
	set(value):
		sound_effects.process_mode = value
	get:
		return sound_effects.process_mode

var ui_sound_process_mode: ProcessMode:
	set(value):
		ui_sound_effects.process_mode = value
	get:
		return ui_sound_effects.process_mode 

var music_process_mode: ProcessMode:
	set(value):
		music.process_mode = value
	get:
		return music.process_mode 


func _ready() -> void:
	self.sound_process_mode = PROCESS_MODE_PAUSABLE
	self.ui_sound_process_mode = PROCESS_MODE_ALWAYS
	self.music_process_mode = PROCESS_MODE_ALWAYS


func set_sound_volume(volume_between_0_and_1) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(sound_effects.bus), linear_to_db(volume_between_0_and_1))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(ui_sound_effects.bus), linear_to_db(volume_between_0_and_1))


func play_sound(resource: AudioStream, override_bus: String = "") -> AudioStreamPlayer:
	return sound_effects.play(resource, override_bus)


func play_ui_sound(resource: AudioStream, override_bus: String = "") -> AudioStreamPlayer:
	return ui_sound_effects.play(resource, override_bus)


func set_default_sound_bus(bus: String) -> void:
	sound_effects.bus = bus


func set_default_ui_sound_bus(bus: String) -> void:
	ui_sound_effects.bus = bus


func set_music_volume(volume_between_0_and_1: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(music.bus), linear_to_db(volume_between_0_and_1))


func play_music(resource: AudioStream, crossfade_duration: float = 0.0, override_bus: String = "") -> AudioStreamPlayer:
	return music.play(resource, 0.0, crossfade_duration, override_bus)


func play_music_at_volume(resource: AudioStream, volume: float = 0.0, crossfade_duration: float = 0.0, override_bus: String = "") -> AudioStreamPlayer:
	return music.play(resource, volume, crossfade_duration, override_bus)


func get_music_track_history() -> Array:
	return music.track_history


func get_last_played_music_track() -> String:
	return music.track_history[0]


func is_music_playing(resource: AudioStream = null) -> bool:
	return music.is_playing(resource)
	

func is_music_track_playing(resource_path: String) -> bool:
	return music.is_track_playing(resource_path)


func get_currently_playing_music() -> Array:
	return music.get_current()


func get_currently_playing_music_tracks() -> Array:
	return music.get_current_tracks()


func stop_music(fade_out_duration: float = 0.0) -> void:
	music.stop(fade_out_duration)


func set_default_music_bus(bus: String) -> void:
	music.bus = bus
