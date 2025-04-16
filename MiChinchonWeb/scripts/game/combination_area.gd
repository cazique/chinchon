extends Node2D
# combination_area.gd
# Script para gestionar el área donde se muestran las combinaciones de cartas

# Señales
signal combination_added(combination_cards)        # Emitida cuando se añade una combinación
signal combination_removed(combination_index)      # Emitida cuando se elimina una combinación
signal combination_completed(combination_index)    # Emitida cuando una combinación está completa

# Referencias a nodos
@onready var combinations_container = $CombinationsContainer
@onready var instruction_label = $InstructionLabel
@onready var background = $Background

# Constantes
const MAX_COMBINATIONS = 3        # Número máximo de combinaciones visibles
const MIN_CARDS_PER_COMBO = 3     # Mínimo de cartas para una combinación válida
const MAX_CARDS_PER_COMBO = 7     # Máximo de cartas por combinación
const CARD_SCENE_PATH = "res://scenes/cards/card.tscn"

# Variables
var active_combinations = []       # Lista de combinaciones activas
var drag_target_combo = -1         # Índice de la combinación a la que se está arrastrando una carta
var is_accepting_combinations = false  # Si el área está actualmente aceptando combinaciones

# Función de inicialización
func _ready():
	# Ocultar inicialmente los paneles de grupos
	for i in range(MAX_COMBINATIONS):
		var group_panel = get_group_panel(i)
		if group_panel:
			group_panel.visible = false
	
	# Mostrar instrucciones iniciales
	instruction_label.visible = true
	
	# Configurar el área como no interactiva inicialmente
	set_active(false)

# Establecer si el área está activa
func set_active(active: bool):
	is_accepting_combinations = active
	
	# Ajustar visuales según estado
	background.modulate.a = 0.5 if active else 0.184
	instruction_label.visible = active and active_combinations.size() == 0
	
	# Habilitar/deshabilitar interacción
	set_process_input(active)
	set_process(active)

# Añadir una nueva combinación
func add_combination(cards: Array) -> bool:
	if active_combinations.size() >= MAX_COMBINATIONS:
		push_warning("No se pueden añadir más combinaciones")
		return false
	
	if cards.size() < MIN_CARDS_PER_COMBO:
		push_warning("Se requieren al menos " + str(MIN_CARDS_PER_COMBO) + " cartas para formar una combinación")
		return false
	
	if !is_valid_combination(cards):
		push_warning("Las cartas no forman una combinación válida")
		return false
	
	# Encontrar el primer panel disponible
	for i in range(MAX_COMBINATIONS):
		var group_panel = get_group_panel(i)
		if group_panel and !group_panel.visible:
			# Activar panel
			group_panel.visible = true
			
			# Añadir cartas a la combinación
			var card_container = group_panel.get_node("CardContainer")
			for child in card_container.get_children():
				child.queue_free()
			
			var combination_data = {
				"panel_index": i,
				"cards": [],
				"is_group": is_card_group(cards),
				"suit": cards[0].suit if !is_card_group(cards) else -1,
				"value": cards[0].value if is_card_group(cards) else -1
			}
			
			# Crear cartas visuales
			for card in cards:
				add_card_to_combination(combination_data, card.suit, card.value)
			
			active_combinations.append(combination_data)
			
			# Ocultar instrucciones si hay al menos una combinación
			instruction_label.visible = false
			
			emit_signal("combination_added", cards)
			return true
	
	return false

# Añadir una carta a una combinación existente
func add_card_to_combination(combination, suit: int, value: int) -> bool:
	if combination.cards.size() >= MAX_CARDS_PER_COMBO:
		return false
	
	# Verificar si la carta se puede añadir a esta combinación
	if combination.is_group:
		# Para grupos, el valor debe coincidir
		if combination.value != value:
			return false
	else:
		# Para escaleras, debe ser del mismo palo y valor secuencial
		if combination.suit != suit:
			return false
		
		# Ordenar cartas actuales por valor
		var values = []
		for card in combination.cards:
			values.append(card.value)
		values.sort()
		
		# Verificar si la nueva carta extiende la secuencia
		if value != values[0] - 1 and value != values[-1] + 1:
			return false
	
	# Crear instancia de carta visual
	var card_scene = load(CARD_SCENE_PATH)
	var card_instance = card_scene.instantiate()
	
	# Obtener contenedor de cartas del panel
	var panel_index = combination.panel_index
	var group_panel = get_group_panel(panel_index)
	var card_container = group_panel.get_node("CardContainer")
	
	# Añadir la carta visual
	card_container.add_child(card_instance)
	card_instance.setup(suit, value, true)
	card_instance.set_draggable(false)
	card_instance.scale = Vector2(0.7, 0.7) # Escala más pequeña para la combinación
	
	# Registrar la carta en la combinación
	combination.cards.append({
		"suit": suit,
		"value": value,
		"node": card_instance
	})
	
	# Si la combinación está completa, emitir señal
	if combination.cards.size() >= MIN_CARDS_PER_COMBO:
		emit_signal("combination_completed", panel_index)
	
	return true

# Eliminar una combinación
func remove_combination(index: int) -> bool:
	if index < 0 or index >= active_combinations.size():
		return false
	
	var combination = active_combinations[index]
	var panel_index = combination.panel_index
	var group_panel = get_group_panel(panel_index)
	
	if group_panel:
		group_panel.visible = false
		var card_container = group_panel.get_node("CardContainer")
		
		# Eliminar todas las cartas
		for child in card_container.get_children():
			child.queue_free()
		
		# Eliminar de la lista de combinaciones activas
		active_combinations.erase(combination)
		
		# Mostrar instrucciones si no quedan combinaciones
		instruction_label.visible = is_accepting_combinations and active_combinations.size() == 0
		
		emit_signal("combination_removed", index)
		return true
	
	return false

# Verificar si una carta se puede añadir a una combinación existente
func can_add_to_combination(combination_index: int, card_node) -> bool:
	if combination_index < 0 or combination_index >= active_combinations.size():
		return false
	
	var combination = active_combinations[combination_index]
	
	# Si la combinación ya está llena
	if combination.cards.size() >= MAX_CARDS_PER_COMBO:
		return false
	
	# Verificar si la carta es compatible con la combinación
	if combination.is_group:
		# Para grupos, el valor debe coincidir
		return card_node.value == combination.value
	else:
		# Para escaleras, debe ser del mismo palo y valor secuencial
		if card_node.suit != combination.suit:
			return false
		
		# Ordenar cartas actuales por valor
		var values = []
		for card in combination.cards:
			values.append(card.value)
		values.sort()
		
		# Verificar si la nueva carta extiende la secuencia
		return card_node.value == values[0] - 1 or card_node.value == values[-1] + 1

# Obtener el panel de un grupo específico
func get_group_panel(index: int) -> Control:
	if index < 0 or index >= MAX_COMBINATIONS:
		return null
	
	return combinations_container.get_node("Group" + str(index + 1))

# Verificar si un conjunto de cartas forma un grupo válido (mismo valor)
func is_card_group(cards: Array) -> bool:
	if cards.size() < MIN_CARDS_PER_COMBO:
		return false
	
	var first_value = cards[0].value
	
	for card in cards:
		if card.value != first_value:
			return false
	
	return true

# Verificar si un conjunto de cartas forma una escalera válida (secuencia del mismo palo)
func is_card_straight(cards: Array) -> bool:
	if cards.size() < MIN_CARDS_PER_COMBO:
		return false
	
	# Todas las cartas deben ser del mismo palo
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return false
	
	# Ordenar por valor
	var sorted_cards = cards.duplicate()
	sorted_cards.sort_custom(func(a, b): return a.value < b.value)
	
	# Verificar secuencia
	for i in range(1, sorted_cards.size()):
		if sorted_cards[i].value != sorted_cards[i-1].value + 1:
			return false
	
	return true

# Verificar si un conjunto de cartas forma una combinación válida
func is_valid_combination(cards: Array) -> bool:
	return is_card_group(cards) or is_card_straight(cards)

# Limpiar todas las combinaciones
func clear_all_combinations():
	for i in range(active_combinations.size() - 1, -1, -1):
		remove_combination(i)
	
	active_combinations.clear()
	instruction_label.visible = is_accepting_combinations

# Actualizar la visualización de las combinaciones
func update_combinations_display():
	for i in range(active_combinations.size()):
		var combination = active_combinations[i]
		var panel_index = combination.panel_index
		var group_panel = get_group_panel(panel_index)
		
		if group_panel:
			group_panel.visible = true
			
			# Actualizar aspecto visual según el tipo de combinación
			if combination.is_group:
				group_panel.self_modulate = Color(1.0, 0.9, 0.7, 1.0)  # Amarillo para grupos
			else:
				group_panel.self_modulate = Color(0.7, 1.0, 0.8, 1.0)  # Verde para escaleras

# Procesar entrada para detectar arrastres de carta sobre el área
func _input(event):
	if !is_accepting_combinations:
		return
	
	# Aquí se implementaría la lógica para detectar arrastre de cartas
	# sobre el área de combinaciones y resaltar la zona donde se puede soltar