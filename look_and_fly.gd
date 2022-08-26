extends Spatial

export var speed = .2
export var look_sensitivity = .5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y += deg2rad(-event.relative.x*look_sensitivity)
		rotation.x += deg2rad(-event.relative.y*look_sensitivity)
		rotation.x = clamp(rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	var j = Vector2(
		int(Input.is_key_pressed(KEY_D))-int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_W))-int(Input.is_key_pressed(KEY_S))
	)
	
	j = j.normalized()
	
	translate(Vector3(j.x,0,-j.y)*speed);
