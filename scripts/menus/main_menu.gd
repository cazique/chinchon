extends Control
# main_menu.gd
# Script para el menú principal del juego Chinchón

# Señales
signal start_singleplayer  # Emitida cuando se inicia el modo un jugador
signal start_multiplayer   # Emitida cuando se inicia el modo multijugador
signal open_settings       # Emitida cuando se abren las configuraciones
signal exit_game           # Emitida cuando se solicita salir del juego

# Referencias a nodos
@onready var single_player_button: Button = $MainContainer/ButtonsContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $MainContainer/ButtonsContainer/MultiplayerButton
@onready var settings_button: Button = $MainContainer/ButtonsContainer/SettingsButton
@onready var exit_button: Button = $MainContainer/ButtonsContainer/ExitButton
@onready var version_label: Label = $VersionLabel
@onready var player_setup_panel: Control = $PlayerSetupPanel
@onready var settings_panel: Control = $SettingsPanel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var logo_animation: AnimatedSprite2D = $LogoAnimation

# Variables
var player_count: int = 1  # Número de jugadores (por defecto 1 jugador)
var player_names: Array = ["Jugador"]  # Nombres de los jugadores
var use_48_card_deck: bool = true  # Usar baraja de 48 cartas por defecto
var two_deck_mode: bool = false  # Modo de una o dos barajas

# Función de inicialización
func _ready() -> void:
	# Mostrar versión del juego
	version_label.text = "v" + GameManager.GAME_VERSION
	
	# Conectar señales de botones
	single_player_button.connect("pressed", _on_single_player_button_pressed)
	multiplayer_button.connect("pressed", _on_multiplayer_button_pressed)
	settings_button.connect("pressed", _on_settings_button_pressed)
	exit_button.connect("pressed", _on_exit_button_pressed)
	
	# Configurar paneles
	player_setup_panel.visible = false
	settings_panel.visible = false
	
	# Conectar botones del panel de configuración de jugadores
	var start_game_button = player_setup_panel.get_node("VBoxContainer/StartGameButton")
	var back_button = player_setup_panel.get_node("VBoxContainer/BackButton")
	var player_count_slider = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountSlider")
	var deck_toggle = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/DeckTypeToggle")
	var two_deck_toggle = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/TwoDeckToggle")
	
	start_game_button.connect("pressed", _on_start_game_button_pressed)
	back_button.connect("pressed", _on_back_button_pressed)
	player_count_slider.connect("value_changed", _on_player_count_slider_changed)
	deck_toggle.connect("toggled", _on_deck_toggle_toggled)
	two_deck_toggle.connect("toggled", _on_two_deck_toggle_toggled)
	
	# Configurar panel de configuraciones
	var settings_back_button = settings_panel.get_node("VBoxContainer/BackButton")
	settings_back_button.connect("pressed", _on_settings_back_button_pressed)
	
	# Iniciar animaciones y música
	if animation_player.has_animation("menu_intro"):
		animation_player.play("menu_intro")
	
	if background_music.stream != null:
		background_music.play()
	
	if logo_animation != null:
		logo_animation.play("default")

# Mostrar panel de configuración de jugadores para modo un jugador
func show_singleplayer_setup() -> void:
	player_count = 1
	player_names = ["Jugador"]
	
	# Configurar panel para modo un jugador
	var player_count_container = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer")
	var player_count_slider = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountSlider")
	var player_count_label = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountValue")
	var title_label = player_setup_panel.get_node("VBoxContainer/TitleLabel")
	
	title_label.text = "Configuración de Juego Solitario"
	player_count_container.visible = true  # Mostrar selección de número de oponentes
	player_count_slider.min_value = 1
	player_count_slider.max_value = 7
	player_count_slider.value = 2  # Jugador + 1 oponente por defecto
	player_count_label.text = "Oponentes: 1"
	
	# Actualizar opciones de baraja
	update_deck_options()
	
	# Mostrar panel con animación
	_transition_to_panel(player_setup_panel)

# Mostrar panel de configuración de jugadores para modo multijugador
func show_multiplayer_setup() -> void:
	player_count = 2
	player_names = ["Jugador 1", "Jugador 2"]
	
	# Configurar panel para modo multijugador
	var player_count_container = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer")
	var player_count_slider = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountSlider")
	var player_count_label = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountValue")
	var title_label = player_setup_panel.get_node("VBoxContainer/TitleLabel")
	
	title_label.text = "Configuración de Multijugador"
	player_count_container.visible = true  # Mostrar selección de número de jugadores
	player_count_slider.min_value = 2
	player_count_slider.max_value = 8
	player_count_slider.value = 2  # 2 jugadores por defecto
	player_count_label.text = "Jugadores: 2"
	
	# Actualizar opciones de baraja
	update_deck_options()
	
	# Mostrar panel con animación
	_transition_to_panel(player_setup_panel)

# Actualizar opciones de baraja según el número de jugadores
func update_deck_options() -> void:
	var two_deck_toggle = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/TwoDeckToggle")
	var two_deck_container = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/TwoDeckContainer")
	
	# Habilitar opción de dos barajas solo si hay 5+ jugadores
	two_deck_container.visible = player_count >= 5
	
	if player_count >= 5 and !two_deck_mode:
		two_deck_toggle.button_pressed = true
		two_deck_mode = true
	elif player_count < 5 and two_deck_mode:
		two_deck_toggle.button_pressed = false
		two_deck_mode = false

# Mostrar panel de configuraciones
func show_settings_panel() -> void:
	_transition_to_panel(settings_panel)

# Volver al menú principal
func back_to_main_menu() -> void:
	_transition_to_panel(null)

# Función para transicionar entre paneles
func _transition_to_panel(target_panel: Control) -> void:
	# Ocultar todos los paneles excepto el menú principal
	if player_setup_panel.visible:
		player_setup_panel.visible = false
	
	if settings_panel.visible:
		settings_panel.visible = false
	
	# Mostrar el panel objetivo
	if target_panel != null:
		target_panel.visible = true
		
		# Animar transición si es posible
		if animation_player.has_animation("panel_transition"):
			animation_player.play("panel_transition")
	else:
		# Mostrar menú principal
		if animation_player.has_animation("menu_return"):
			animation_player.play("menu_return")

# Iniciar juego con configuración actual
func start_game() -> void:
	var actual_player_count = player_count
	
	if GameManager.game_mode == "singleplayer":
		actual_player_count += 1  # Añadir al jugador humano a los oponentes
	
	# Configurar GameManager
	GameManager.use_48_card_deck = use_48_card_deck
	GameManager.two_deck_mode = two_deck_mode
	
	# Crear la lista de nombres de jugadores para la partida
	var game_player_names = []
	
	# Modo un jugador (jugador + CPU)
	if GameManager.game_mode == "singleplayer":
		game_player_names.append("Jugador")
		
		# Añadir oponentes CPU
		for i in range(1, actual_player_count):
			game_player_names.append("CPU " + str(i))
	else:
		# Modo multijugador
		for i in range(actual_player_count):
			game_player_names.append("Jugador " + str(i + 1))
	
	# Iniciar el juego
	if GameManager.game_mode == "singleplayer":
		emit_signal("start_singleplayer", actual_player_count, game_player_names, two_deck_mode, use_48_card_deck)
	else:
		emit_signal("start_multiplayer", actual_player_count, game_player_names, two_deck_mode, use_48_card_deck)

# Manejadores de eventos
func _on_single_player_button_pressed() -> void:
	GameManager.game_mode = "singleplayer"
	show_singleplayer_setup()

func _on_multiplayer_button_pressed() -> void:
	GameManager.game_mode = "multiplayer"
	show_multiplayer_setup()

func _on_settings_button_pressed() -> void:
	show_settings_panel()
	emit_signal("open_settings")

func _on_exit_button_pressed() -> void:
	emit_signal("exit_game")

func _on_start_game_button_pressed() -> void:
	start_game()

func _on_back_button_pressed() -> void:
	back_to_main_menu()

func _on_settings_back_button_pressed() -> void:
	back_to_main_menu()

func _on_player_count_slider_changed(value: float) -> void:
	var count_value = int(value)
	player_count = count_value
	
	var label = player_setup_panel.get_node("VBoxContainer/PlayerCountContainer/PlayerCountValue")
	
	if GameManager.game_mode == "singleplayer":
		label.text = "Oponentes: " + str(count_value - 1)
	else:
		label.text = "Jugadores: " + str(count_value)
	
	# Actualizar opciones de baraja
	update_deck_options()

func _on_deck_toggle_toggled(button_pressed: bool) -> void:
	use_48_card_deck = button_pressed
	
	var label = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/DeckTypeLabel")
	
	if button_pressed:
		label.text = "Baraja de 48 cartas"
	else:
		label.text = "Baraja de 40 cartas"

func _on_two_deck_toggle_toggled(button_pressed: bool) -> void:
	two_deck_mode = button_pressed
	
	var label = player_setup_panel.get_node("VBoxContainer/DeckOptionsContainer/TwoDeckContainer/TwoDeckLabel")
	
	if button_pressed:
		label.text = "Usando dos barajas"
	else:
		label.text = "Usando una baraja"