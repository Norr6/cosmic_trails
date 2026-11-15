extends RigidBody2D

var max_rebotes = 3
var rebotes = 0
var dentro = false

func _ready():
	add_to_group("asteroides")
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	if not dentro:
		var area = get_viewport_rect().grow(-60)
		if area.has_point(global_position):
			dentro = true
			set_collision_mask_value(3, true)

func _on_body_entered(body):
	if body is StaticBody2D:
		if rebotes >= max_rebotes:
			set_collision_mask_value(3, false) 
			
		rebotes += 1


		
func _on_visible_on_screen_notifier_2d_screen_exited():
		queue_free()




func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Area2D tocó: ", body.name)
	if body.has_method("dando_dano"):
		body.recibir_dano()
