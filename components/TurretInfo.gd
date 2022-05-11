extends Label

func _process(delta):
	var aim_pose = get_node("../../").aim_pose
	text = "Yaw: " + str(aim_pose.x) + "\n" + "Pitch: " + str(aim_pose.y)
