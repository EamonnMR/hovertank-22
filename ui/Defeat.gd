extends Control


func _on_Continue_pressed():
	Client.start_level()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Menu_pressed():
	Client.return_to_menu()
