extends Node2D

@export var asteroide_escena: PackedScene

func _on_timer_timeout():
	var a = asteroide_escena.instantiate()
	var tam = get_viewport_rect().size
	var pos = Vector2.ZERO
	match randi() % 4:
		0: pos = Vector2(randf_range(0, tam.x), -50)
		1: pos = Vector2(randf_range(0, tam.x), tam.y + 50)
		2: pos = Vector2(-50, randf_range(0, tam.y))
		3: pos = Vector2(tam.x + 50, randf_range(0, tam.y))
	a.global_position = pos
	var objetivo = Vector2(randf_range(0, tam.x), randf_range(0, tam.y))
	a.linear_velocity = (objetivo - pos).normalized() * randf_range(80, 250)
	add_child(a)
