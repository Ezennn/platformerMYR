extends OptionButton


@onready var option_button: OptionButton = $"." as OptionButton

var RES_DICT : Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
}

func _ready() :
	add_resolution_items()
	
	
func add_resolution_items() -> void :
	for resolution_size in RES_DICT :
		option_button.add_item(resolution_size)
