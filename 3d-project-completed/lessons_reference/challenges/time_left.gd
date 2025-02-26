extends Label

# You can use a signal like this to notify other nodes when the timer ended
# and, for example, hide the player's reticle, despawn mobs, and more.
signal timer_ended

@onready var timer = %Timer
@onready var label = %Label
@onready var color_rect = %ColorRect


func _ready():
	label.hide()
	color_rect.hide()


func _process(delta):
	text = "Time left: " + str(round(timer.time_left))


func _on_timer_timeout():
	get_tree().paused = true
	label.show()
	color_rect.show()
	timer_ended.emit()
