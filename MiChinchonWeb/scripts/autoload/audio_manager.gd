extends Node
# audio_manager.gd
# Gestor global de audio para el juego Chinchón
# Se encarga de reproducir música y efectos de sonido

# Buses de audio
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Rutas de recursos
const MUSIC_PATH = "res://assets/audio/music/"
const SFX_PATH = "res://assets/audio/sfx/"

# Nodos para reproducción de audio
var music_players: Array = []
var sfx_players: Array = []
var current_music_player: int = 0
var current_sfx_player: int = 0

# Configuración
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true
var music_bus_idx: int = -1
var sfx_bus_idx: int = -1

# Precargar efectos de sonido comunes
var preloaded_sfx = {
	"card_draw": null,
	"card_discard": null,
	"card_shuffle": null,
	"button_click": null,
	"chinchon": null,
	"game_over": null,
	"game_start": null
}

# Función de inicialización
func _ready() -> void:
	# Obtener índices de buses de audio
	music_bus_idx = AudioServer.get_bus_index(MUSIC_BUS)
	sfx_bus_idx = AudioServer.get_bus_index(SFX_BUS)
	
	# Si los buses no existen, crearlos
	if music_bus_idx == -1:
		music_bus_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(music_bus_idx, MUSIC_BUS)
		AudioServer.set_bus_send(music_bus_idx, MASTER_BUS)
	
	if sfx_bus_idx == -1:
		sfx_bus_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(sfx_bus_idx, SFX_BUS)
		AudioServer.set_bus_send(sfx_bus_idx, MASTER_BUS)
	
	# Crear reproductores de música (para crossfade)
	for i in range(2):
		var music_player = AudioStreamPlayer.new()
		music_player.bus = MUSIC_BUS
		music_player.volume_db = linear_to_db(music_volume)
		music_player.name = "MusicPlayer" + str(i)
		add_child(music_player)
		music_players.append(music_player)
	
	# Crear pool de reproductores de efectos de sonido
	for i in range(8):  # 8 reproductores para permitir múltiples efectos simultáneos
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = SFX_BUS
		sfx_player.volume_db = linear_to_db(sfx_volume)
		sfx_player.name = "SFXPlayer" + str(i)
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	# Precargar efectos de sonido comunes
	preload_common_sfx()
	
	# Cargar configuración
	load_settings()
	
	# Configurar volumen inicial
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

# Precargar efectos de sonido comunes
func preload_common_sfx() -> void:
	for sfx_name in preloaded_sfx.keys():
		var sfx_resource = load(SFX_PATH + sfx_name + ".ogg")
		if sfx_resource:
			preloaded_sfx[sfx_name] = sfx_resource
		else:
			push_warning("No se pudo cargar el efecto de sonido: " + sfx_name)

# Reproducir música
func play_music(music_name: String, fade_duration: float = 1.0, loop: bool = true) -> void:
	if !music_enabled:
		return
	
	var music_resource = load(MUSIC_PATH + music_name + ".ogg")
	if !music_resource:
		push_warning("No se pudo cargar la música: " + music_name)
		return
	
	# Obtener el siguiente reproductor (para crossfade)
	var next_player_idx = (current_music_player + 1) % music_players.size()
	var current_player = music_players[current_music_player]
	var next_player = music_players[next_player_idx]
	
	# Configurar el siguiente reproductor
	next_player.stream = music_resource
	next_player.volume_db = linear_to_db(0.0)  # Empezar en silencio
	next_player.loop = loop
	next_player.play()
	
	# Crear efecto de crossfade
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(current_player, "volume_db", linear_to_db(0.0), fade_duration)
	fade_out_tween.tween_callback(func(): current_player.stop())
	
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(next_player, "volume_db", linear_to_db(music_volume), fade_duration)
	
	# Actualizar el reproductor actual
	current_music_player = next_player_idx

# Detener música
func stop_music(fade_duration: float = 1.0) -> void:
	var current_player = music_players[current_music_player]
	
	if current_player.playing:
		var tween = create_tween()
		tween.tween_property(current_player, "volume_db", linear_to_db(0.0), fade_duration)
		tween.tween_callback(func(): current_player.stop())

# Reproducir efecto de sonido
func play_sfx(sfx_name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	if !sfx_enabled:
		return
	
	# Verificar si está precargado
	var sfx_resource = preloaded_sfx.get(sfx_name)
	
	# Si no está precargado, intentar cargarlo
	if !sfx_resource:
		sfx_resource = load(SFX_PATH + sfx_name + ".ogg")
	
	if !sfx_resource:
		push_warning("No se pudo cargar el efecto de sonido: " + sfx_name)
		return
	
	# Buscar un reproductor de efectos disponible
	var found_player = false
	var start_idx = current_sfx_player
	
	for i in range(sfx_players.size()):
		var idx = (start_idx + i) % sfx_players.size()
		var player = sfx_players[idx]
		
		if !player.playing:
			player.stream = sfx_resource
			player.volume_db = linear_to_db(sfx_volume * volume)
			player.pitch_scale = pitch
			player.play()
			
			current_sfx_player = (idx + 1) % sfx_players.size()
			found_player = true
			break
	
	# Si todos los reproductores están ocupados, usar el siguiente en la lista
	if !found_player:
		var player = sfx_players[current_sfx_player]
		player.stream = sfx_resource
		player.volume_db = linear_to_db(sfx_volume * volume)
		player.pitch_scale = pitch
		player.play()
		
		current_sfx_player = (current_sfx_player + 1) % sfx_players.size()

# Establecer volumen de música
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	
	# Actualizar reproductores de música activos
	for player in music_players:
		if player.playing:
			player.volume_db = linear_to_db(music_volume)
	
	save_settings()

# Establecer volumen de efectos de sonido
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
	
	save_settings()

# Activar/desactivar música
func toggle_music(enabled: bool) -> void:
	music_enabled = enabled
	
	if music_bus_idx >= 0:
		AudioServer.set_bus_mute(music_bus_idx, !music_enabled)
	
	if !music_enabled:
		for player in music_players:
			player.stop()
	
	save_settings()

# Activar/desactivar efectos de sonido
func toggle_sfx(enabled: bool) -> void:
	sfx_enabled = enabled
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_mute(sfx_bus_idx, !sfx_enabled)
	
	save_settings()

# Guardar configuración de audio
func save_settings() -> void:
	var config = ConfigFile.new()
	
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sfx_enabled", sfx_enabled)
	
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("Error al guardar configuración de audio: " + str(err))

# Cargar configuración de audio
func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		music_enabled = config.get_value("audio", "music_enabled", true)
		sfx_enabled = config.get_value("audio", "sfx_enabled", true)
	
	# Aplicar configuración
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
		AudioServer.set_bus_mute(music_bus_idx, !music_enabled)
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
		AudioServer.set_bus_mute(sfx_bus_idx, !sfx_enabled)
