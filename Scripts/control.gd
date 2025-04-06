extends Node

# Configuración de notas: [tiempo_en_segundos, "dirección"]
var notas_a_generar = [
	[0.5, "Arriba"],
	[1.0, "Abajo"],
	[1.5, "Izquierda"],
	[2.0, "Derecha"],
	[2.5, "Arriba"],
	[3.0, "Abajo"]
]
var next_note_index = 0
@onready var nota_scene = preload("res://Escenas/arriba.tscn")  # Asegúrate de tener esta escena

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cancion.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if next_note_index < notas_a_generar.size():
		var tiempo_nota = notas_a_generar[next_note_index][0]
		var direccion_nota = notas_a_generar[next_note_index][1]
		
		if $Cancion.get_playback_position() >= tiempo_nota:
			spawn_note(direccion_nota)
			next_note_index += 1

func spawn_note(direction: String):
	var new_note = nota_scene.instantiate()
	new_note.direction = direction
	
	# Posiciones según dirección (ajusta estos valores)
	match direction:
		"Arriba":
			new_note.position = Vector2(150, 320)
		"Abajo":
			new_note.position = Vector2(0, 320)
		"Izquierda":
			new_note.position = Vector2(-150, 320)
		"Derecha":
			new_note.position = Vector2(300, 320)
	
	$notas.add_child(new_note)
	print("Nota generada: ", direction, " en ", $Cancion.get_playback_position(), "s")

func check_hit(direction: String):
	var receptor = $Flechas.get_node(direction)
	for note in $notas.get_children():
		if note.direction == direction and note.global_position.distance_to(receptor.global_position) < 50:
			note.queue_free()
			print("¡Nota golpeada!", direction)
			break
