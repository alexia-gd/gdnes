extends Node2D


const PATH := "res://roms/5_Instructions1.nes"

@onready var emulator: NESEmulator = $NESEmulator


func _ready() -> void:
	emulator.filepath = PATH
	emulator.reset()
