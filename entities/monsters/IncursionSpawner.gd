extends Spatial

export var severity: int
export var spawn: PackedScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var signals_by_severity = [
		"minor",
		"major",
		"boss"
	]
	Heat.connect(signals_by_severity[severity] + "_incursion_begun", self, "do_spawn")

func do_spawn():
	var instance = spawn.instance()
	instance.transform.origin = transform.origin
	get_node("../").add_child(instance)
