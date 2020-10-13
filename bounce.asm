# CHH182
# ChingWei Hsieh

.include "constants.asm"
.include "convenience.asm"

.eqv GAME_TICK_MS 16

.eqv GRAV        0x0003 # (24.8) 0.01171875 (I just played with the number)
.eqv THRUST_X    0x000A # (24.8) 0.0390625
.eqv THRUST_Y    0x000A # (24.8) 0.0390625

.eqv XVEL_MIN   -0x0300 # (24.8) -3.0
.eqv XVEL_MAX    0x0300 # (24.8) 3.0

.eqv YVEL_MIN   -0x0300 # (24.8) -3.0
.eqv YVEL_MAX    0x0300 # (24.8) 3.0

.eqv X_MIN       0
.eqv X_MAX       0x3B00 # (24.8) 59

.eqv Y_MIN       0
.eqv Y_MAX       0x3B00 # (24.8) 59

.eqv RESTITUTION 0x00C0 # (24.8) 0.75

.data
ball_x:    .word 0x1D00 # (24.8) x position [X_MIN .. X_MAX]
ball_y:    .word 0x1D00 # (24.8) y position [Y_MIN .. Y_MAX]
ball_xvel: .word 0      # (24.8) x velocity [XVEL_MIN .. XVEL_MAX]
ball_yvel: .word 0      # (24.8) y velocity [YVEL_MIN .. YVEL_MAX]
.text

# -------------------------------------------------------------------------------------------------

.globl main
main:

_main_loop:
	# check for input,
	jal	check_input

	# update everything,
	jal	ball_motion
	jal	ball_collision

	# then draw everything.
	jal	draw_ball
	jal	display_update_and_clear

	# wait for next frame and loop.
	li	a0, GAME_TICK_MS
	jal	wait_for_next_frame
	j	_main_loop

_game_over:
	exit

# -------------------------------------------------------------------------------------------------
# clamp(val: a0, lo: a1, hi: a2)
#   returns val clamped to range [lo, hi] (inclusive both ends)
clamp:
enter
	# if(value < lo) return lo
	# else if(value > hi) return hi
	# else return value
	move	v0, a0
	bge	a0, a1, _clamp_check_hi
	move	v0, a1
	j	_clamp_exit
_clamp_check_hi:
	ble	a0, a2, _clamp_exit
	move	v0, a2
_clamp_exit:
leave

# -------------------------------------------------------------------------------------------------

check_input:

enter

        enter
        jal	input_get_keys
        leave
        and     t0, v0, KEY_L
        bne     t0, 0, dot_x_minus
        
        enter
        jal	input_get_keys
        leave
        and     t0, v0, KEY_R
        bne     t0, 0, dot_x_plus
        
        enter
        jal	input_get_keys
        leave
        and     t0, v0, KEY_U
        bne     t0, 0, dot_y_minus
        
        enter
        jal	input_get_keys
        leave       
        and     t0, v0, KEY_D
        bne     t0, 0, dot_y_plus




leave
# -------------------------------------------------------------------------------------------------

dot_x_minus:
        enter
        lw	a0, ball_xvel
        sub    a0, a0, THRUST_X
        and     a0, a0, 0x003F
        sw      a0, ball_xvel
	leave


dot_x_plus:
        enter
        lw	a0, ball_xvel
        add    a0, a0, THRUST_X
        and     a0, a0, 0x003F
        sw      a0, ball_xvel
	leave

dot_y_plus:
        enter
        lw	a0, ball_yvel
        add    a0, a0, THRUST_Y
        and     a0, a0, 0x003F
        sw      a0, ball_yvel
	leave

dot_y_minus:
        enter
        lw	a0, ball_yvel
        sub    a0, a0, THRUST_Y
        and     a0, a0, 0x003F
        sw      a0, ball_yvel
	leave










ball_motion:
enter

        lw	a0, ball_yvel
        add    a0, a0, GRAV
        sw      a0, ball_yvel
        #ball_xvel = clamp(ball_xvel, XVEL_MIN, XVEL_MAX)
        lw	a0, ball_xvel
	li	a1, XVEL_MIN
	li	a2, XVEL_MAX
	jal	clamp
	sw	v0, ball_xvel
	
        #ball_yvel = clamp(ball_yvel, YVEL_MIN, YVEL_MAX)
        lw	a0, ball_yvel
	li	a1, YVEL_MIN
	li	a2, YVEL_MAX
	jal	clamp
	sw	v0, ball_yvel       
        
        lw	a0, ball_x
	lw	a1, ball_xvel
        add    a0, a0, a1
        sw     a0, ball_x
        
        lw	a0, ball_y
        lw	a1, ball_yvel
        add    a0, a0, a1
        sw     a0, ball_y
 
leave

# -------------------------------------------------------------------------------------------------

ball_collision:
enter
        lw	a0, ball_x
        ble a0, X_MIN, bumpx
        
        lw	a0, ball_x
        bge a0, X_MAX, bumpx
        
        lw	a0, ball_x
	lw	a1, ball_y
        ble a1, Y_MIN, bumpy
        
        lw	a0, ball_x
	lw	a1, ball_y
        bge a1, Y_MAX, bumpy
leave

#--------------------------------------------------------------------------------------------------

bumpx:

enter

        #ball_xvel = clamp(ball_xvel, XVEL_MIN, XVEL_MAX)
        lw	a0, ball_x
	li	a1, X_MIN
	li	a2, X_MAX
	jal	clamp
	sw	v0, ball_x
	
	

	lw	a0, ball_xvel
	neg     a0, a0
	mulu    a0, a0, RESTITUTION
	sra     a0, a0, 8 
	sw      a0, ball_xvel


leave

bumpy:

enter

        #ball_xvel = clamp(ball_xvel, XVEL_MIN, XVEL_MAX)
        lw	a0, ball_y
	li	a1, Y_MIN
	li	a2, Y_MAX
	jal	clamp
	sw	v0, ball_y
	
	lw	a0, ball_yvel
	neg     a0, a0
	mulu    a0, a0, RESTITUTION
	sra     a0, a0, 8 
	sw      a0, ball_yvel

leave
# -------------------------------------------------------------------------------------------------

.data
ball_pattern:
	.byte 0 7 7 7 0
	.byte 7 7 7 7 7
	.byte 7 7 7 7 7
	.byte 7 7 7 7 7
	.byte 0 7 7 7 0
.text
draw_ball:
enter
	lw	a0, ball_x
	srl	a0, a0, 8
	lw	a1, ball_y
	srl	a1, a1, 8
	la	a2, ball_pattern
	jal	display_blit_5x5
leave


       