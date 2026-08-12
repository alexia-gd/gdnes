class_name NESEmulator
extends Node

# Symbols:
# $ = Hex ($0A = literal 10)
# # = Immediate (#22 = literal 22)
# bare = Address (05 = load from address 05)

const TYPE_SIZE_BYTE: int = 0xFF
const TYPE_SIZE_SHORT: int = 0xFFFF

const OPCODE_NAMES: PackedStringArray = [
	"BRK", "ORA", "HLT", "SLO", "NOP", "ORA", "ASL", "SLO", "PHP", "ORA", "ASL", "ANC", "NOP", "ORA", "ASL", "SLO",
	"BPL", "ORA", "HLT", "SLO", "NOP", "ORA", "ASL", "SLO", "CLC", "ORA", "NOP", "SLO", "NOP", "ORA", "ASL", "SLO",
	"JSR", "AND", "HLT", "RLA", "BIT", "AND", "ROL", "RLA", "PLP", "AND", "ROL", "ANC", "BIT", "AND", "ROL", "RLA",
	"BMI", "AND", "HLT", "RLA", "NOP", "AND", "ROL", "RLA", "SEC", "AND", "NOP", "RLA", "NOP", "AND", "ROL", "RLA",
	"RTI", "EOR", "HLT", "SRE", "NOP", "EOR", "LSR", "SRE", "PHA", "EOR", "LSR", "ALR", "JMP", "EOR", "LSR", "SRE",
	"BVC", "EOR", "HLT", "SRE", "NOP", "EOR", "LSR", "SRE", "CLI", "EOR", "NOP", "SRE", "NOP", "EOR", "LSR", "SRE",
	"RTS", "ADC", "HLT", "RRA", "NOP", "ADC", "ROR", "RRA", "PLA", "ADC", "ROR", "ARR", "JMP", "ADC", "ROR", "RRA",
	"BVS", "ADC", "HLT", "RRA", "NOP", "ADC", "ROR", "RRA", "SEI", "ADC", "NOP", "RRA", "NOP", "ADC", "ROR", "RRA",
	"NOP", "STA", "NOP", "SAX", "STY", "STA", "STX", "SAX", "DEY", "NOP", "TXA", "ANE", "STY", "STA", "STX", "SAX",
	"BCC", "STA", "HLT", "SHA", "STY", "STA", "STX", "SAX", "TYA", "STA", "TXS", "SHS", "SHY", "STA", "SHX", "SHA",
	"LDY", "LDA", "LDX", "LAX", "LDY", "LDA", "LDX", "LAX", "TAY", "LDA", "TAX", "LXA", "LDY", "LDA", "LDX", "LAX",
	"BCS", "LDA", "HLT", "LAX", "LDY", "LDA", "LDX", "LAX", "CLV", "LDA", "TSX", "LAS", "LDY", "LDA", "LDX", "LAX",
	"CPY", "CMP", "NOP", "DCP", "CPY", "CMP", "DEC", "DCP", "INY", "CMP", "DEX", "AXS", "CPY", "CMP", "DEC", "DCP",
	"BNE", "CMP", "HLT", "DCP", "NOP", "CMP", "DEC", "DCP", "CLD", "CMP", "NOP", "DCP", "NOP", "CMP", "DEC", "DCP",
	"CPX", "SBC", "NOP", "ISC", "CPX", "SBC", "INC", "ISC", "INX", "SBC", "NOP", "SBC", "CPX", "SBC", "INC", "ISC",
	"BEQ", "SBC", "NOP", "ISC", "NOP", "SBC", "INC", "ISC", "SED", "SBC", "NOP", "ISC", "NOP", "SBC", "INC", "ISC",
]
const OPCODE_OPERAND_COUNT: PackedByteArray = [
	0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	2, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
	1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 2, 2, 2,
	1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 2, 2, 2, 2,
]
const OPCODE_ADDR_SYMBOL: PackedStringArray = [
	"",   "(%s,X)", "",    "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "A", "#%s", "%s",   "%s",   "%s",   "%s",   # $00-$0F
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $10-$1F
	"%s", "(%s,X)", "",    "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "A", "#%s", "%s",   "%s",   "%s",   "%s",   # $20-$2F
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $30-$3F
	"",   "(%s,X)", "",    "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "A", "#%s", "%s",   "%s",   "%s",   "%s",   # $40-$4F
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $50-$5F
	"",   "(%s,X)", "",    "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "A", "#%s", "(%s)", "%s",   "%s",   "%s",   # $60-$6F
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $70-$7F
	"#%s","(%s,X)", "#%s", "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "",  "#%s", "%s",   "%s",   "%s",   "%s",   # $80-$8F
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,Y", "<%s,Y", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,Y", "%s,Y", # $90-$9F
	"#%s","(%s,X)", "#%s", "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "",  "#%s", "%s",   "%s",   "%s",   "%s",   # $A0-$AF
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,Y", "<%s,Y", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,Y", "%s,Y", # $B0-$BF
	"#%s","(%s,X)", "#%s", "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "",  "#%s", "%s",   "%s",   "%s",   "%s",   # $C0-$CF
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $D0-$DF
	"#%s","(%s,X)", "#%s", "(%s,X)", "<%s",   "<%s",   "<%s",   "<%s",   "",  "#%s", "",  "#%s", "%s",   "%s",   "%s",   "%s",   # $E0-$EF
	"%s", "(%s),Y", "",    "(%s),Y", "<%s,X", "<%s,X", "<%s,X", "<%s,X", "",  "%s,Y","",  "%s,Y","%s,X", "%s,X", "%s,X", "%s,X", # $F0-$FF
]

@export var enable_trace_logger: bool = false

var program_counter: int:
	set(v):
		program_counter = v & TYPE_SIZE_SHORT
var stack_pointer: int:
	set(v):
		stack_pointer = v & TYPE_SIZE_BYTE
var address_bus: int:
	set(v):
		address_bus = v & TYPE_SIZE_SHORT
var a: int:
	set(v):
		a = v & TYPE_SIZE_BYTE
var x: int:
	set(v):
		x = v & TYPE_SIZE_BYTE
var y: int:
	set(v):
		y = v & TYPE_SIZE_BYTE

var flag_carry: bool
var flag_zero: bool
var flag_interrupt_disable: bool
var flag_decimal: bool
var flag_overflow: bool
var flag_negative: bool

var header: PackedByteArray
var ram: PackedByteArray
var rom: PackedByteArray

var filepath: String
var cpu_halted: bool = false
var total_cycles: int = 0


func _ready() -> void:
	header.resize(0x10)
	ram.resize(0x800)
	rom.resize(0x8000)


func reset() -> void:
	var headered_rom := FileAccess.get_file_as_bytes(filepath)
	if not headered_rom:
		push_error("Error loading ROM from %s: %s" %
				[filepath, error_string(FileAccess.get_open_error())])
		return
	
	rom = headered_rom.slice(0x10, 0x8010)
	header = headered_rom.slice(0, 0x10)
	
	headered_rom.clear()
	
	flag_interrupt_disable = true
	stack_pointer = 0xFD
	total_cycles = 0
	
	var pcl = read(0xFFFC)
	var pch = read(0xFFFD)
	program_counter = (pch << 8) + pcl
	
	cpu_halted = false
	run()
	pass


func run() -> void:
	tracelogger_header()
	while not cpu_halted:
		emulate_cpu()


func emulate_cpu() -> int:
	var opcode := read(program_counter)
	var cycles := 0
	program_counter += 1
	
	tracelogger(opcode)
	
	match opcode:
		0x00: # BRK
			program_counter += 1
			push(program_counter >> 8)
			push(program_counter)
			push_flags_to_stack()
			var temp_low = read(0xFFFE)
			var temp_high = read(0xFFFF)
			program_counter = (temp_high << 8) | temp_low
			cycles = 7
		0x01: # ORA (Indirect,X)
			read_operands_indirect_addressed()
			op_ora(read(address_bus + x))
			cycles = 6
		0x02: # HLT
			cpu_halted = true
		0x05: # ORA Zero Page
			read_operands_zero_page_addressed()
			op_ora(read(address_bus))
			cycles = 3
		0x08: # PHP
			push_flags_to_stack()
			cycles = 3
		0x09: # ORA Immediate
			op_ora(read(program_counter))
			program_counter += 1
			cycles = 2
		0x0A: # ASL A
			flag_carry = a & 0x80
			a <<= 1
			flag_zero = a == 0
			flag_negative = a & 0x80
			cycles = 2
		0x0D: # ORA Absolute
			read_operands_absolute_addressed()
			op_ora(read(address_bus))
			cycles = 4
		0x0E: # ASL Absolute
			read_operands_absolute_addressed()
			op_asl(address_bus, read(address_bus))
			cycles = 5
		0x10: # BPL
			cycles = branch_on(not flag_negative)
		0x11: # ORA (Indirect),Y
			var old_boundary := address_bus & 0xFF00
			read_operands_indirect_addressed()
			op_ora(read(address_bus + y))
			if old_boundary != address_bus & 0xFF00:
				cycles = 6
			else:
				cycles = 5
		0x15: # ORA Zero Page,X
			read_operands_zero_page_addressed()
			var temp := address_bus + x
			op_asl(temp, read(temp))
			cycles = 4
		0x18: # CLC
			flag_carry = false
			cycles = 2
		0x19: # ORA Absolute,Y
			var old_boundary := address_bus & 0xFF00
			read_operands_absolute_addressed()
			op_ora(read(address_bus + y))
			if old_boundary != address_bus & 0xFF00:
				cycles = 5
			else:
				cycles = 4
		0x1D: # ORA Absolute,X
			var old_boundary := address_bus & 0xFF00
			read_operands_absolute_addressed()
			op_ora(read(address_bus + x))
			if old_boundary != address_bus & 0xFF00:
				cycles = 5
			else:
				cycles = 4
		0x20: # JSR
			var temp_low := read(program_counter)
			program_counter += 1
			push(program_counter >> 8)
			push(program_counter)
			var temp_high := read(program_counter)
			program_counter = (temp_high << 8) + temp_low
			cycles = 6
		0x25: # AND Zero Page
			read_operands_zero_page_addressed()
			op_and(read(address_bus))
			cycles = 5
		0x26: # ROL Zero Page
			read_operands_zero_page_addressed()
			op_rol(address_bus, read(address_bus))
			cycles = 5
		0x28: # PLP
			pull_flags_from_stack()
			cycles = 3
		0x29: # AND Immediate
			op_and(read(program_counter))
			program_counter += 1
		0x2A: # ROL A
			var future_flag_carry := a & 0x80
			a <<= 1
			a |= int(flag_carry)
			flag_carry = future_flag_carry
			flag_zero = a == 0
			flag_negative = a & 0x80
		0x2D: # AND Absolute
			read_operands_absolute_addressed()
			op_and(read(address_bus))
			cycles = 6
		0x2E: # ROL Absolute
			read_operands_absolute_addressed()
			op_rol(address_bus, read(address_bus))
			cycles = 6
		0x30: # BMI
			cycles = branch_on(flag_negative)
		0x38: # SEC
			flag_carry = true
			cycles = 2
		0x40: # RTI
			pull_flags_from_stack()
			var temp_low := pull()
			var temp_high := pull()
			program_counter = (temp_high << 8) | temp_low
			cycles = 6
		0x45: # EOR Zero Page
			read_operands_zero_page_addressed()
			op_eor(read(address_bus))
			cycles = 5
		0x46: # LSR Zero Page
			read_operands_zero_page_addressed()
			op_lsr(address_bus, read(address_bus))
			cycles = 5
		0x48: # PHA
			push(a)
			cycles = 3
		0x49: # EOR Immediate
			op_eor(read(program_counter))
			program_counter += 1
		0x4C: # JMP
			var temp_low := read(program_counter)
			program_counter += 1
			var temp_high := read(program_counter)
			program_counter = (temp_high << 8) + temp_low
			cycles = 3
		0x4D: # EOR Absolute
			read_operands_absolute_addressed()
			op_eor(read(address_bus))
			cycles = 5
		0x4E: # LSR Absolute
			read_operands_absolute_addressed()
			op_lsr(address_bus, read(address_bus))
			cycles = 5
		0x50: # BVC
			cycles = branch_on(not flag_overflow)
		0x58: # CLI
			flag_interrupt_disable = false
			cycles = 2
		0x60: # RTS
			var temp_low := pull()
			var temp_high := pull()
			program_counter = (temp_high << 8) | temp_low
			program_counter += 1
			cycles = 6
		0x66: # ROR Zero Page
			read_operands_zero_page_addressed()
			op_ror(address_bus, read(address_bus))
			cycles = 5
		0x68: # PLA
			a = pull()
			flag_zero = a == 0
			flag_negative = a > 127
			cycles = 4
		0x6A: # ROR A
			var future_flag_carry := a & 0x80
			a >>= 1
			a |= int(flag_carry)
			flag_carry = future_flag_carry
			flag_zero = a == 0
			flag_negative = a & 0x80
		0x6E: # ROR Absolute
			read_operands_absolute_addressed()
			op_ror(address_bus, read(address_bus))
			cycles = 5
		0x70: # BVS
			cycles = branch_on(flag_overflow)
		0x78: # SET
			flag_interrupt_disable = true
			cycles = 2
		0x84: # STY Zero Page
			read_operands_zero_page_addressed()
			write(address_bus, y)
			cycles = 3
		0x85: # STA Zero Page
			read_operands_zero_page_addressed()
			write(address_bus, a)
			cycles = 3
		0x86: # STX Zero Page
			read_operands_zero_page_addressed()
			write(address_bus, x)
			cycles = 3
		0x88: # DEY
			y -= 1
			flag_zero = y == 0
			flag_negative = y > 127
			cycles = 2
		0x8A: # TXA
			a = x
			flag_zero = a == 0
			flag_negative = a > 127
			cycles = 2
		0x8C: # STY Absolute
			read_operands_absolute_addressed()
			write(address_bus, y)
			cycles = 4
		0x8D: # STA Absolute
			read_operands_absolute_addressed()
			write(address_bus, a)
			cycles = 4
		0x8E: # STX Absolute
			read_operands_absolute_addressed()
			write(address_bus, x)
			cycles = 4
		0x90: # BCC
			cycles = branch_on(not flag_carry)
		0x98: # TYA
			a = y
			flag_zero = a == 0
			flag_negative = a > 127
			cycles = 2
		0x9A: # TXS
			stack_pointer = x
			# Does NOT Update zero/negative flags
			cycles = 2
		0xA0: # LDY Immediate
			y = read(program_counter)
			flag_zero = y == 0
			flag_negative = y > 127
			program_counter += 1
			cycles = 2
		0xA2: # LDX Immediate
			x = read(program_counter)
			flag_zero = x == 0
			flag_negative = x > 127
			program_counter += 1
			cycles = 2
		0x4A: # LSR A
			flag_carry = a & 1
			a >>= 1
			flag_zero = a == 0
			flag_negative = a > 0x80
			cycles = 2
		0xA5: # LDA Zero Page
			read_operands_zero_page_addressed()
			a = read(address_bus)
			flag_zero = a == 0
			flag_negative = a > 127
			cycles = 3
		0xA8: # TAY
			y = a
			flag_zero = y == 0
			flag_negative = y > 127
			cycles = 2
		0xA9: # LDA Immediate
			a = read(program_counter)
			flag_zero = a == 0
			flag_negative = a > 127
			program_counter += 1
			cycles = 2
		0xAA: # TAX
			x = a
			flag_zero = x == 0
			flag_negative = x > 127
			cycles = 2
		0xAD: # LDA Absolute
			read_operands_absolute_addressed()
			a = read(address_bus)
			flag_zero = a == 0
			flag_negative = a > 127
			cycles = 4
		0xB0: # BCS
			cycles = branch_on(flag_carry)
		0xB8: # CLV
			flag_overflow = false
			cycles = 2
		0xBA: # TSX
			x = stack_pointer
			flag_zero = x == 0
			flag_negative = x > 127
			cycles = 2
		0xC8: # INY
			y += 1
			flag_zero = y == 0
			flag_negative = y > 127
			cycles = 2
		0xCA: # DEX
			x -= 1
			flag_zero = x == 0
			flag_negative = x > 127
			cycles = 2
		0xD0: # BNE
			cycles = branch_on(not flag_zero)
		0xD8:
			flag_decimal = false
			cycles = 2
		0xE8: # INX
			x += 1
			flag_zero = x == 0
			flag_negative = x > 127
			cycles = 2
		0xEA: # NOP
			cycles = 2
		0xF0: # BEQ
			cycles = branch_on(flag_zero)
		0xF8: # SED
			flag_decimal = true
			cycles = 2
		_:
			push_warning("Unknown opcode 0x%s" % String.num_int64(opcode, 16, true))
			pass
	
	total_cycles += cycles
	return cycles


func op_inc(address: int, input: int) -> void:
	input += 1
	write(address, input)
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_dec(address: int, input: int) -> void:
	input += 1
	write(address, input)
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_ora(input: int) -> void:
	a |= input
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_and(input: int) -> void:
	a &= input
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_eor(input: int) -> void:
	a ^= input
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_adc(input: int) -> void:
	var sum := input + a + int(flag_carry)
	flag_overflow = (~(a ^ input) & (a ^ sum) & 0x80)
	flag_carry = sum > TYPE_SIZE_BYTE
	a = sum
	flag_zero = a == 0
	flag_negative = a & 0x80

func op_sbc(input: int) -> void:
	var sum := a - input - int(not flag_carry)
	flag_overflow = ((a ^ input) & a ^ sum) & 0x80
	flag_carry = sum >= 0
	a = sum
	flag_zero = a == 0
	flag_negative = a & 0x80

func op_asl(address: int, input: int) -> void:
	flag_carry = input & 0x80
	input <<= 1
	write(address, input)
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_rol(address: int, input: int) -> void:
	var future_flag_carry := input & 0x80
	input <<= 1
	input |= int(flag_carry)
	write(address, input)
	flag_carry = future_flag_carry
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_lsr(address: int, input: int) -> void:
	flag_carry = input & 1
	input >>= 1
	write(address, input)
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_ror(address: int, input: int) -> void:
	var future_flag_carry := input & 1
	input >>= 1
	input |= int(flag_carry)
	write(address, input)
	flag_carry = future_flag_carry
	flag_zero = input == 0
	flag_negative = input & 0x80

func op_cmp(input: int) -> void:
	flag_carry = input <= a
	flag_zero = input == a
	flag_negative = ((a - input) & TYPE_SIZE_BYTE) >= 0x80

func op_bit(input: int) -> void:
	flag_zero = not (a & input)
	flag_negative = input & 0x80
	flag_overflow = input & 0x40


func read(address: int) -> int:
	if address < 0x2000:
		# Return ram mirror using only the lower 11 bits of the adress
		return ram[address & 0x7FF]
	
	if address >= 0x8000:
		return rom[address - 0x8000]
	
	return 0

func write(address: int, value: int) -> void:
	if address < 0x2000:
		# Return ram mirror using only the lower 11 bits of the adress
		ram[address & 0x7FF] = value


func push(value: int) -> void:
	write(0x100 + stack_pointer, value)
	stack_pointer -= 1


func pull() -> int:
	stack_pointer += 1
	return read(0x100 + stack_pointer)


func read_operands_zero_page_addressed() -> void:
	address_bus = read(program_counter)
	program_counter += 1

func read_operands_absolute_addressed() -> void:
	var temp_low := read(program_counter)
	program_counter += 1
	var temp_high := read(program_counter)
	program_counter += 1
	address_bus = (temp_high << 8) | temp_low

func read_operands_indirect_addressed() -> void:
	var temp_low := read(program_counter)
	program_counter += 1
	var temp_high := read(program_counter)
	program_counter += 1
	address_bus = (temp_high << 8) | temp_low


func branch_on(flag: bool) -> int:
	var temp := read(program_counter)
	program_counter += 1
	if flag:
		if temp > 127:
			temp -= 256
		
		var old_pc := program_counter
		program_counter += temp
		
		if old_pc & 0xFF00 == program_counter & 0xFF00:
			return 3
		else:
			return 4
	
	return 2


func push_flags_to_stack() -> void:
	var temp := int(flag_carry)
	temp |= int(flag_zero) << 1
	temp |= int(flag_interrupt_disable) << 2
	temp |= int(flag_decimal) << 3
	temp |= 0x30
	temp |= int(flag_overflow) << 6
	temp |= int(flag_negative) << 7
	push(temp)

func pull_flags_from_stack() -> void:
	var temp := pull()
	flag_carry = temp & 1
	flag_zero = temp & 2
	flag_interrupt_disable = temp & 4
	flag_decimal = temp & 8
	flag_overflow = temp & 0x40
	flag_negative = temp & 0x80


func tracelogger_header() -> void:
	if enable_trace_logger:
		print("PC\t\tOP\t\t\t\t\t\tREGISTERS\t\t\t\tSTACK\tFLAGS\t\tCYCLE")


func tracelogger(opcode: int) -> void:
	if not enable_trace_logger:
		return
	
	var line := "$%04X\t%02X %s\t%s\tA: %02X\tX: %02X\tY: %02X\tSP: %02X\t%s\tCy: %d" % [
		program_counter, opcode, _tl_operands(opcode),
		_tl_op_string(opcode),
		a, x, y, stack_pointer, 
		("N" if flag_negative else "n") \
		+ ("V" if flag_overflow else "v") \
		+ "TB" \
		+ ("D" if flag_decimal else "d") \
		+ ("I" if flag_interrupt_disable else "i") \
		+ ("Z" if flag_zero else "z") \
		+ ("C" if flag_carry else "c"),
		total_cycles
	]
	
	print(line)


func _tl_operands(opcode: int) -> String:
	var count := OPCODE_OPERAND_COUNT[opcode]
	
	match count:
		1:
			return String.num_int64(read(program_counter+1), 16, true).lpad(2, "0") \
			+ "   "
		2:
			return String.num_int64(read(program_counter+1), 16, true).lpad(2, "0") \
			+ " " + String.num_int64(read(program_counter+2), 16, true).lpad(2, "0")
		_:
			return "     "

func _tl_op_string(opcode: int) -> String:
	var opname := OPCODE_NAMES[opcode]
	var count := OPCODE_OPERAND_COUNT[opcode]
	var symbol := OPCODE_ADDR_SYMBOL[opcode]
	
	if not count:
		return opname.rpad(9) if not symbol else "%s %s".rpad(9) % [opname, symbol]
	
	var addr: String
	if count == 1:
		addr = "$%02X" % read(program_counter+1)
	else:
		addr = "$%04X" % (read(program_counter+2) << 8 | read(program_counter+1))
	
	return "%s %s" % [opname, symbol % addr]
