extends Node2D


const PATH := "res://roms/4_TheStack.nes"

@onready var emulator: NESEmulator = $NESEmulator


func _ready() -> void:
	emulator.filepath = PATH
	emulator.reset()
