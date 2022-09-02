extends Spatial

export var speed = .2
export var look_sensitivity = .5

var look_enabled : bool = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		if look_enabled:
			rotation.y += deg2rad(-event.relative.x*look_sensitivity)
			rotation.x += deg2rad(-event.relative.y*look_sensitivity)
			rotation.x = clamp(rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		look_enabled = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("menu"):
		look_enabled = !look_enabled
		if look_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var j = Vector2(
		int(Input.is_key_pressed(KEY_D))-int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_W))-int(Input.is_key_pressed(KEY_S))
	)
	
	j = j.normalized()
	
	translate(Vector3(j.x,0,-j.y)*speed);
