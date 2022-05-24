extends VehicleWheel

export var left: bool
export var right: bool

func _ready():
	wheel_friction_slip = get_node("../").traction
