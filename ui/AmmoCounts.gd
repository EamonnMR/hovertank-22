extends HBoxContainer


func update_ammo_count(new_ammo_counts, current_special):
	for child in get_children():
		remove_child(child)
	
	# TODO: Display main cannon and secondary with infinity	
	
	for i in range(len(new_ammo_counts)):
		if new_ammo_counts[i] > 0:
			print("i: ", i)
			add_child(_create_tile(i, new_ammo_counts[i], i == current_special))

func _create_tile(special_id: int, count: int, current: bool) -> Node:
	var tile = VBoxContainer.new()
	var icon = TextureRect.new()
	icon.texture = Client.SPECIAL_WEAPONS[special_id].icon_tex

	tile.add_child(icon)
	var text = Label.new()
	text.text = str(count)
	tile.add_child(text)
	if current:
		var background = TextureRect.new()
		background.texture = preload("res://assets/eamonn/darken.png")
		#background.stretch_mode = TextureRect.STRETCH_SCALE
		#background.expand = true
		tile.add_child(background)
		return tile
	return tile
