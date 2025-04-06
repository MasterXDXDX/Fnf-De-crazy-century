extends Node2D
var speed = -200
var direction

func _process(delta: float) -> void:
	$Icon.play(direction)
	position.y += speed * delta
