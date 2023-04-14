extends Label

@onready var parent = get_node("../../")

func _process(delta):
	text = "l_bound: " + str(rad_to_deg(parent.l_bound)) + "\n" + \
		"r_bound: " + str(rad_to_deg(parent.r_bound)) + "\n" + \
		"aim: " + str(rad_to_deg(parent.last_aim_input)) + "\n" + \
		"branch: " + parent.cond_branch
