extends "res://components/abilities/Ability.gd"

export var wall_entity: PackedScene
export var vfx: PackedScene

func activate():
	# TODO: make sure you don't fly right through a star/etc
	var wall_pos = controller.get_aim_point()
	var wall = wall_entity.instance()
	wall.transform.origin = wall_pos
	
	# This isn't really the public API and should be refactored into one
	var turret = parent.get_turrets()[0]
	
	var fx = vfx.instance()
	fx.transform.origin = wall_pos
	
	var world = parent.get_node("../")
	world.add_child(fx)
	world.add_child(wall)
	wall.rotation.y = controller.get_aim_y() + PI/2
