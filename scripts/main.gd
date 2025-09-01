extends Node2D

@export var customer_scene: PackedScene
@export var base_spawn_interval: float = 1.5
@export var base_customers_per_wave: int = 5
@export var health: int = 3

var score: int = 0
var wave: int = 1
var customers_remaining_to_spawn: int = 0
var customers_remaining: int = 0
var spawning: bool = false
var double_score: bool = false

func _ready() -> void:
	add_to_group("game")
	$SpawnTimer.timeout.connect(_spawn_customer)
	start_wave()

func start_wave() -> void:
	spawning = true
	var spawn_interval = max(0.4, base_spawn_interval - (wave * 0.1)) # faster each wave
	var customers_to_spawn = base_customers_per_wave + (wave - 1) * 2
	
	customers_remaining_to_spawn = customers_to_spawn
	customers_remaining = customers_to_spawn
	print("customers to spawn: %d" % customers_to_spawn)
	print("customers remaining: %d" % customers_remaining)
	
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()
	
	%HealthLabel.text = "Health: %d" % health
	%ScoreLabel.text = "Score: %d" % score
	%WaveLabel.text = "Wave %d" % wave

func _spawn_customer() -> void:
	if customers_remaining_to_spawn <= 0:
		$SpawnTimer.stop()
		spawning = false
		# check if wave ended (all dead)
		_check_wave_clear()
		return

	var c = customer_scene.instantiate()
	var view_w = get_viewport_rect().size.x
	c.global_position = Vector2(randi_range(32, view_w - 32), -32)

	# scale difficulty by wave
	c.speed += wave * 5
	c.health += int(wave / 3)

	add_child(c)
	customers_remaining_to_spawn -= 1
	
	# customer death event
	if not c.died.is_connected(_on_customer_died):
		c.died.connect(_on_customer_died)


func _on_customer_died() -> void:
	customers_remaining -= 1
	_check_wave_clear()

func _check_wave_clear() -> void:
	print(customers_remaining)
	# if no customers left in scene
	if customers_remaining == 0:
		_show_upgrades()

func _show_upgrades():
	%UpgradePanel.visible = true
	%GameOverLabel.visible = false
	%RestartButton.visible = false
	
	var upgrade_pool: Array[Upgrades.UpgradeType] = [
		Upgrades.UpgradeType.FASTER_SHOOT,
		Upgrades.UpgradeType.EXTRA_HEALTH,
		Upgrades.UpgradeType.SPREAD_SHOT,
		Upgrades.UpgradeType.DOUBLE_SHOT,
		Upgrades.UpgradeType.DOUBLE_SCORE,
		Upgrades.UpgradeType.BOUNCING_SHOTS
	]
	
	upgrade_pool.shuffle()
	var choices = upgrade_pool.slice(0, 3)
	
	for i in range(3):
		var btn: Button = %UpgradePanel.get_node("VBoxContainer/UpgradeButton%d" % (i+1))
		btn.text = Upgrades.get_upgrade_name(choices[i])
		btn.set_meta("upgrade_choice", choices[i])
		
		if btn.pressed.is_connected(_on_upgrade_button_pressed):
			btn.pressed.disconnect(_on_upgrade_button_pressed)
		btn.pressed.connect(_on_upgrade_button_pressed.bind(btn))

func _on_upgrade_button_pressed(button: Button):
	var choice = button.get_meta("upgrade_choice")
	Upgrades.apply_upgrade(self, choice)
	%UpgradePanel.visible= false
	wave += 1
	await get_tree().create_timer(1.5).timeout
	start_wave()

func add_score(points: int) -> void:
	if double_score:
		points *= 2
	score += points
	_update_ui()

func take_damage(amount: int) -> void:
	health -= amount
	_update_ui()
	if health <= 0:
		game_over()

func game_over() -> void:
	$SpawnTimer.stop()
	%GameOverLabel.visible = true
	%RestartButton.visible = true
	Engine.time_scale = 0.0

func _update_ui() -> void:
	%HealthLabel.text = "Health: %d" % health
	$%ScoreLabel.text = "Score: %d" % score
	%WaveLabel.text = "Wave %d" % wave

func _on_restart_button_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
