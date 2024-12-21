extends HSlider

@export var player_var_name : String

func _ready() -> void:
	value = %Player.get(player_var_name)

func _physics_process(_delta: float) -> void:
	%Player.set(player_var_name, value)
	%Player.recalculate_movement()
