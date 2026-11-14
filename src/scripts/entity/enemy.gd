extends Entity
class_name Enemy

@export var rarity_set: RaritySet

@export var _damage: float = 10.0
@export var _speed: float = 1.0
@export var _attack_rate: float = 1.0

@export var _player_detection_area: Area3D
@export var _player_attack_area: Area3D

@export var _player: Player

var _player_in_attack_range: bool = false
var _attack_on_cooldown: bool = false

@export var _mesh: MeshInstance3D
@export var _color: Color


func _ready() -> void:
	_player = Game.inst.player
	_player_detection_area.body_entered.connect(_on_player_detection_area_body_entered)
	_player_attack_area.body_entered.connect(_on_player_attack_area_body_entered)
	_player_attack_area.body_exited.connect(_on_player_attack_area_body_exited)
	_init_visuals()


func _physics_process(delta: float) -> void:
	if position.distance_to(Vector3.ZERO) > 100.0:
		_take_damage(get_max_health())
		print("Out of bounds")
	
	_handle_gravity(delta)
	
	if _player == null:
		move_and_slide()
		return
	
	if _can_attack_player():
		await _attack_player()
	
	var dir: Vector3 = position.direction_to(_player.position)
	#dir.y = velocity.y
	velocity = Vector3(dir.x * _speed, velocity.y, dir.z * _speed)
	look_at(_player.position)
	move_and_slide()



func _die() -> void:
	super._die()
	Game.inst.enemy_died.emit(self)

func _on_player_detection_area_body_entered(body: Node) -> void:
	if body is Player:
		_player = body

func _on_player_attack_area_body_entered(body: Node) -> void:
	if body is Player:
		_player_in_attack_range = true

func _on_player_attack_area_body_exited(body: Node) -> void:
	if body is Player:
		_player_in_attack_range = false


func _attack_player() -> void:
	_player.take_damage(_damage)
	_attack_on_cooldown = true
	#await Utils.delay_s(_attack_rate)
	await get_tree().create_timer(_attack_rate).timeout
	_attack_on_cooldown = false


func _can_attack_player() -> bool:
	return not _attack_on_cooldown and _player_in_attack_range


func _init_visuals() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color.darkened(0.1)
	_mesh.material_override = mat
	health_changed.connect(func(_old: float, new: float) -> void:
		mat.albedo_color = _color.darkened(0.1 + (0.5 * (1.0 - (new / get_max_health()))))
		)
