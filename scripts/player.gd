class_name Player extends CharacterBody2D

# Stats
@export_category("Stats")
@export var max_health: int = 3
@export var move_speed: float = 360.0
@export var fire_rate: float = 0.5

@export var projectile_scene: PackedScene
@export var muzzle_offset: Vector2 = Vector2(0, -24)

# Flag Modifiers
var has_spread: bool = false
var has_doubleshot: bool = false
var has_bounce: bool = false
var has_pierce: bool = false
var max_pierce_count: int = 0
var has_explosive: bool = false
var has_shield: bool = false

var current_health: int
var _can_shoot := true
var _floor_y: float

func _ready() -> void:
	# Remember the Y where you place the player in the main scene
	_floor_y = position.y
	current_health = max_health

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
	if DevUtilities.aimbot:
		_process_aimbot()
		
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
	await get_tree().create_timer(fire_rate).timeout
	_can_shoot = true

func _spawn_projectile(angle_deg: float) -> void:
	var p: Node2D = projectile_scene.instantiate()
	p.global_position = global_position + muzzle_offset
	add_sibling(p)
	p.rotation_degrees = angle_deg
	if has_bounce and p.has_method("enable_bounce"):
		p.enable_bounce()
		

func set_fire_rate(cooldown: float) -> void:
	fire_rate = cooldown

func get_fire_rate() -> float:
	return fire_rate

func _process_aimbot() -> void:
	var enemies = get_tree().get_nodes_in_group("customers")
	if enemies.is_empty():
		return
	
	var closest = null
	var closest_dist = INF
	for e in enemies:
		var dist = global_position.distance_squared_to(e.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = e
	
	if closest:
		global_position.x = closest.global_position.x
