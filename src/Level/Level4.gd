extends Node2D

var crate = preload("res://src/Prop/Crate.tscn")

func spawn_crate():
	$CratePos.add_child(crate.instance())
