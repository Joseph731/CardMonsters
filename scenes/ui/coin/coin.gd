extends TextureButton

signal flipped(landed_on_heads: bool)

const COIN_MENU = preload("uid://ciwptexorncn3")

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	var coin_menu: CoinMenu = COIN_MENU.instantiate()
	coin_menu.flip_pressed.connect(_on_flip_pressed)
	get_parent().menu_container.add_child(coin_menu)
	coin_menu.center_container.global_position = global_position + size/2

func _on_flip_pressed():
	flipped.emit(randf() < 0.5)
