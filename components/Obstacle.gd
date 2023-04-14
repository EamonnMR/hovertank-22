extends Node3D

var obstacle
@onready var parent = get_node("../")
@onready var world = parent.get_node("../")
@export var radius: float = 9
@export var height: float = 20
@export var width: float
@export var square: bool = true

func _ready():
	parent.transform.origin = world.stick_to_ground(global_transform.origin)
	if world.nav_is_ready:
		_setup_obstacle()
	else:
		world.connect("nav_ready",Callable(self,"_setup_obstacle"))

func _setup_obstacle():
	var pos = parent.global_transform.origin - Vector3(0, 1, 0)
	if square:
		obstacle = world.navigation.addBoxObstacle(
			pos,
			Vector3(2 * radius, height, width if width else radius * 2),
			global_transform.basis.get_euler().y
		)
	else:
		obstacle = world.navigation.addCylinderObstacle(pos, radius, height)
	world.navigation.rebuildChangedTiles()
	world.redraw()

func _exit_tree():
	obstacle.destroy()
	world.navigation.rebuildChangedTiles()
	world.redraw()
