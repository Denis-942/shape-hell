extends RefCounted
class_name PlayerMovement

var __player: Player


@export var speed_dict: Dictionary[Entity.MoveState, float] = {
	Entity.MoveState.IDLE: 0.0,
	Entity.MoveState.WALKING: 6.0,
	Entity.MoveState.SPRINTING: 10.0,
}

var _input_direction: Vector2


func _init(player: Player) -> void:
	__player = player
	#__camera = __player.camera
	#__orientation = __player.orientation


func owner_physics_process(_delta: float) -> void:
	__handle_orientation()
	__handle_move_state()
	__handle_movement()


func __handle_move_state() -> void:
	_input_direction = Input.get_vector("left", "right", "up", "down")
	if _input_direction == Vector2.ZERO:
		__player.move_state = Entity.MoveState.IDLE
	elif Input.is_action_pressed("sprint"):
		__player.move_state = Entity.MoveState.SPRINTING
	else:
		__player.move_state = Entity.MoveState.WALKING


func __handle_movement() -> void:
	var vel := __player.velocity
	var rot_y: float = -(__player.camera.get_parent() as Node3D).rotation.y
	var input_dir: Vector2 = _input_direction.rotated(rot_y)
	var speed: float = speed_dict[__player.move_state]
	
	__player.velocity = Vector3(speed * input_dir.x, vel.y, speed * input_dir.y)
	
	__player.move_and_slide()


func __handle_orientation() -> void:
	var space_state := __player.get_world_3d().direct_space_state
	var mouse_pos: Vector2 = __player.get_viewport().get_mouse_position()
	var origin := __player.camera.project_ray_origin(mouse_pos)
	var end := origin + __player.camera.project_ray_normal(mouse_pos) * 1000
	var layer := Utils.get_3d_physics_layer("camera_detection")
	var query := PhysicsRayQueryParameters3D.create(origin, end, layer)
	var dict := space_state.intersect_ray(query)
	
	if not dict.is_empty():
		var pos: Vector3 = dict["position"] 
		__player.orientation.look_at(pos)
		__player.orientation.rotation.x = 0
