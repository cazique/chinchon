extends Node
# GameManager.gd
# Script singleton (autoload) que gestiona el estado global del juego Chinchón
# Controla la lógica del juego, reglas, puntuación y estado de la partida

# Señales
signal game_started               # Emitida cuando comienza una nueva partida
signal round_started(round_num)   # Emitida cuando comienza una nueva ronda
signal player_turn_started(player_id) # Emitida cuando comienza el turno de un jugador
signal player_turn_ended(player_id)   # Emitida cuando finaliza el turno de un jugador
signal card_drawn(player_id, from_pile) # Emitida cuando un jugador roba una carta
signal card_discarded(player_id, card)  # Emitida cuando un jugador descarta una carta
signal player_chinchon(player_id)  # Emitida cuando un jugador consigue Chinchón
signal player_closed(player_id)   # Emitida cuando un jugador cierra el juego
signal round_ended(scores)        # Emitida cuando finaliza una ronda
signal game_ended(final_scores)   # Emitida cuando finaliza la partida
signal game_paused                # Emitida cuando se pausa el juego
signal game_resumed               # Emitida cuando se reanuda el juego

# Enumeraciones
enum GameState {IDLE, DEALING, PLAYER_TURN, AI_TURN, ROUND_END, GAME_END}
enum DrawSource {DECK, DISCARD_PILE}
enum CardValue {AS = 1, DOS = 2, TRES = 3, CUATRO = 4, CINCO = 5, SEIS = 6, SIETE = 7, SOTA = 8, CABALLO = 9, REY = 10}
enum CardSuit {OROS, COPAS, ESPADAS, BASTOS}

# Constantes
const MAX_PLAYERS = 8          # Máximo número de jugadores
const MIN_PLAYERS = 2          # Mínimo número de jugadores
const CARDS_PER_PLAYER = 7     # Cartas por jugador
const MAX_ROUNDS = 5           # Número de rondas en una partida
const CHINCHON_BONUS = 10      # Puntos de bonificación por conseguir Chinchón
const MAX_SCORE = 100          # Puntuación máxima para eliminación
const GAME_VERSION = "1.0.0"   # Versión del juego

# Variables de estado del juego
var game_state = GameState.IDLE  # Estado actual del juego
var current_player_index = 0     # Índice del jugador actual
var players = []                 # Array de jugadores
var deck = []                    # Baraja de cartas
var discard_pile = []            # Pila de descarte
var current_round = 0            # Ronda actual
var is_game_active = false       # ¿Está el juego activo?
var is_game_paused = false       # ¿Está el juego pausado?
var use_48_card_deck = false     # True para baraja de 48 cartas, false para 40 cartas
var two_deck_mode = false        # True si se juega con dos barajas

# Variables de configuración
var game_mode = "singleplayer"  # "singleplayer" o "multiplayer"
var language = "es"             # Idioma predeterminado
var ai_difficulty = 1           # Dificultad de la IA (1-3)

# Funciones de inicialización
func _ready():
	randomize()  # Inicializar generador de números aleatorios
	load_config()
	print("GameManager inicializado - Versión: ", GAME_VERSION)

# Iniciar una nueva partida
func start_new_game(player_count: int, player_names: Array, use_two_decks: bool = false, use_48_cards: bool = false) -> void:
	if player_count < MIN_PLAYERS or player_count > MAX_PLAYERS:
		push_error("Número de jugadores inválido: " + str(player_count))
		return
	
	# Configurar opciones de juego
	two_deck_mode = use_two_decks
	use_48_card_deck = use_48_cards
	
	# Restablecer estado del juego
	is_game_active = true
	is_game_paused = false
	current_round = 1
	game_state = GameState.IDLE
	
	# Inicializar jugadores
	initialize_players(player_count, player_names)
	
	# Comenzar primera ronda
	start_round()
	
	# Señalizar inicio de juego
	emit_signal("game_started")
	print("Juego iniciado con " + str(player_count) + " jugadores")

# Inicializar jugadores
func initialize_players(count: int, names: Array) -> void:
	players.clear()
	
	for i in range(count):
		var player_name = names[i] if i < names.size() else "Jugador " + str(i+1)
		var is_ai = (i > 0) if game_mode == "singleplayer" else false
		
		players.append({
			"id": i,
			"name": player_name,
			"hand": [],
			"score": 0,
			"total_score": 0,
			"is_ai": is_ai,
			"has_drawn": false,
			"eliminated": false
		})
	
	current_player_index = 0  # El primer jugador comienza

# Iniciar una nueva ronda
func start_round() -> void:
	game_state = GameState.DEALING
	
	# Inicializar baraja y repartir
	initialize_deck()
	shuffle_deck()
	deal_cards()
	
	# Comenzar con el juego
	game_state = GameState.PLAYER_TURN
	
	# Emitir señal de inicio de ronda
	emit_signal("round_started", current_round)
	start_player_turn()
	
	print("Ronda " + str(current_round) + " iniciada")

# Inicializar baraja de cartas
func initialize_deck() -> void:
	deck.clear()
	discard_pile.clear()
	
	var suits = [CardSuit.OROS, CardSuit.COPAS, CardSuit.ESPADAS, CardSuit.BASTOS]
	var min_value = 1
	var max_value = 12 if use_48_card_deck else 10  # 48 cartas (con 8,9) o 40 cartas
	
	# Crear baraja(s)
	var deck_count = 1
	if two_deck_mode:
		deck_count = 2
	
	for _deck_num in range(deck_count):
		for suit in suits:
			for value in range(min_value, max_value + 1):
				# Ajustar valores para corresponder con la baraja española
				var adjusted_value = value
				if value > 7:
					adjusted_value = value + 2  # 8->10 (sota), 9->11 (caballo), 10->12 (rey)
				
				deck.append({
					"suit": suit,
					"value": adjusted_value,
					"score_value": get_card_score_value(adjusted_value)
				})
	
	print("Baraja inicializada: " + str(deck.size()) + " cartas")

# Obtener el valor de puntuación de una carta
func get_card_score_value(card_value: int) -> int:
	if card_value == 1:  # As
		return 1
	elif card_value == 10:  # Sota
		return 8
	elif card_value == 11:  # Caballo
		return 9
	elif card_value == 12:  # Rey
		return 10
	else:
		return card_value  # 2-7 valen lo mismo que su número

# Mezclar la baraja
func shuffle_deck() -> void:
	deck.shuffle()
	print("Baraja mezclada")

# Repartir cartas a los jugadores
func deal_cards() -> void:
	# Repartir cartas a cada jugador
	for player in players:
		if player.eliminated:
			continue
			
		player.hand.clear()
		player.has_drawn = false
		
		for _i in range(CARDS_PER_PLAYER):
			if deck.size() > 0:
				player.hand.append(deck.pop_back())
	
	# Colocar primera carta en la pila de descarte
	if deck.size() > 0:
		discard_pile.append(deck.pop_back())
	
	print("Cartas repartidas")

# Comenzar turno del jugador actual
func start_player_turn() -> void:
	var current_player = players[current_player_index]
	
	if current_player.eliminated:
		advance_to_next_player()
		return
	
	current_player.has_drawn = false
	emit_signal("player_turn_started", current_player.id)
	
	if current_player.is_ai:
		game_state = GameState.AI_TURN
		# La lógica de la IA se implementará en otro script
		# que llamará a process_ai_turn()
	else:
		game_state = GameState.PLAYER_TURN
	
	print("Turno del jugador: " + current_player.name)

# Procesar turno de la IA
func process_ai_turn() -> void:
	# Esta función será llamada por la lógica de IA
	var current_player = players[current_player_index]
	
	if !current_player.is_ai:
		push_error("process_ai_turn llamado para un jugador humano")
		return
	
	# Implementar lógica de IA aquí o en otro script
	# Por ahora, solo pasamos el turno
	advance_to_next_player()

# Robar carta (del mazo o de la pila de descarte)
func draw_card(player_index: int, source: int) -> Dictionary:
	var player = players[player_index]
	
	if player.has_drawn:
		push_error("El jugador ya ha robado una carta este turno")
		return {}
	
	var card = {}
	
	if source == DrawSource.DECK:
		# Verificar si hay cartas en el mazo
		if deck.size() == 0:
			# Si no hay cartas, reciclar la pila de descarte
			recycle_discard_pile()
			
			if deck.size() == 0:
				push_error("No hay cartas disponibles para robar")
				return {}
		
		card = deck.pop_back()
		print("Jugador " + player.name + " robó carta del mazo")
	else:  # DrawSource.DISCARD_PILE
		if discard_pile.size() == 0:
			push_error("No hay cartas en la pila de descarte")
			return {}
		
		card = discard_pile.pop_back()
		print("Jugador " + player.name + " tomó carta de la pila de descarte")
	
	player.hand.append(card)
	player.has_drawn = true
	
	emit_signal("card_drawn", player.id, source)
	return card

# Reciclar pila de descarte como nuevo mazo
func recycle_discard_pile() -> void:
	if discard_pile.size() <= 1:
		return
	
	# Mantener la carta superior en la pila de descarte
	var top_card = discard_pile.pop_back()
	
	# Mover el resto al mazo y mezclar
	deck = discard_pile.duplicate()
	discard_pile.clear()
	discard_pile.append(top_card)
	
	shuffle_deck()
	print("Pila de descarte reciclada como nuevo mazo")

# Descartar carta
func discard_card(player_index: int, card_index: int) -> Dictionary:
	var player = players[player_index]
	
	if !player.has_drawn:
		push_error("El jugador debe robar una carta antes de descartar")
		return {}
	
	if card_index < 0 or card_index >= player.hand.size():
		push_error("Índice de carta inválido: " + str(card_index))
		return {}
	
	var card = player.hand[card_index]
	player.hand.remove_at(card_index)
	discard_pile.append(card)
	
	emit_signal("card_discarded", player.id, card)
	print("Jugador " + player.name + " descartó una carta")
	
	# Verificar si el jugador ganó la ronda
	if check_for_round_win(player_index):
		end_round()
	else:
		advance_to_next_player()
	
	return card

# Verificar si un jugador ha ganado la ronda
func check_for_round_win(player_index: int) -> bool:
	var player = players[player_index]
	
	# El jugador debe tener exactamente 0 cartas para ganar
	if player.hand.size() == 0:
		# El jugador ha cerrado el juego
		emit_signal("player_closed", player.id)
		print("¡Jugador " + player.name + " ha cerrado el juego!")
		return true
	
	# Verificar si tiene Chinchón (todas las cartas combinadas)
	var has_chinchon = check_for_chinchon(player.hand)
	if has_chinchon:
		emit_signal("player_chinchon", player.id)
		print("¡Jugador " + player.name + " ha conseguido Chinchón!")
		return true
	
	return false

# Verificar si una mano es Chinchón (todas las cartas en combinaciones)
func check_for_chinchon(hand: Array) -> bool:
	# Implementación simple - se expandirá en la versión completa
	# para verificar correctamente las combinaciones de cartas
	
	# Por ahora, consideramos que un jugador tiene Chinchón si tiene
	# exactamente 7 cartas (CARDS_PER_PLAYER) y puede formar grupos
	
	if hand.size() != CARDS_PER_PLAYER:
		return false
		
	# En la implementación real, verificaríamos si todas las cartas pueden
	# formar escaleras o grupos del mismo valor
	
	return false  # Por defecto, retornamos false hasta implementar la verificación completa

# Pasar al siguiente jugador
func advance_to_next_player() -> void:
	emit_signal("player_turn_ended", players[current_player_index].id)
	
	# Encontrar al siguiente jugador no eliminado
	var next_player_found = false
	var original_index = current_player_index
	
	while !next_player_found:
		current_player_index = (current_player_index + 1) % players.size()
		
		if !players[current_player_index].eliminated:
			next_player_found = true
		
		# Si hemos dado una vuelta completa, todos están eliminados
		if current_player_index == original_index:
			break
	
	start_player_turn()

# Finalizar la ronda actual
func end_round() -> void:
	game_state = GameState.ROUND_END
	
	# Calcular puntuaciones
	var round_scores = calculate_round_scores()
	
	# Actualizar puntuaciones totales y verificar eliminaciones
	for i in range(players.size()):
		players[i].total_score += players[i].score
		
		if players[i].total_score >= MAX_SCORE:
			players[i].eliminated = true
			print("Jugador " + players[i].name + " eliminado con " + str(players[i].total_score) + " puntos")
	
	emit_signal("round_ended", round_scores)
	print("Ronda " + str(current_round) + " finalizada")
	
	# Verificar si el juego ha terminado
	if current_round >= MAX_ROUNDS or check_game_end():
		end_game()
	else:
		current_round += 1
		start_round()

# Verificar si el juego ha terminado
func check_game_end() -> bool:
	# El juego termina si solo queda un jugador no eliminado
	var active_players = 0
	
	for player in players:
		if !player.eliminated:
			active_players += 1
	
	return active_players <= 1

# Calcular puntuaciones de la ronda
func calculate_round_scores() -> Dictionary:
	var scores = {}
	var winner_index = -1
	var chinchon_bonus = false
	
	# Encontrar al ganador (jugador que cerró)
	for i in range(players.size()):
		if players[i].hand.size() == 0 or check_for_chinchon(players[i].hand):
			winner_index = i
			chinchon_bonus = check_for_chinchon(players[i].hand)
			break
	
	# Calcular puntuación para cada jugador
	for i in range(players.size()):
		var player = players[i]
		var hand_value = 0
		
		# Sumar valores de las cartas en la mano
		for card in player.hand:
			hand_value += card.score_value
		
		# El ganador recibe 0 puntos (o -CHINCHON_BONUS si hizo Chinchón)
		if i == winner_index:
			player.score = -CHINCHON_BONUS if chinchon_bonus else 0
		else:
			player.score = hand_value

		
		scores[i] = player.score
	
	return scores

# Finalizar el juego
func end_game() -> void:
	game_state = GameState.GAME_END
	is_game_active = false
	
	var final_scores = {}
	for i in range(players.size()):
		final_scores[i] = players[i].total_score
	
	emit_signal("game_ended", final_scores)
	print("Juego finalizado")

# Pausar el juego
func pause_game() -> void:
	if is_game_active and !is_game_paused:
		is_game_paused = true
		emit_signal("game_paused")
		print("Juego pausado")

# Reanudar el juego
func resume_game() -> void:
	if is_game_active and is_game_paused:
		is_game_paused = false
		emit_signal("game_resumed")
		print("Juego reanudado")

# Guardar configuración
func save_config() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "language", language)
	config.set_value("settings", "game_mode", game_mode)
	config.set_value("settings", "ai_difficulty", ai_difficulty)
	
	var err = config.save("user://chinchon_config.cfg")
	if err != OK:
		push_error("Error al guardar configuración: " + str(err))

# Cargar configuración
func load_config() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://chinchon_config.cfg")
	
	if err == OK:
		language = config.get_value("settings", "language", "es")
		game_mode = config.get_value("settings", "game_mode", "singleplayer")
		ai_difficulty = config.get_value("settings", "ai_difficulty", 1)
	else:
		# Crear configuración predeterminada si no existe
		save_config()

# Obtener el nombre formateado de un valor de carta
func get_card_value_name(value: int) -> String:
	match value:
		1: return "As"
		10: return "Sota"
		11: return "Caballo"
		12: return "Rey"
		_: return str(value)

# Obtener el nombre de un palo
func get_suit_name(suit: int) -> String:
	match suit:
		CardSuit.OROS: return "Oros"
		CardSuit.COPAS: return "Copas"
		CardSuit.ESPADAS: return "Espadas"
		CardSuit.BASTOS: return "Bastos"
		_: return "Desconocido"

# Obtener una descripción de una carta
func get_card_description(card: Dictionary) -> String:
	return get_card_value_name(card.value) + " de " + get_suit_name(card.suit)
