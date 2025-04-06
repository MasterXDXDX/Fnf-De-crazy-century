extends Node2D
var speed = -500
var direction

func _process(delta: float) -> void:
	$Icon.play(direction)
	position.y += speed * delta
