# Autoload
extends Node

const __ARRAY_SIZE := 1024

var __projectile_arr: Array[Projectile]
var __position_arr: PackedVector3Array
var __origin_arr: PackedVector3Array
var __direction_arr: PackedVector3Array
var __velocity_arr: PackedFloat64Array
var __distance_limit_arr: PackedFloat64Array
var __available_arr: PackedByteArray
var __object_id_arr: Array[PackedInt64Array]
var __damage_arr: PackedFloat64Array
var __pierce_arr: PackedByteArray

@onready var __projectile_holder: Node = Game.inst.projectile_holder

var __entity_mask := Utils.get_3d_physics_layer("entity")

var projectile_scene: PackedScene = preload("res://src/scenes/projectiles/basic_bullet.tscn")

var __last: int

func _ready() -> void:
	__projectile_arr.resize(__ARRAY_SIZE)
	__position_arr.resize(__ARRAY_SIZE)
	__origin_arr.resize(__ARRAY_SIZE)
	__direction_arr.resize(__ARRAY_SIZE)
	__velocity_arr.resize(__ARRAY_SIZE)
	__distance_limit_arr.resize(__ARRAY_SIZE)
	__available_arr.resize(__ARRAY_SIZE)
	__object_id_arr.resize(__ARRAY_SIZE)
	__damage_arr.resize(__ARRAY_SIZE)
	__pierce_arr.resize(__ARRAY_SIZE)
	
	__available_arr.fill(true)
	for i: int in __ARRAY_SIZE:
		__projectile_arr[i] = __create_projectile()


func __create_projectile() -> Projectile:
	var p := projectile_scene.instantiate() as Projectile
	__projectile_holder.add_child(p)
	p.visible = false
	p.set_process(false)
	p.set_physics_process(false)
	p.process_mode = Node.PROCESS_MODE_DISABLED
	return p


func _physics_process(delta: float) -> void:
	var count := __available_arr.count(false)
	if count != __last:
		__last = count
	if count == 0:
		return
	
	var space_state: PhysicsDirectSpaceState3D = Game.inst.game_map.get_world_3d().direct_space_state
	
	var i: int = 0
	while i < __ARRAY_SIZE:
		if __available_arr[i] == int(true):
			i += 1
			continue
		var pos := __position_arr[i]
		var origin := __origin_arr[i]
		var dir := __direction_arr[i]
		var vel := __velocity_arr[i]
		var dist_limit := __distance_limit_arr[i]
		var new_pos: Vector3 = pos + (dir * vel * delta)
		#__projectile_arr[i].global_position = new_pos
		__move(i, new_pos)
		__position_arr[i] = new_pos
		__collide(i, space_state, pos, dir, vel, delta)
		#if new_pos.distance_to(origin) >= dist_limit:
			#__remove_projectile(i)
		if new_pos.distance_to(origin) >= dist_limit:
			__remove_projectile(i)
		i += 1


func __move(i: int, new_pos: Vector3) -> void:
	__projectile_arr[i].global_position = new_pos

func __collide(i: int, space_state: PhysicsDirectSpaceState3D,
		pos: Vector3, dir: Vector3, vel: float, delta: float) -> void:
	var query := PhysicsRayQueryParameters3D.create(pos, pos + (dir * vel * delta), __entity_mask)
	var result := space_state.intersect_ray(query)
	if not result.is_empty():
		if result["collider_id"] in __object_id_arr[i]:
			return
		var entity: Entity = result["collider"]
		entity.take_damage(__damage_arr[i])
		var id: int = result["collider_id"]
		__object_id_arr[i].append(id)
		__pierce_arr[i] -= 1
		if __pierce_arr[i] <= 0:
			__remove_projectile(i)


func fire_projectile(params: ProjectileFireParameters) -> void:
	var index := __get_available_index()
	if index == -1:
		push_error("'index' is -1")
		return
	__position_arr[index] = params.position
	__origin_arr[index] = params.position
	__direction_arr[index] = params.direction
	__velocity_arr[index] = params.velocity
	__distance_limit_arr[index] = params.distance_limit
	__available_arr[index] = false
	__damage_arr[index] = params.damage
	__pierce_arr[index] = params.pierce
	__projectile_arr[index].look_at(params.direction)
	__move(index, params.position)
	__projectile_arr[index].visible = true


func __remove_projectile(index: int) -> void:
	__projectile_arr[index].visible = false
	__projectile_arr[index].global_position = Vector3.ZERO
	__available_arr[index] = true
	__object_id_arr[index].clear()


func __get_available_index() -> int:
	var i := __available_arr.find(true)
	if i > -1:
		return i
	return -1
