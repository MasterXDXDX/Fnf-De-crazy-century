extends Node

### CONFIGURACIÓN DE NOTAS ###
var notas_a_generar = []
var next_note_index = 0
@onready var nota_scene = preload("res://Escenas/arriba.tscn")
const DISTANCIA_NOTAS = 620	# Ajusta según tu escena
var tiempo_viaje_nota = DISTANCIA_NOTAS / 500.0	# 500 = velocidad de las notas

### SISTEMA DE PUNTUACIÓN ###
var puntuacion = 0
var combo = 0
var max_combo = 0
var precision = {
	"pene": {"rango": 0.05, "puntos": 100, "texto": "SICK!", "color": Color.GOLD},
	"penes":	{"rango": 0.30, "puntos": 50,	"texto": "GOOD",	"color": Color.ORANGE},
	"pene1":	 {"rango": 0.40, "puntos": 20,	"texto": "SHIT",	 "color": Color.RED},
	"pene2":	{"puntos": 0,	"texto": "MISS!", "color": Color.GRAY}
}

### NODOS ###
@onready var ui_puntuacion = $UI/PuntuacionText
@onready var ui_combo = $UI/ComboText

func _ready():
	cargar_notas_desde_txt("res://chart.txt")
	$Cancion.play()

func cargar_notas_desde_txt(ruta: String):
	var file = FileAccess.open(ruta, FileAccess.READ)
	if not file:
		push_error("Error al cargar el archivo: ", ruta)
		return
	
	while file.get_position() < file.get_length():
		var linea = file.get_line().strip_edges()
		if linea.is_empty() or not " - " in linea:
			continue
		
		var partes = linea.split(" - ")
		if partes.size() == 2:
			notas_a_generar.append([partes[0].to_float(), partes[1]])
	
	file.close()
	print("Notas cargadas: ", notas_a_generar.size())

func _process(delta):
	generar_notas()
	actualizar_ui()

func generar_notas():
	if next_note_index < notas_a_generar.size():
		var tiempo_nota = notas_a_generar[next_note_index][0]
		var tiempo_generacion = tiempo_nota - tiempo_viaje_nota
		
		if $Cancion.get_playback_position() >= tiempo_generacion:
			spawn_note(notas_a_generar[next_note_index][1])
			next_note_index += 1

func spawn_note(direction: String):
	var new_note = nota_scene.instantiate()
	new_note.direction = direction
	
	match direction:
		"Arriba":
			new_note.position = Vector2(150, DISTANCIA_NOTAS)
		"Abajo":
			new_note.position = Vector2(0, DISTANCIA_NOTAS)
		"Izquierda":
			new_note.position = Vector2(-150, DISTANCIA_NOTAS)
		"Derecha":
			new_note.position = Vector2(300, DISTANCIA_NOTAS)
	
	$notas.add_child(new_note)

func _input(event):
	if event.is_action_pressed("Arriba"):
		check_hit("Arriba")
	elif event.is_action_pressed("Abajo"):
		check_hit("Abajo")
	elif event.is_action_pressed("Izquierda"):
		check_hit("Izquierda")
	elif event.is_action_pressed("Derecha"):
		check_hit("Derecha")

func check_hit(direction: String):
	var receptor = $Flechas.get_node(direction)
	var nota_mas_cercana = null
	var distancia_minima = INF
	
	for note in $notas.get_children():
		if note.direction == direction:
			# Cálculo preciso del centro de la nota
			var sprite_nota = note.get_node("Icon")
			var frame_texture = sprite_nota.sprite_frames.get_frame_texture(sprite_nota.animation, sprite_nota.frame)
			var altura_nota = frame_texture.get_height()
			# El centro es position.y + altura/2 (porque Y crece hacia abajo)
			var centro_nota = note.position.y + (altura_nota / 2)
			var centro_receptor = receptor.position.y
			var distancia = abs(centro_nota - centro_receptor)
			
			# Solo considerar notas que estén cerca del receptor (no muy arriba)
			if distancia < distancia_minima and centro_nota >= receptor.position.y - 100:
				distancia_minima = distancia
				nota_mas_cercana = note
	
	if nota_mas_cercana:
		var tiempo_error = distancia_minima / abs(nota_mas_cercana.speed)
		evaluar_precision(tiempo_error, direction)
		nota_mas_cercana.queue_free()
	else:
		registrar_miss(direction)

func evaluar_precision(tiempo_error: float, direction: String):
	var resultado = "miss"
	
	if tiempo_error <= precision["perfect"]["rango"]:
		resultado = "perfect"
	elif tiempo_error <= precision["good"]["rango"]:
		resultado = "good"
	elif tiempo_error <= precision["bad"]["rango"]:
		resultado = "bad"
	
	actualizar_puntuacion(resultado)
	mostrar_feedback(resultado, direction)

func registrar_miss(direction: String):
	actualizar_puntuacion("miss")
	mostrar_feedback("miss", direction)
	if has_node("AudioMiss"):
		$AudioMiss.play()

func actualizar_puntuacion(resultado: String):
	var puntos = precision[resultado]["puntos"]
	
	if resultado != "miss":
		puntuacion += puntos
		combo += 1
		max_combo = max(max_combo, combo)
	else:
		combo = 0

func mostrar_feedback(resultado: String, direction: String):
	var feedback = preload("res://Escenas/Feedback.tscn").instantiate()
	feedback.text = precision[resultado]["texto"]
	feedback.modulate = precision[resultado]["color"]
	feedback.position = $Flechas.get_node(direction).position + Vector2(0, -100)
	add_child(feedback)
	
	if resultado != "bad" and resultado != "miss" and has_node("Audio" + resultado.capitalize()):
		get_node("Audio" + resultado.capitalize()).play()

func actualizar_ui():
	ui_puntuacion.text = str("Score: ", puntuacion)
	ui_combo.text = str("Combo: ", combo)
