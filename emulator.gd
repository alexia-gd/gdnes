class_name NES
extends Node


const SIZE_BYTE: int = 0xFF
const SIZE_SHORT: int = 0xFFFF


var program_counter: int:
	set(v):
		program_counter = v & SIZE_SHORT
var a: int:
	set(v):
		a = v & SIZE_BYTE
var x: int:
	set(v):
		x = v & SIZE_BYTE
var y: int:
	set(v):
		y = v & SIZE_BYTE
