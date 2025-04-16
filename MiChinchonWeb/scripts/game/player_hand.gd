extends Node2D
# player_hand.gd
# Script para gestionar la mano de cartas del jugador en el juego Chinchón

# Señales
signal card_selected(card_node)    # Emitida cuando se selecciona una carta
signal card_deselected(card_node)  # Emitida cuando se deselecciona una carta
signal card_played(card_node)      # Emitida cuando se juega una carta
signal hand_sorted()               # Emitida cuando se ordena la mano
signal combination_formed(cards)   # Emitida cuando se detecta una combinación válida

# Constantes
const CARD_SCENE_PATH: String = "res://scenes/cards/card.tscn"
const CARD_WIDTH: float = 140.0    # Ancho visual de una carta
const CARD_SPACING: float = 50.0   # Espacio entre cartas cuando están desplegadas
const CARD_OVERLAP: float = 30.0   # Espacio entre cartas cuando están agrupadas
const ANIMATION_SPEED: float = 0.2 # Duración de las animaciones de reorganización
const MAX_HAND_WIDTH: float = 900.0 # Ancho máximo para desplegar las cartas

# Variables
var player_id: int = 0            # ID del jugador propietario de esta mano
var cards: Array = []             # Array de nodos de cartas en la mano
var selected_cards: Array = []    # Array de cartas seleccionadas actualmente
var is_interactive: bool = true   # Si la mano permite interacción del usuario
var is_sorting: bool = false      # Si actualmente se está ordenando la mano
var card_scene: PackedScene       # Referencia a la escena de carta precargada
var hand_center: Vector2          # Centro de la mano para posicionamiento
var is_player_turn: bool = false  # Si es actualmente el turno del jugador
var max_cards: int = 7            # Número máximo de cartas en mano (por defecto 7)

# Referencias a nodos
@onready var sort_button: Button = $SortButton
@onready var play_button: Button = $PlayButton
@onready var cards_container: Node2D = $CardsContainer

# Función de inicialización
func _ready() -> void:
	# Precargar escena de carta
	card_scene = load(CARD_SCENE_PATH)
	if card_scene == null:
		push_error("No se pudo cargar la escena de carta: " + CARD_SCENE_PATH)
	
	# Establecer centro de la mano
	hand_center = global_position
	
	# Conectar señales
	sort_button.connect("pressed", _on_sort_button_pressed)
	play_button.connect("pressed", _on_play_button_pressed)
	
	# Actualizar estado de botones
	_update_buttons_state()

# Inicializar la mano con cartas
func initialize_hand(data_cards: Array) -> void:
	# Limpiar mano actual
	clear_hand()
	
	# Añadir las nuevas cartas
	for card_data in data_cards:
		add_card(card_data)
	
	# Ordenar y organizar
	sort_hand()

# Añadir una carta a la mano
func add_card(card_data: Dictionary, animate: bool = true) -> Node2D:
	if cards.size() >= max_cards + 1:
		push_warning("La mano ya tiene el máximo de cartas (" + str(max_cards + 1) + ")")
		return null
	
	# Crear instancia de carta
	var card_instance = card_scene.instantiate()
	cards_container.add_child(card_instance)
	
	# Configurar valores de la carta
	card_instance.setup(card_data.suit, card_data.value, true)
	card_instance.owner_id = player_id
	
	# Configurar interactividad
	card_instance.set_draggable(is_interactive)
	card_instance.connect("card_clicked", _on_card_clicked)
	card_instance.connect("card_drag_ended", _on_card_drag_ended)
	
	# Añadir a la lista de cartas
	cards.append(card_instance)
	
	# Posicionar la carta
	if animate:
		_organize_cards()
	else:
		_set_card_positions_immediately()
	
	# Actualizar estado de botones
	_update_buttons_state()
	
	# Verificar automáticamente posibles combinaciones
	_check_for_combinations()
	
	return card_instance

# Eliminar una carta de la mano
func remove_card(card_node: Node2D) -> void:
	if card_node in selected_cards:
		selected_cards.erase(card_node)
	
	if card_node in cards:
		cards.erase(card_node)
		card_node.queue_free()
	
	# Reorganizar las cartas restantes
	_organize_cards()
	
	# Actualizar estado de botones
	_update_buttons_state()
	
	# Verificar automáticamente posibles combinaciones
	_check_for_combinations()

# Remover una carta por su índice
func remove_card_at(index: int) -> void:
	if index < 0 or index >= cards.size():
		push_error("Índice fuera de rango: " + str(index))
		return
	
	var card = cards[index]
	remove_card(card)

# Ordenar las cartas en la mano
func sort_hand() -> void:
	if is_sorting:
		return
	
	is_sorting = true
	
	# Ordenar primero por palo, luego por valor
	cards.sort_custom(func(a, b):
		if a.suit == b.suit:
			return a.value < b.value
		return a.suit < b.suit
	)
	
	# Reorganizar visualmente
	_organize_cards()
	
	is_sorting = false
	emit_signal("hand_sorted")

# Reorganizar visualmente las cartas
func _organize_cards() -> void:
	if cards.is_empty():
		return
	
	# Calcular el espacio entre cartas según el número de cartas
	var total_width = min(CARD_WIDTH * cards.size() + CARD_SPACING * (cards.size() - 1), MAX_HAND_WIDTH)
	var actual_spacing = (total_width - CARD_WIDTH) / max(cards.size() - 1, 1)
	
	# Posición inicial (centrada)
	var start_x = hand_center.x - total_width / 2
	
	# Animar el movimiento de cada carta
	for i in range(cards.size()):
		var card = cards[i]
		var target_position = Vector2(start_x + i * (CARD_WIDTH + actual_spacing), hand_center.y)
		var target_z_index = i
		
		# Si está seleccionada, ajustar posición vertical
		if card in selected_cards:
			target_position.y -= 20
		
		# Animar el movimiento
		card.move_to(target_position, ANIMATION_SPEED)
		card.move_to_z_index(target_z_index, ANIMATION_SPEED)

# Posicionar cartas inmediatamente (sin animación)
func _set_card_positions_immediately() -> void:
	if cards.is_empty():
		return
	
	# Calcular el espacio entre cartas según el número de cartas
	var total_width = min(CARD_WIDTH * cards.size() + CARD_SPACING * (cards.size() - 1), MAX_HAND_WIDTH)
	var actual_spacing = (total_width - CARD_WIDTH) / max(cards.size() - 1, 1)
	
	# Posición inicial (centrada)
	var start_x = hand_center.x - total_width / 2
	
	# Posicionar cada carta
	for i in range(cards.size()):
		var card = cards[i]
		var target_position = Vector2(start_x + i * (CARD_WIDTH + actual_spacing), hand_center.y)
		
		# Si está seleccionada, ajustar posición vertical
		if card in selected_cards:
			target_position.y -= 20
		
		# Posicionar directamente
		card.position = target_position
		card.original_position = target_position
		card.z_index = i
		card.original_z_index = i

# Limpiar la mano
func clear_hand() -> void:
	for card in cards:
		card.queue_free()
	
	cards.clear()
	selected_cards.clear()
	
	# Actualizar estado de botones
	_update_buttons_state()

# Establecer interactividad de la mano
func set_interactive(interactive: bool) -> void:
	is_interactive = interactive
	
	# Actualizar interactividad de cada carta
	for card in cards:
		card.set_draggable(interactive)
	
	# Actualizar estado de botones
	_update_buttons_state()

# Establecer si es el turno del jugador
func set_player_turn(is_turn: bool) -> void:
	is_player_turn = is_turn
	
	# Actualizar estado de botones
	_update_buttons_state()

# Verificar posibles combinaciones en la mano
func _check_for_combinations() -> void:
	# Esta función identificará posibles combinaciones válidas en la mano
	# (grupos del mismo valor o escaleras del mismo palo)
	
	if cards.size() < 3:
		return  # Se necesitan al menos 3 cartas para formar una combinación
	
	# Buscar grupos (3 o 4 cartas del mismo valor)
	var values_count = {}
	for card in cards:
		if card.value not in values_count:
			values_count[card.value] = []
		values_count[card.value].append(card)
	
	# Verificar si hay grupos de 3 o 4 cartas del mismo valor
	for value in values_count.keys():
		if values_count[value].size() >= 3:
			var combo = values_count[value]
			emit_signal("combination_formed", combo)
	
	# Buscar escaleras (3 o más cartas consecutivas del mismo palo)
	var cards_by_suit = {}
	for card in cards:
		if card.suit not in cards_by_suit:
			cards_by_suit[card.suit] = []
		cards_by_suit[card.suit].append(card)
	
	for suit in cards_by_suit.keys():
		if cards_by_suit[suit].size() < 3:
			continue
		
		# Ordenar cartas por valor
		var suit_cards = cards_by_suit[suit]
		suit_cards.sort_custom(func(a, b): return a.value < b.value)
		
		# Buscar secuencias consecutivas
		var i = 0
		while i < suit_cards.size() - 2:  # Necesitamos al menos 3 cartas
			var sequence = [suit_cards[i]]
			var current_value = suit_cards[i].value
			
			var j = i + 1
			while j < suit_cards.size() and suit_cards[j].value == current_value + 1:
				sequence.append(suit_cards[j])
				current_value = suit_cards[j].value
				j += 1
			
			if sequence.size() >= 3:
				emit_signal("combination_formed", sequence)
			
			i = j

# Obtener cartas seleccionadas
func get_selected_cards() -> Array:
	return selected_cards

# Obtener el índice de una carta en la mano
func get_card_index(card_node: Node2D) -> int:
	return cards.find(card_node)

# Verificar si la mano tiene una carta con valores específicos
func has_card_with_values(suit: int, value: int) -> bool:
	for card in cards:
		if card.suit == suit and card.value == value:
			return true
	return false

# Jugar las cartas seleccionadas
func play_selected_cards() -> void:
	if selected_cards.is_empty():
		return
	
	# Verificar si las cartas seleccionadas forman una combinación válida
	if _is_valid_combination(selected_cards):
		for card in selected_cards:
			emit_signal("card_played", card)
		selected_cards.clear()
	else:
		# Mostrar mensaje de error o feedback visual
		push_warning("Las cartas seleccionadas no forman una combinación válida")
		
		# Deseleccionar todas las cartas
		for card in selected_cards:
			card.select(false)
		selected_cards.clear()
	
	# Reorganizar las cartas
	_organize_cards()
	
	# Actualizar estado de botones
	_update_buttons_state()

# Verificar si las cartas forman una combinación válida
func _is_valid_combination(card_nodes: Array) -> bool:
	if card_nodes.size() < 3:
		return false  # Se necesitan al menos 3 cartas
	
	# Verificar si es un grupo (mismo valor)
	var is_group = true
	var first_value = card_nodes[0].value
	
	for card in card_nodes:
		if card.value != first_value:
			is_group = false
			break
	
	if is_group:
		return true
	
	# Verificar si es una escalera (mismo palo, valores consecutivos)
	var is_straight = true
	var first_suit = card_nodes[0].suit
	
	# Verificar que todas las cartas sean del mismo palo
	for card in card_nodes:
		if card.suit != first_suit:
			is_straight = false
			break
	
	if not is_straight:
		return false
	
	# Ordenar por valor
	var sorted_cards = card_nodes.duplicate()
	sorted_cards.sort_custom(func(a, b): return a.value < b.value)
	
	# Verificar que sean valores consecutivos
	for i in range(1, sorted_cards.size()):
		if sorted_cards[i].value != sorted_cards[i-1].value + 1:
			is_straight = false
			break
	
	return is_straight

# Actualizar el estado de los botones según la situación actual
func _update_buttons_state() -> void:
	sort_button.disabled = cards.size() < 2 or not is_interactive
	play_button.disabled = selected_cards.size() < 3 or not is_interactive or not is_player_turn
	
	# Mostrar/ocultar los botones según corresponda
	sort_button.visible = is_interactive
	play_button.visible = is_interactive and is_player_turn

# Manejadores de eventos
func _on_card_clicked(card_node) -> void:
	if not is_interactive:
		return
	
	# Alternar selección de la carta
	if card_node in selected_cards:
		selected_cards.erase(card_node)
		card_node.select(false)
		emit_signal("card_deselected", card_node)
	else:
		selected_cards.append(card_node)
		card_node.select(true)
		emit_signal("card_selected", card_node)
	
	# Reorganizar para reflejar la selección
	_organize_cards()
	
	# Actualizar estado de botones
	_update_buttons_state()

func _on_card_drag_ended(card_node) -> void:
	if not is_interactive or not is_player_turn:
		return
	
	# Aquí se podría implementar lógica para detectar si la carta 
	# fue arrastrada a una zona de juego o a la pila de descarte
	
	# Por ahora, solo reorganizamos las cartas
	_organize_cards()

func _on_sort_button_pressed() -> void:
	sort_hand()

func _on_play_button_pressed() -> void:
	play_selected_cards()