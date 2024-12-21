extends Label

@export var text1 : String
@export var h_slider : HSlider


func _process(_delta: float) -> void:
	text = text1 + " " + str(h_slider.value)
