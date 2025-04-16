extends Node2D
# main_game.gd
# Script principal para la escena del juego Chinchón
# Coordina todos los componentes y gestiona el flujo de la partida

# Referencias a nodos
@onready var player_hand: Node2D = $PlayerHand
@onready var deck_manager: Node2D = $Table/DeckManager
@onready var ui_manager: CanvasLayer = $UILayer
@onready var opponent_container: Node2D = $OpponentsContainer
@onready var combination_area: Node2D = $CombinationArea
@onready var game_camera: Camera2D = $GameCamera
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_sound_player: AudioStreamPlayer = $GameSoundPlayer

# Variables del juego
var is_game_initialized: bool = false
var player_names: Dictionary = {}
var opponent_hands: Dictionary = {}
var current_dealer_id: int = -1
var current_round: int = 0
var active_players: Array = []
var ai_think_time: float = 1.0  # Tiempo de "pensamiento" de la IA en segundos

# Función de inicialización
func _ready() -> void:
	# Configurar cámara
	if game_camera:
		game_camera.make_current()
	
	# Conectar señales de GameManager
	GameManager.connect("game_started", _on_game_started)
	GameManager.connect("round_started", _on_round_started)
	GameManager.connect("player_turn_started", _on_player_turn_started)
	GameManager.connect("player_turn_ended", _on_player_turn_ended)
	GameManager.connect("card_drawn", _on_card_drawn)
	GameManager.connect("card_discarded", _on_card_discarded)
	GameManager.connect("player_chinchon", _on_player_chinchon)
	GameManager.connect("player_closed", _on_player_closed)
	GameManager.connect("round_ended", _on_round_ended)
	GameManager.connect("game_ended", _on_game_ended)
	GameManager.connect("game_paused", _on_game_paused)
	GameManager.connect("game_resumed", _on_game_resumed)
	
	# Conectar señales de UI
	ui_manager.connect("game_paused", _on_ui_pause_requested)
	ui_manager.connect("game_resumed", _on_ui_resume_requested)
	ui_manager.connect("new_game_requested", _on_new_game_requested)
	ui_manager.connect("main_menu_requested", _on_main_menu_requested)
	
	# Conectar señales del mazo
	deck_manager.connect("deck_clicked", _on_deck_clicked)
	deck_manager.connect("discard_clicked", _on_discard_clicked)
	
	# Conectar señales de la mano del jugador
	player_hand.connect("card_selected", _on_player_card_selected)
	player_hand.connect("card_played", _on_player_card_played)
	
	# Iniciar juego (para desarrollo, en producción esto se llamaría desde el menú)
	if OS.is_debug_build():
		# Solo para pruebas en desarrollo
		initialize_game()

# Inicializar un nuevo juego
func initialize_game() -> void:
	if is_game_initialized:
		return
	
	is_game_initialized = true
	
	# Crear lista de nombres según la configuración
	setup_player_names()
	
	# Configurar mano del jugador
	player_hand.player_id = 0
	player_hand.set_interactive(true)
	player_hand.set_player_turn(false)
	
	# Crear manos de oponentes
	create_opponent_hands()
	
	# Iniciar partida
	GameManager.start_new_game(active_players.size(), get_player_names_array(), 
		GameManager.two_deck_mode, GameManager.use_48_card_deck)

# Configurar nombres de jugadores
func setup_player_names() -> void:
	player_names.clear()
	
	# Añadir jugador humano
	player_names[0] = "Jugador"
	active_players = [0]
	
	# Añadir oponentes (CPU en singleplayer, humanos en multiplayer)
	var player_count = GameManager.players.size()
	
	for i in range(1, player_count):
		if GameManager.game_mode == "singleplayer":
			player_names[i] = "CPU " + str(i)
		else:
			player_names[i] = "Jugador " + str(i + 1)
		
		active_players.append(i)
	
	# Informar a UI de los nombres
	ui_manager.set_player_names(player_names)

# Crear manos de oponentes
func create_opponent_hands() -> void:
	# Limpiar oponentes anteriores
	for child in opponent_container.get_children():
		child.queue_free()
	
	opponent_hands.clear()
	
	# Crear nuevos oponentes
	var opponent_scene = load("res://scenes/game/opponent_hand.tscn")
	
	for i in range(1, active_players.size()):
		var player_id = active_players[i]
		var opponent_instance = opponent_scene.instantiate()
		
		opponent_container.add_child(opponent_instance)
		opponent_instance.setup(player_id, player_names[player_id])
		
		# Posicionar según el número de oponentes
		position_opponent(opponent_instance, i, active_players.size() - 1)
		
		opponent_hands[player_id] = opponent_instance

# Posicionar oponente en la mesa
func position_opponent(opponent: Node2D, index: int, total: int) -> void:
	var radius = 400  # Distancia desde el centro
	var start_angle = -110
	var end_angle = -70
	
	# Calcular ángulo basado en posición
	var angle_rad
	if total > 1:
		var angle_step = (end_angle - start_angle) / (total - 1)
		angle_rad = deg_to_rad(start_angle + index * angle_step)
	else:
		angle_rad = deg_to_rad((start_angle + end_angle) / 2)
	
	# Establecer posición
	var pos_x = cos(angle_rad) * radius
	var pos_y = sin(angle_rad) * radius
	opponent.position = Vector2(pos_x, pos_y)

# Obtener array con nombres de jugadores
func get_player_names_array() -> Array:
	var names = []
	
	for id in active_players:
		names.append(player_names[id])
	
	return names

# Actualizar visualmente las manos después de repartir
func update_hands_visuals() -> void:
	# Actualizar mano del jugador con cartas del GameManager
	if GameManager.players.size() > 0:
		var player_cards = GameManager.players[0].hand
		player_hand.initialize_hand(player_cards)
	
	# Actualizar manos de oponentes
	for player_id in opponent_hands.keys():
		if player_id < GameManager.players.size():
			var opponent = opponent_hands[player_id]
			var cards = GameManager.players[player_id].hand
			opponent.update_hand(cards.size())

# Iniciar turno del jugador
func start_player_turn() -> void:
	player_hand.set_player_turn(true)
	player_hand.set_interactive(true)
	
	ui_manager.show_message("Tu turno - Roba una carta del mazo o pila de descarte")
	ui_manager.update_turn_indicator(0)

# Iniciar turno de oponente/CPU
func start_opponent_turn(player_id: int) -> void:
	player_hand.set_player_turn(false)
	player_hand.set_interactive(false)
	
	# Resaltar oponente activo
	if player_id in opponent_hands:
		opponent_hands[player_id].highlight_turn(true)
	
	ui_manager.update_turn_indicator(player_id)
	
	# Si es CPU, procesar su turno
	if GameManager.game_mode == "singleplayer":
		process_ai_turn(player_id)
	else:
		# En modo multijugador, mostrar interfaz para el jugador actual
		# (Implementar según sistema de turnos en multijugador)
		pass

# Procesar turno de la IA
func process_ai_turn(player_id: int) -> void:
	# Simular tiempo de "pensamiento" de la IA
	await get_tree().create_timer(ai_think_time).timeout
	
	# Determinar si tomar del mazo o pila de descarte
	var take_from_discard = false
	
	if !GameManager.discard_pile.is_empty():
		# Lógica simple de IA: 50% de probabilidad de tomar de la pila
		# En una implementación real, sería más complejo basado en estrategias
		take_from_discard = randf() > 0.5
	
	# Tomar carta
	if take_from_discard and !GameManager.discard_pile.is_empty():
		_on_discard_clicked_for_ai(player_id)
	else:
		_on_deck_clicked_for_ai(player_id)
	
	# Simular tiempo para "pensar" qué descartar
	await get_tree().create_timer(ai_think_time).timeout
	
	# Determinar qué carta descartar (lógica simple para ejemplo)
	var ai_player = GameManager.players[player_id]
	var hand = ai_player.hand
	
	# Por defecto, descartar una carta aleatoria
	var card_index = randi() % hand.size()
	
	# Descartar carta
	GameManager.discard_card(player_id, card_index)

# Procesar robo de carta del mazo para la IA
func _on_deck_clicked_for_ai(player_id: int) -> void:
	var card = GameManager.draw_card(player_id, GameManager.DrawSource.DECK)
	
	if card.size() > 0:
		# Animar visualmente
		if player_id in opponent_hands:
			opponent_hands[player_id].add_card_visual()
		
		# Sonido de robar carta
		play_sound("card_draw")

# Procesar robo de carta de la pila para la IA
func _on_discard_clicked_for_ai(player_id: int) -> void:
	var card = GameManager.draw_card(player_id, GameManager.DrawSource.DISCARD_PILE)
	
	if card.size() > 0:
		# Animar visualmente
		if player_id in opponent_hands:
			opponent_hands[player_id].add_card_visual()
		
		# Actualizar visualización de la pila de descarte
		deck_manager.take_top_discard_card()
		
		# Sonido de robar carta
		play_sound("card_draw")

# Reproducir efectos de sonido
func play_sound(sound_name: String) -> void:
	var sound_path = "res://assets/audio/sfx/" + sound_name + ".ogg"
	var sound = load(sound_path)
	
	if sound and game_sound_player:
		game_sound_player.stream = sound
		game_sound_player.play()

# Volver al menú principal
func return_to_main_menu() -> void:
	# Cambiar a la escena del menú principal
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

# Manejadores de señales de GameManager
func _on_game_started() -> void:
	# Inicializar deck manager con las cartas del juego
	deck_manager.initialize_deck()
	
	# Actualizar visuales de las manos
	update_hands_visuals()
	
	# Actualizar UI
	ui_manager.update_round_indicator(1, GameManager.MAX_ROUNDS)
	
	# Animar inicio de partida si tenemos animación
	if animation_player and animation_player.has_animation("game_start"):
		animation_player.play("game_start")
	else:
		# Mostrar mensaje de inicio
		ui_manager.show_message("¡Comienza la partida!", 2.0)

func _on_round_started(round_num: int) -> void:
	current_round = round_num
	
	# Actualizar UI
	ui_manager.update_round_indicator(round_num, GameManager.MAX_ROUNDS)
	ui_manager.show_message("Ronda " + str(round_num), 1.5)
	
	# Actualizar visuales de las manos
	update_hands_visuals()
	
	# Reiniciar mazo visual
	deck_manager.initialize_deck()

func _on_player_turn_started(player_id: int) -> void:
	# Desactivar resaltado del jugador anterior
	for opponent_id in opponent_hands.keys():
		opponent_hands[opponent_id].highlight_turn(false)
	
	if player_id == 0:
		# Turno del jugador humano
		start_player_turn()
	else:
		# Turno de un oponente
		start_opponent_turn(player_id)

func _on_player_turn_ended(player_id: int) -> void:
	if player_id in opponent_hands:
		opponent_hands[player_id].highlight_turn(false)

func _on_card_drawn(player_id: int, from_pile: int) -> void:
	# Actualizar visualización según quién robó y de dónde
	if player_id == 0:
		player_hand.set_interactive(true)
		
		# Actualizar mensaje de instrucción
		ui_manager.show_message("Selecciona una carta para descartar", 2.0)
	else:
		if from_pile == GameManager.DrawSource.DISCARD_PILE:
			# Animar visualmente tomar carta de la pila
			deck_manager.take_top_discard_card()

func _on_card_discarded(player_id: int, card: Dictionary) -> void:
	# Visualizar descarte
	deck_manager.add_card_to_discard(card)
	
	# Sonido de descarte
	play_sound("card_discard")

func _on_player_chinchon(player_id: int) -> void:
	var player_name = player_names.get(player_id, "Jugador " + str(player_id + 1))
	
	# Mostrar mensaje de Chinchón
	ui_manager.show_message("¡" + player_name + " ha conseguido Chinchón!", 3.0)
	
	# Sonido de Chinchón
	play_sound("chinchon")

func _on_player_closed(player_id: int) -> void:
	var player_name = player_names.get(player_id, "Jugador " + str(player_id + 1))
	
	# Mostrar mensaje de cierre
	ui_manager.show_message("¡" + player_name + " ha cerrado el juego!", 3.0)
	
	# Sonido de cierre
	play_sound("game_close")

func _on_round_ended(scores: Dictionary) -> void:
	# Actualizar puntuaciones en la UI
	ui_manager.update_scores(scores)
	
	# Mostrar mensaje de fin de ronda
	ui_manager.show_message("Fin de la ronda " + str(current_round), 2.0)
	
	# Desactivar interactividad hasta la próxima ronda
	player_hand.set_interactive(false)
	player_hand.set_player_turn(false)

func _on_game_ended(final_scores: Dictionary) -> void:
	# Determinar ganador (menor puntuación)
	var winner_id = -1
	var min_score = 9999
	
	for player_id in final_scores.keys():
		if final_scores[player_id] < min_score:
			min_score = final_scores[player_id]
			winner_id = player_id
	
	# Mostrar panel de fin de juego
	ui_manager.show_game_over(final_scores, winner_id)
	
	# Sonido de fin de partida
	play_sound("game_over")

func _on_game_paused() -> void:
	# Implementar pausa (como ralentizar animaciones, etc.)
	pass

func _on_game_resumed() -> void:
	# Implementar reanudación (restaurar velocidad normal, etc.)
	pass

# Manejadores de señales de UI
func _on_ui_pause_requested() -> void:
	GameManager.pause_game()

func _on_ui_resume_requested() -> void:
	GameManager.resume_game()

func _on_new_game_requested() -> void:
	# Reiniciar componentes visuales
	player_hand.clear_hand()
	deck_manager.clear_all_cards()
	
	for opponent_id in opponent_hands.keys():
		opponent_hands[opponent_id].clear_hand()
	
	# Inicializar nuevo juego
	is_game_initialized = false
	initialize_game()

func _on_main_menu_requested() -> void:
	return_to_main_menu()

# Manejadores de señales del mazo
func _on_deck_clicked() -> void:
	if GameManager.game_state == GameManager.GameState.PLAYER_TURN and !GameManager.players[0].has_drawn:
		var card = GameManager.draw_card(0, GameManager.DrawSource.DECK)
		
		if card.size() > 0:
			# Añadir la carta a la mano visual
			player_hand.add_card(card)
			
			# Sonido de robar carta
			play_sound("card_draw")

func _on_discard_clicked() -> void:
	if GameManager.game_state == GameManager.GameState.PLAYER_TURN and !GameManager.players[0].has_drawn:
		var card = GameManager.draw_card(0, GameManager.DrawSource.DISCARD_PILE)
		
		if card.size() > 0:
			# Añadir la carta a la mano visual
			player_hand.add_card(card)
			
			# Actualizar visualización de la pila de descarte
			deck_manager.take_top_discard_card()
			
			# Sonido de robar carta
			play_sound("card_draw")

# Manejadores de señales de la mano del jugador
func _on_player_card_selected(card_node) -> void:
	# Implementar lógica cuando el jugador selecciona una carta
	pass

func _on_player_card_played(card_node) -> void:
	if GameManager.game_state == GameManager.GameState.PLAYER_TURN and GameManager.players[0].has_drawn:
		var card_index = player_hand.get_card_index(card_node)
		
		if card_index >= 0:
			# Descartar la carta seleccionada
			var card = GameManager.discard_card(0, card_index)
			
			if card.size() > 0:
				# Remover carta de la mano visual
				player_hand.remove_card(card_node)
