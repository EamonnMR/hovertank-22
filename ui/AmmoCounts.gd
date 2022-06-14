extends HBoxContainer


func update_ammo_count(new_ammo_counts):
	for child in get_children():
		remove_child(child)
	
	# TODO: Display main cannon and secondary with infinity	
	
	for i in range(len(new_ammo_counts)):
		if new_ammo_counts[i] > 0:
			print("i: ", i)
			add_child(_create_tile(i, new_ammo_counts[i]))

func _create_tile(special_id: int, count: int) -> Node:
	var tile = VBoxContainer.new()
	var icon = TextureRect.new()
	icon.texture = Client.SPECIAL_WEAPONS[special_id].icon_tex
	tile.add_child(icon)
	var text = Label.new()
	text.text = str(count)
	tile.add_child(text)
	return tile
