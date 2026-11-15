extends CharacterBody2D

signal vidas_cambiadas(vidas: int)
signal nave_destruida

const SPEED := 300.0
const VELOCIDAD_ROTACION := 10.0
const VELOCIDAD_LASER := 700.0
const ALCANCE_LASER := 900.0
const COOLDOWN_DISPARO := 0.2
const VIDAS_MAX := 3
const TIEMPO_INVULNERABLE := 1.5

var vidas := VIDAS_MAX
var invulnerable := false
var puede_disparar := true


func _physics_process(delta: float) -> void:
	# Movimiento horizontal
	var direction := Input.get_axis("A", "D")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Movimiento vertical
	var direction_vertical := Input.get_axis("W", "S")
	if direction_vertical:
		velocity.y = direction_vertical * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Rotación hacia donde se mueve
	if velocity.length() > 10.0:
		var angulo_objetivo := velocity.angle() + PI / 2
		rotation = lerp_angle(rotation, angulo_objetivo, VELOCIDAD_ROTACION * delta)

	# Disparo con la barra espaciadora
	if Input.is_physical_key_pressed(KEY_SPACE) and puede_disparar:
		disparar()

	move_and_slide()


func disparar() -> void:
	puede_disparar = false

	var direccion := Vector2.UP.rotated(rotation)

	# Disparo: un Area2D creado por código
	var laser := Area2D.new()
	laser.rotation = rotation

	# Forma de colisión
	var forma := CollisionShape2D.new()
	var rectangulo := RectangleShape2D.new()
	rectangulo.size = Vector2(6, 24)
	forma.shape = rectangulo
	forma.position = Vector2(0, -12)
	laser.add_child(forma)

	# Dibujo del láser
	var linea := Line2D.new()
	linea.width = 5.0
	linea.default_color = Color(1.0, 0.2, 0.2)
	linea.points = PackedVector2Array([Vector2.ZERO, Vector2(0, -24)])
	laser.add_child(linea)

	# Al tocar un asteroide, se destruyen los dos
	laser.body_entered.connect(func(cuerpo: Node2D) -> void:
		if cuerpo.is_in_group("asteroides"):
			cuerpo.queue_free()
			laser.queue_free()
	)

	get_parent().add_child(laser)
	laser.global_position = global_position + direccion * 30.0

	# Movimiento: viaja hacia adelante y se borra al final
	var destino := laser.position + direccion * ALCANCE_LASER
	var tween := laser.create_tween()
	tween.tween_property(laser, "position", destino, ALCANCE_LASER / VELOCIDAD_LASER)
	tween.tween_callback(laser.queue_free)

	await get_tree().create_timer(COOLDOWN_DISPARO).timeout
	puede_disparar = true


func recibir_dano() -> void:
	if invulnerable:
		return

	vidas -= 1
	print("Vidas: ", vidas)
	vidas_cambiadas.emit(vidas)

	if vidas <= 0:
		nave_destruida.emit()
		queue_free()
		return

	invulnerable = true

	# Parpadeo visual
	var tween := create_tween().set_loops(5)
	tween.tween_property(self, "modulate:a", 0.3, 0.15)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

	await get_tree().create_timer(TIEMPO_INVULNERABLE).timeout
	modulate.a = 1.0
	invulnerable = false
