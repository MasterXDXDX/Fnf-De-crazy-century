extends Node2D  # Ahora el nodo principal puede ser Node2D

@onready var hit_area: Area2D = get_node("Area2D") as Area2D  # Referencia al hijo Area2D
@onready var Sprite: AnimatedSprite2D = get_node("Icon") as AnimatedSprite2D

func _ready():
	set_process_input(true)


func _input(event):
	if event.is_action_pressed(name):  # Ej: "ui_arriba"
		Sprite.play("active")
		check_note()
	if event.is_action_released(name):
		Sprite.play("default")
		

func check_note():
	# Verifica colisiones en el Area2D hijo
	for note in hit_area.get_overlapping_areas():
		if note.direction == name:
			note.queue_free()
			
			# Añadir puntos: get_node("/root/main").add_score(100)
			break

# Opcional: Para debug (señal del área hijo)
func _on_hit_area_entered(area):
	if area.direction == name:
		print("Nota entró en zona:", name)
