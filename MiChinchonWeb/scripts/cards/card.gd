extends Node2D
# Card.gd
# Clase para representar una carta individual en el juego Chinchón
# Maneja la lógica visual e interactiva de las cartas

# Señales
signal card_clicked(card_node)  # Emitida cuando se hace clic en la carta
signal card_drag_started(card_node)  # Emitida cuando se comienza a arrastrar la carta
signal card_drag_ended(card_node)  # Emitida cuando se termina de arrastrar la carta

# Propiedades de la carta
var suit: int = -1  # Palo: oros, copas, espadas, bastos (valores de GameManager.CardSuit)
var value: int = -1  # Valor: 1(as) a 12(rey) (valores directos de carta española)
var score_value: int = 0  # Valor para puntuación
var card_id: String = ""  # Identificador único para la carta
var owner_id: int = -1  # ID del jugador propietario (-1 si está en el mazo/descarte)

# Estados visuales
var is_face_up: bool = true  # Si la carta muestra su cara (true) o su dorso (false)
var is_selected: bool = false  # Si la carta está seleccionada
var is_highlighted: bool = false  # Si la carta está resaltada (ej: posible jugada)
var is_draggable: bool = false  # Si la carta se puede arrastrar
var original_position: Vector2  # Posición original para retorno si se cancela arrastre
var original_z_index: int = 0  # Índice Z original

# Referencias a nodos
@onready var sprite: Sprite2D = $CardSprite
@onready var highlight: Sprite2D = $HighlightSprite
@onready var collision: CollisionShape2D = $CardCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Constantes
const SELECTION_OFFSET: Vector2 = Vector2(0, -20)  # Desplazamiento cuando se selecciona
const HOVER_SCALE: Vector2 = Vector2(1.05, 1.05)  # Escala al pasar el cursor
const DRAG_Z_INDEX: int = 10  # Índice Z durante arrastre
const CARD_WIDTH: float = 140.0  # Ancho de la carta en píxeles
const CARD_HEIGHT: float = 190.0  # Alto de la carta en píxeles

# Variables para arrastre
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _hover: bool = false

# Función de inicialización
func _ready() -> void:
	# Guardar posición original
	original_position = position
	original_z_index = z_index
	
	# Configurar estado visual inicial
	highlight.visible = false
	
	# Conectar señales de interacción
	var card_button = $CardButton
	card_button.connect("pressed", _on_card_pressed)
	card_button.connect("mouse_entered", _on_mouse_entered)
	card_button.connect("mouse_exited", _on_mouse_exited)
	
	# Generar ID único para la carta si no existe
	if card_id.is_empty():
		card_id = _generate_card_id()
	
	# Actualizar apariencia inicial
	_update_appearance()

# Configurar la carta con valores específicos
func setup(card_suit: int, card_value: int, show_face: bool = true) -> void:
	suit = card_suit
	value = card_value
	score_value = _calculate_score_value(card_value)
	is_face_up = show_face
	
	# Generar ID único para la carta
	card_id = _generate_card_id()
	
	# Actualizar visual
	_update_appearance()

# Generar un ID único para la carta
func _generate_card_id() -> String:
	return "card_" + str(suit) + "_" + str(value) + "_" + str(randi() % 10000)

# Calcular valor de puntuación para la carta
func _calculate_score_value(card_value: int) -> int:
	match card_value:
		1: return 1  # As
		10: return 8  # Sota
		11: return 9  # Caballo
		12: return 10  # Rey
		_: return card_value  # 2-7 valen su número
	
# Actualizar apariencia de la carta según su estado
func _update_appearance() -> void:
	if is_face_up:
		# Mostrar cara de la carta
		_load_card_texture()
	else:
		# Mostrar dorso
		_load_back_texture()
	
	# Actualizar visibilidad del resaltado
	highlight.visible = is_highlighted or is_selected
	
	# Actualizar posición según selección
	if is_selected:
		position = original_position + SELECTION_OFFSET
	else:
		position = original_position

# Cargar textura correspondiente a la carta, usando el formato del repositorio de cartas españolas
func _load_card_texture() -> void:
	# Mapear valores de palo a nombres usados en el repositorio
	var suit_name = _get_suit_name(suit)
	
	# Mapear valores de carta a nombres usados en el repositorio
	var value_name = _get_value_file_name(value)
	
	# Construir la ruta del archivo según la estructura del repositorio
	# La estructura esperada es "baraja-española/{palo}/{valor}.png"
	var texture_path = "res://assets/sprites/cards/baraja-española/" + suit_name + "/" + value_name + ".png"
	
	var texture = load(texture_path)
	if texture:
		sprite.texture = texture
	else:
		# Si no encuentra la textura, intentar con una ruta alternativa (por si hay diferencias en nombres)
		var alt_texture_path = "res://assets/sprites/cards/" + suit_name + "_" + value_name + ".png"
		texture = load(alt_texture_path)
		
		if texture:
			sprite.texture = texture
		else:
			# Textura de respaldo si no se encuentra la correcta
			push_warning("No se pudo cargar la textura: " + texture_path + " o " + alt_texture_path)
			_load_back_texture()

# Cargar textura del dorso de la carta
func _load_back_texture() -> void:
	# Ruta esperada del dorso según repositorio
	var back_texture = load("res://assets/sprites/cards/baraja-española/dorso.png")
	
	if not back_texture:
		# Intentar ruta alternativa
		back_texture = load("res://assets/sprites/cards/card_back.png")
	
	if back_texture:
		sprite.texture = back_texture
	else:
		push_warning("No se pudo cargar la textura del dorso de la carta")
		# Crear un placeholder si no hay textura de dorso
		sprite.texture = null
		sprite.modulate = Color(0.2, 0.2, 0.7)

# Obtener nombre del palo para ruta de textura según el repositorio
func _get_suit_name(suit_value: int) -> String:
	match suit_value:
		GameManager.CardSuit.OROS: return "oros"
		GameManager.CardSuit.COPAS: return "copas"
		GameManager.CardSuit.ESPADAS: return "espadas"
		GameManager.CardSuit.BASTOS: return "bastos"
		_: return "unknown"

# Obtener nombre del valor para ruta de textura según el repositorio
func _get_value_file_name(card_value: int) -> String:
	match card_value:
		1: return "1"  # As
		10: return "10" # Sota
		11: return "11" # Caballo
		12: return "12" # Rey
		_: return str(card_value)

# Obtener nombre legible del valor para mostrar
func _get_value_name(card_value: int) -> String:
	match card_value:
		1: return "as"
		10: return "sota"
		11: return "caballo"
		12: return "rey"
		_: return str(card_value)

# Obtener descripción de la carta
func get_description() -> String:
	var value_str = _get_value_name(value)
	var suit_str = _get_suit_name(suit)
	
	# Capitalizar primera letra
	value_str = value_str.substr(0, 1).to_upper() + value_str.substr(1)
	suit_str = suit_str.substr(0, 1).to_upper() + suit_str.substr(1)
	
	return value_str + " de " + suit_str

# Voltear la carta
func flip(face_up: bool = !is_face_up, animate: bool = true) -> void:
	is_face_up = face_up
	
	if animate and animation_player.has_animation("flip"):
		animation_player.play("flip")
	else:
		_update_appearance()

# Seleccionar/deseleccionar la carta
func select(selected: bool = true, animate: bool = true) -> void:
	if is_selected == selected:
		return
		
	is_selected = selected
	
	if animate and animation_player.has_animation("select"):
		animation_player.play("select" if selected else "deselect")
	else:
		_update_appearance()

# Resaltar/desresaltar la carta
func highlight(highlighted: bool = true) -> void:
	is_highlighted = highlighted
	_update_appearance()

# Habilitar/deshabilitar arrastre
func set_draggable(draggable: bool) -> void:
	is_draggable = draggable

# Mover a una posición con animación
func move_to(target_position: Vector2, duration: float = 0.3) -> void:
	if duration <= 0:
		position = target_position
		original_position = target_position
		return
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): original_position = position)

# Mover a un índice Z específico con animación
func move_to_z_index(target_z: int, duration: float = 0.2) -> void:
	if duration <= 0:
		z_index = target_z
		original_z_index = target_z
		return
	
	var tween = create_tween()
	tween.tween_property(self, "z_index", target_z, duration)
	tween.tween_callback(func(): original_z_index = z_index)

# Procesamiento de entrada
func _input(event: InputEvent) -> void:
	if !is_draggable or !_dragging:
		return
	
	if event is InputEventMouseMotion:
		position = get_global_mouse_position() - _drag_offset
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			_end_drag()

# Iniciar arrastre
func _start_drag() -> void:
	if !is_draggable:
		return
	
	_dragging = true
	_drag_offset = get_global_mouse_position() - position
	z_index = DRAG_Z_INDEX
	
	emit_signal("card_drag_started", self)

# Finalizar arrastre
func _end_drag() -> void:
	if !_dragging:
		return
	
	_dragging = false
	z_index = original_z_index
	
	emit_signal("card_drag_ended", self)
	
	# La posición final se decidirá por quien reciba la señal card_drag_ended
	# Si no, la carta volverá a su posición original
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.2).set_ease(Tween.EASE_OUT)

# Manejadores de eventos
func _on_card_pressed() -> void:
	if is_draggable:
		_start_drag()
	else:
		is_selected = !is_selected
		_update_appearance()
	
	emit_signal("card_clicked", self)

func _on_mouse_entered() -> void:
	_hover = true
	
	if !_dragging and !is_selected:
		var tween = create_tween()
		tween.tween_property(self, "scale", HOVER_SCALE, 0.1).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	_hover = false
	
	if !_dragging and !is_selected:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

# Para depuración
func _to_string() -> String:
	return get_description()
