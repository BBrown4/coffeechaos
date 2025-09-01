class_name Player extends CharacterBody2D


@export var move_speed: float = 360.0
@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 0.22
@export var muzzle_offset: Vector2 = Vector2(0, -24)

var has_spread: bool = false
var has_doubleshot: bool = false
var has_bounce: bool = false

var _can_shoot := true
var _floor_y: float

func _ready() -> void:
	# Remember the Y where you place the player in the main scene
	_floor_y = position.y

func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * move_speed
	velocity.y = 0.0
	move_and_slide()

	# keep player on screen & locked to floor y
	var view_w := get_viewport_rect().size.x
	position.x = clamp(position.x, 16.0, view_w - 16.0)
	position.y = _floor_y
	
	if Input.is_action_pressed("shoot") and _can_shoot:
		_shoot()

func _shoot() -> void:
	if projectile_scene == null:
		push_warning("Projectile scene not assigned on Player.")
		return
	
	if has_spread:
		for angle in [-10, 0, 10]:
			_spawn_projectile(angle)
	elif has_doubleshot:
		_spawn_projectile(-5)
		_spawn_projectile(5)
	else:
		_spawn_projectile(0)

	_can_shoot = false
	await get_tree().create_timer(shoot_cooldown).timeout
	_can_shoot = true

func _spawn_projectile(angle_deg: float) -> void:
	var p: Node2D = projectile_scene.instantiate()
	p.global_position = global_position + muzzle_offset
	add_sibling(p)
	p.rotation_degrees = angle_deg
	if has_bounce and p.has_method("enable_bounce"):
		p.enable_bounce()
		

func set_shoot_cooldown(cooldown: float) -> void:
	shoot_cooldown = cooldown

func get_shoot_cooldown() -> float:
	return shoot_cooldown
