extends Control

func _ready():
	visible = true
	get_tree().paused = true

func _on_Start_pressed():
	$"../FadeToBlack".start_game()

func hide():
	$AnimationPlayer.stop()
	visible = false

func _on_Quit_pressed():
	get_tree().quit()

func _on_NewSave_pressed():
	$ConfirmClear.visible = true

func _on_Yes_pressed():
	var dir = Directory.new()
	dir.remove("user://savegame.save")
	$ConfirmClear.visible = false

func _on_No_pressed():
	$ConfirmClear.visible = false
