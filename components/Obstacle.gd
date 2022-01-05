extends Spatial

var obstacle
var world
var parent

export var radius: float = 9
export var height: float = 20
export var square: bool = true

func _ready():
	parent = get_node("../")
	world = parent.get_node("../")
	parent.transform.origin = world.stick_to_ground(global_transform.origin)
	world.connect("nav_ready", self, "_setup_obstacle")

func _setup_obstacle():
	var pos = parent.global_transform.origin - Vector3(0, 1, 0)
	if square:
		obstacle = world.navigation.addBoxObstacle(
			pos,
			Vector3(2 * radius, height, 2 * radius),
			global_transform.basis.get_euler().x
		)
	else:
		obstacle = world.navigation.addCylinderObstacle(pos, radius, height)
	world.navigation.rebuildChangedTiles()
	world.redraw()

func _exit_tree():
	obstacle.destroy()
	world.navigation.rebuildChangedTiles()
	world.redraw()
