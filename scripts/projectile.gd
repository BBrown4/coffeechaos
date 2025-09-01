extends Area2D

@export var speed: float = 720.0
@export var despawn_margin: float = 48.0

var can_bounce: bool = false
var bounced: bool = false

func enable_bounce() -> void:
	can_bounce = true

func _physics_process(delta: float) -> void:
	var dir = Vector2.UP.rotated(rotation)
	position += dir * speed * delta
	
	var view_rect = get_viewport_rect()
	
	if can_bounce:
		if (position.x < 0 or position.x > view_rect.size.x) and not bounced:
			rotation = -rotation
			bounced = true
			
	if position.y < -despawn_margin:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
