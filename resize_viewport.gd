extends Viewport

func _ready():
	size = get_tree().get_root().size
	get_tree().get_root().connect("size_changed", self, "size_changed")
	
func size_changed():
	size = get_tree().get_root().size
