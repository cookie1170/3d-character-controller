extends HSlider

@export var player_var_name : String
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	value = player.get(player_var_name)

func _physics_process(_delta: float) -> void:
	player.set(player_var_name, value)
	player.recalculate_movement()
