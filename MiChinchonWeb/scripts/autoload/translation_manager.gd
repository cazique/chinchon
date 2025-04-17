extends Node
# translation_manager.gd
# Gestor de traducciones y localización para el juego Chinchón

# Señales
signal language_changed(locale)  # Emitida cuando se cambia el idioma

# Constantes
const TRANSLATIONS_PATH = "res://assets/i18n/"
const DEFAULT_LOCALE = "es"  # Español como idioma por defecto

# Idiomas soportados
var supported_locales = {
	"es": {
		"name": "Español",
		"flag": "es_flag"
	},
	"en": {
		"name": "English",
		"flag": "en_flag"
	}
	# Añadir más idiomas según sea necesario
}

# Estado
var current_locale: String = DEFAULT_LOCALE

# Función de inicialización
func _ready() -> void:
	# Cargar configuración de idioma guardada
	load_settings()
	
	# Establecer el idioma inicial
	set_locale(current_locale)
	
	# Cargar traducciones
	load_translations()

# Cargar archivos de traducción
func load_translations() -> void:
	# Buscar archivos de traducción en el directorio
	var translations_dir = DirAccess.open(TRANSLATIONS_PATH)
	
	if translations_dir:
		translations_dir.list_dir_begin()
		var file_name = translations_dir.get_next()
		
		while file_name != "":
			if !translations_dir.current_is_dir() and file_name.ends_with(".translation"):
				var translation_path = TRANSLATIONS_PATH + file_name
				var translation = load(translation_path)
				
				TranslationServer.add_translation(translation)
				print("Traducción cargada desde: ", translation_path)

			
			file_name = translations_dir.get_next()
		
		translations_dir.list_dir_end()
	else:
		push_error("No se pudo acceder al directorio de traducciones: " + TRANSLATIONS_PATH)

# Establecer el idioma
func set_locale(locale: String) -> void:
	if !supported_locales.has(locale):
		push_warning("Idioma no soportado: " + locale + ". Usando el idioma por defecto.")
		locale = DEFAULT_LOCALE
	
	current_locale = locale
	TranslationServer.set_locale(locale)
	save_settings()
	
	emit_signal("language_changed", locale)
	print("Idioma cambiado a: " + get_language_name(locale))

# Obtener el idioma actual
func get_current_locale() -> String:
	return current_locale

# Obtener el nombre del idioma
func get_language_name(locale: String) -> String:
	if supported_locales.has(locale):
		return supported_locales[locale].name
	return locale

# Obtener la ruta del icono de bandera
func get_flag_icon(locale: String) -> String:
	if supported_locales.has(locale):
		return "res://assets/images/ui/flags/" + supported_locales[locale].flag + ".png"
	return ""

# Obtener lista de idiomas soportados
func get_supported_locales() -> Array:
	var locales = []
	for locale in supported_locales.keys():
		locales.append(locale)
	return locales

# Obtener lista de nombres de idiomas soportados
func get_supported_language_names() -> Array:
	var names = []
	for locale in supported_locales.keys():
		names.append(supported_locales[locale].name)
	return names

# Traducir texto directamente (útil para textos dinámicos)
func translate(text_key: String) -> String:
	return tr(text_key)

# Guardar configuración
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("localization", "locale", current_locale)
	
	var err = config.save("user://language_settings.cfg")
	if err != OK:
		push_error("Error al guardar configuración de idioma: " + str(err))

# Cargar configuración
func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://language_settings.cfg")
	
	if err == OK:
		var saved_locale = config.get_value("localization", "locale", DEFAULT_LOCALE)
		if supported_locales.has(saved_locale):
			current_locale = saved_locale
	else:
		# Intentar detectar el idioma del sistema
		var system_locale = OS.get_locale().substr(0, 2).to_lower()
		if supported_locales.has(system_locale):
			current_locale = system_locale
		else:
			current_locale = DEFAULT_LOCALE

# Función para generar un archivo CSV de traducción base
func generate_translation_csv() -> void:
	if OS.is_debug_build():  # Solo disponible en modo debug
		var csv_content = "keys,es,en\n"  # Encabezado con idiomas
		
		# Añadir entradas del juego
		# Estas son solo ejemplos, en un juego real se extraerían de los textos del juego
		var translations = {
			"GAME_TITLE": ["Chinchón", "Chinchón"],
			"MENU_NEW_GAME": ["Nueva Partida", "New Game"],
			"MENU_SETTINGS": ["Configuración", "Settings"],
			"MENU_EXIT": ["Salir", "Exit"],
			"GAME_YOUR_TURN": ["Tu turno", "Your Turn"],
			"GAME_OPPONENT_TURN": ["Turno de %s", "%s's Turn"],
			"GAME_ROUND": ["Ronda %d", "Round %d"],
			"GAME_DRAW_CARD": ["Robar carta", "Draw Card"],
			"GAME_DISCARD": ["Descartar", "Discard"],
			"GAME_SORT_HAND": ["Ordenar mano", "Sort Hand"],
			"GAME_CHINCHON": ["¡Chinchón!", "Chinchón!"],
			"GAME_WINNER": ["¡%s gana!", "%s wins!"],
			"SETTINGS_MUSIC": ["Música", "Music"],
			"SETTINGS_SFX": ["Efectos", "SFX"],
			"SETTINGS_LANGUAGE": ["Idioma", "Language"],
			"DIALOG_CONFIRM": ["Aceptar", "OK"],
			"DIALOG_CANCEL": ["Cancelar", "Cancel"],
			"HELP_TITLE": ["Ayuda", "Help"],
			"HELP_RULES": ["Reglas del juego", "Game Rules"],
			# Reglas del juego - introducción
			"RULES_INTRO": ["El Chinchón es un juego de cartas en el que debes formar combinaciones antes que tus oponentes.", 
							"Chinchón is a card game where you must form combinations before your opponents."],
			# Reglas del juego - objetivo
			"RULES_GOAL": ["El objetivo es formar grupos o escaleras con todas tus cartas y descartar la última.", 
						  "The goal is to form groups or runs with all your cards and discard the last one."],
			# Reglas - combinaciones
			"RULES_COMBINATIONS": ["Las combinaciones válidas son grupos de 3 o 4 cartas del mismo valor, o escaleras de 3 o más cartas consecutivas del mismo palo.", 
								  "Valid combinations are groups of 3 or 4 cards of the same value, or runs of 3 or more consecutive cards of the same suit."],
			# Más entradas para todas las interfaces y mensajes del juego
		}
		
		# Generar filas CSV
		for key in translations.keys():
			csv_content += key + "," + translations[key][0] + "," + translations[key][1] + "\n"
		
		# Guardar archivo
		var file = FileAccess.open(TRANSLATIONS_PATH + "translation_template.csv", FileAccess.WRITE)
		if file:
			file.store_string(csv_content)
			print("Archivo de traducción generado en: " + TRANSLATIONS_PATH + "translation_template.csv")
		else:
			push_error("No se pudo crear el archivo de traducción")
