extends Node2D
# deck_manager.gd
# Script para gestionar el mazo de cartas y la pila de descarte en el juego Chinchón

# Señales
signal deck_clicked         # Emitida cuando se hace clic en el mazo
signal discard_clicked      # Emitida cuando se hace clic en la pila de descarte
signal card_dealt(card_node, destination_position, player_id)  # Emitida cuando se reparte una carta
signal deck_exhausted       # Emitida cuando se agota el mazo
signal discard_recycled     # Emitida cuando la pila de descarte se recicla como nuevo mazo

# Referencias a nodos
@onready var deck_sprite: Sprite2D = $DeckSprite
@onready var discard_sprite: Sprite2D = $DiscardSprite
@onready var deck_button: TextureButton = $DeckButton
@onready var discard_button: TextureButton = $DiscardButton
@onready var card_container: Node2D = $CardContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Constantes
const CARD_SCENE_PATH: String = "res://scenes/cards/card.tscn"
const DEAL_ANIMATION_SPEED: float = 0.3  # Duración de la animación al repartir
const CARD_SPACING: float = 0.5  # Espaciado entre cartas en el mazo (para efecto visual)

# Variables
var deck_position: Vector2
var discard_position: Vector2
var top_discard_card: Node2D = null  # Referencia a la carta superior de la pila de descarte
var deck_cards: Array = []  # Lista de nodos de cartas en el mazo
var discard_cards: Array = []  # Lista de nodos de cartas en la pila de descarte
var is_dealing: bool = false  # Indica si hay una animación de reparto en curso
var card_scene: PackedScene

# Función de inicialización
func _ready() -> void:
	# Guardar posiciones iniciales
	deck_position = deck_sprite.global_position
	discard_position = discard_sprite.global_position
	
	# Precargar escena de carta
	card_scene = load(CARD_SCENE_PATH)
	if card_scene == null:
		push_error("No se pudo cargar la escena de carta: " + CARD_SCENE_PATH)
	
	# Conectar señales de botones
	deck_button.connect("pressed", _on_deck_clicked)
	discard_button.connect("pressed", _on_discard_clicked)
	
	# Desactivar botón de pila de descarte inicialmente (hasta que haya una carta)
	discard_button.disabled = true
	
	# Actualizar el contador visual del mazo
	_update_deck_visuals()

# Inicializar el mazo con cartas de GameManager
func initialize_deck() -> void:
	# Limpiar mazo y pila de descarte anteriores
	clear_all_cards()
	
	# Crear carta visual para cada carta en el mazo de GameManager
	var deck_data = GameManager.deck.duplicate()
	
	for i in range(deck_data.size()):
		var card_data = deck_data[i]
		var card_instance = _create_card_from_data(card_data)
		
		# Colocar carta en el mazo (visualmente)
		card_instance.position = deck_position + Vector2(i * CARD_SPACING, i * CARD_SPACING)
		card_instance.is_face_up = false
		card_instance.z_index = i
		
		# Añadir a la lista de cartas del mazo
		deck_cards.append(card_instance)
	
	# Colocar primera carta en la pila de descarte
	if !GameManager.discard_pile.is_empty():
		var first_discard = GameManager.discard_pile[0]
		add_card_to_discard(first_discard)
	
	# Actualizar visuales
	_update_deck_visuals()

# Crear una carta visual a partir de datos
func _create_card_from_data(card_data: Dictionary) -> Node2D:
	var card_instance = card_scene.instantiate()
	card_container.add_child(card_instance)
	
	# Configurar valores de la carta
	card_instance.setup(card_data.suit, card_data.value, false)  # Inicialmente boca abajo
	
	return card_instance

# Agregar una carta a la pila de descarte
func add_card_to_discard(card_data: Dictionary, animate: bool = true) -> void:
	var card_instance = _create_card_from_data(card_data)
	
	# Configurar la carta
	card_instance.is_face_up = true
	card_instance.z_index = discard_cards.size()
	
	if animate:
		# Animar desde posición actual a la pila de descarte
		card_instance.position = card_instance.get_global_transform().origin
		card_instance.flip(true, false)  # Voltear sin animación inicialmente
		
		var tween = create_tween()
		tween.tween_property(card_instance, "position", discard_position, DEAL_ANIMATION_SPEED)
		tween.tween_callback(func(): 
			card_instance.position = discard_position
			_update_discard_visuals()
		)
	else:
		# Colocar directamente
		card_instance.position = discard_position
		card_instance.flip(true, false)
	
	# Actualizar referencia a la carta superior
	top_discard_card = card_instance
	discard_cards.append(card_instance)
	
	# Activar el botón de pila de descarte
	discard_button.disabled = false
	
	# Actualizar visuales
	_update_discard_visuals()

# Repartir una carta a un jugador
func deal_card_to_player(player_id: int, destination_position: Vector2) -> void:
	if is_dealing:
		push_warning("Ya hay una carta siendo repartida, se ignorará esta solicitud")
		return
	
	if deck_cards.is_empty():
		push_warning("El mazo está vacío, no se pueden repartir más cartas")
		emit_signal("deck_exhausted")
		return
	
	is_dealing = true
	
	# Obtener la carta superior del mazo
	var card_instance = deck_cards.pop_back()
	
	# Animar el movimiento de la carta
	var tween = create_tween()
	tween.tween_property(card_instance, "position", destination_position, DEAL_ANIMATION_SPEED)
	tween.tween_callback(func(): 
		card_instance.flip(true)  # Voltear la carta al llegar
		is_dealing = false
		emit_signal("card_dealt", card_instance, destination_position, player_id)
	)
	
	# Actualizar visuales del mazo
	_update_deck_visuals()

# Tomar la carta superior de la pila de descarte
func take_top_discard_card() -> Node2D:
	if discard_cards.is_empty():
		push_warning("La pila de descarte está vacía")
		return null
	
	var card = discard_cards.pop_back()
	top_discard_card = discard_cards.back() if !discard_cards.is_empty() else null
	
	# Actualizar visuales
	_update_discard_visuals()
	
	return card

# Reciclar la pila de descarte como nuevo mazo
func recycle_discard_as_deck() -> void:
	if discard_cards.size() <= 1:
		push_warning("No hay suficientes cartas en la pila de descarte para reciclar")
		return
	
	# Mantener la carta superior en la pila de descarte
	var top_card = null
	if !discard_cards.is_empty():
		top_card = discard_cards.pop_back()
	
	# Mover el resto al mazo
	for card in discard_cards:
		card.flip(false)  # Voltear boca abajo
		deck_cards.append(card)
	
	# Limpiar la lista de descarte
	discard_cards.clear()
	
	# Restaurar la carta superior
	if top_card != null:
		discard_cards.append(top_card)
		top_discard_card = top_card
	
	# Mezclar visualmente las cartas del mazo
	_shuffle_deck_visually()
	
	# Actualizar visuales
	_update_deck_visuals()
	_update_discard_visuals()
	
	# Emitir señal
	emit_signal("discard_recycled")

# Mezclar visualmente las cartas del mazo
func _shuffle_deck_visually() -> void:
	deck_cards.shuffle()
	
	# Reposicionar las cartas en el mazo
	for i in range(deck_cards.size()):
		var card = deck_cards[i]
		card.z_index = i
		
		# Animar el reposicionamiento
		var target_pos = deck_position + Vector2(i * CARD_SPACING, i * CARD_SPACING)
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, 0.2)

# Limpiar todas las cartas
func clear_all_cards() -> void:
	# Eliminar todas las cartas de ambos mazo y pila de descarte
	for card in deck_cards:
		card.queue_free()
	
	for card in discard_cards:
		card.queue_free()
	
	deck_cards.clear()
	discard_cards.clear()
	top_discard_card = null
	
	# Actualizar visuales
	_update_deck_visuals()
	_update_discard_visuals()

# Actualizar visualización del mazo
func _update_deck_visuals() -> void:
	# Actualizar visibilidad del sprite del mazo
	deck_sprite.visible = !deck_cards.is_empty()
	
	# Actualizar interactividad del botón
	deck_button.disabled = deck_cards.is_empty()
	
	# Aquí se podría añadir un contador visual o efecto según cantidad de cartas

# Actualizar visualización de la pila de descarte
func _update_discard_visuals() -> void:
	# Actualizar visibilidad del sprite de la pila de descarte
	discard_sprite.visible = discard_cards.is_empty()
	
	# La carta superior es visible por sí misma, no necesita sprite adicional
	
	# Actualizar interactividad del botón
	discard_button.disabled = discard_cards.is_empty()

# Manejadores de eventos
func _on_deck_clicked() -> void:
	if !deck_cards.is_empty():
		emit_signal("deck_clicked")

func _on_discard_clicked() -> void:
	if !discard_cards.is_empty():
		emit_signal("discard_clicked")