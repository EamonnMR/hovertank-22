extends Spatial

var obstacle
var world
var parent
export var radius: float = 4.5 # Values above this tend to break the pathing system
export var height: float = 10

func _ready():
	parent = get_node("../")
	world = parent.get_node("../")
	parent.transform.origin = world.stick_to_ground(global_transform.origin)
	world.connect("nav_ready", self, "_setup_obstacle")

func _setup_obstacle():
	#obstacle = world.navigation.addBoxObstacle(
	#	global_transform.origin - Vector3(0, 1, 0),
	#	Vector3(8, 16, 8),
	#	global_transform.basis.get_euler().x
	#)
	obstacle = world.navigation.addCylinderObstacle(parent.global_transform.origin, 4.5, 10)
	world.navigation.rebuildChangedTiles()
	world.redraw()

func _exit_tree():
	obstacle.destroy()
	world.navigation.rebuildChangedTiles()
	world.redraw()
