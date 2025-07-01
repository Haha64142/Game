extends Node

var seconds := 0.0
var paused := true

func _process(delta: float) -> void:
	if paused:
		return
	seconds += delta


func start(start_time := 0.0):
	seconds = start_time
	paused = false
