extends Node2D

@export var text := "":
	set(value):
		text = value
		if $Label:  # Asegúrate de que el Label se llama así
			$Label.text = text

func _ready():
	$AnimationPlayer.play("aparecer")
	await $AnimationPlayer.animation_finished
	queue_free()  # Se autodestruye después de la animación
