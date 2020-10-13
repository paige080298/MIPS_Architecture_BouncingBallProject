# MMIO Registers
.eqv DISPLAY_CTRL 0xFFFF0000
.eqv DISPLAY_KEYS 0xFFFF0004
.eqv DISPLAY_BASE 0xFFFF0008

# Display stuff
.eqv DISPLAY_W       64
.eqv DISPLAY_H       64
.eqv DISPLAY_W_SHIFT 6

# LED Colors
.eqv COLOR_BLACK   0
.eqv COLOR_RED     1
.eqv COLOR_ORANGE  2
.eqv COLOR_YELLOW  3
.eqv COLOR_GREEN   4
.eqv COLOR_BLUE    5
.eqv COLOR_MAGENTA 6
.eqv COLOR_WHITE   7
.eqv COLOR_NONE    0xFF

# Input key flags
.eqv KEY_NONE 0x00
.eqv KEY_U    0x01
.eqv KEY_D    0x02
.eqv KEY_L    0x04
.eqv KEY_R    0x08
.eqv KEY_B    0x10