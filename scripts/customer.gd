extends CharacterBody2D

signal died

@export var speed: float = 120.0
@export var health: int = 2

func _physics_process(delta: float) -> void:
	velocity.y = speed
	move_and_slide()

	var view_h := get_viewport_rect().size.y
	if position.y > view_h - 32:
		get_tree().call_group("game", "take_damage", 1)
		die()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		get_tree().call_group("game", "add_score", 10)
		die()

func die():
	if is_queued_for_deletion():
		return
		
	died.emit()
	queue_free()
