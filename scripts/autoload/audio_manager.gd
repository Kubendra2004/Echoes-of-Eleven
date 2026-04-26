## AudioManager Autoload
## Manages background music, SFX, and ambient sounds for atmosphere
extends Node

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _tween: Tween

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.name = "MusicPlayer"
	add_child(_music_player)
	
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)
	
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.name = "AmbientPlayer"
	add_child(_ambient_player)

## Play background music with crossfade
func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if _tween:
		_tween.kill()
	
	if _music_player.playing:
		_tween = create_tween()
		_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
		await _tween.finished
	
	_music_player.stream = stream
	_music_player.volume_db = -40.0
	_music_player.play()
	
	_tween = create_tween()
	_tween.tween_property(_music_player, "volume_db", 0.0, fade_duration)

## Play a sound effect
func play_sfx(stream: AudioStream) -> void:
	_sfx_player.stream = stream
	_sfx_player.play()

## Play ambient sound (loops)
func play_ambient(stream: AudioStream, fade_duration: float = 2.0) -> void:
	_ambient_player.stream = stream
	_ambient_player.volume_db = -40.0
	_ambient_player.play()
	
	var tween = create_tween()
	tween.tween_property(_ambient_player, "volume_db", -10.0, fade_duration)

## Stop all audio
func stop_all(fade_duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
	tween.tween_property(_ambient_player, "volume_db", -40.0, fade_duration)
	await tween.finished
	_music_player.stop()
	_ambient_player.stop()

## Stop music
func stop_music(fade_duration: float = 1.0) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
	await _tween.finished
	_music_player.stop()
