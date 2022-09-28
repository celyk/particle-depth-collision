extends Spatial

export(NodePath) var target_path
onready var target : Spatial = get_node(target_path)

export var weight = 8

onready var global_orientation : Quat = global_transform.basis.get_rotation_quat()

func _process(dt):
	global_transform = global_transform.interpolate_with(target.global_transform,weight*dt)
	
	# sheesh
	#global_transform.basis = global_transform.basis.slerp(target.global_transform.basis.orthonormalized(),weight).orthonormalized()
	
	#global_orientation = global_orientation.slerp(target.global_transform.basis.get_rotation_quat(),weight)
	#global_transform.basis = global_orientation
	
	#global_translation = global_translation.linear_interpolate(target.global_translation,weight)
