extends Control


func _on_Continue_pressed():
	Client.return_to_menu()
	
func _on_Quit_pressed():
	get_tree().quit()
