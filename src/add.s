.cpu cortex-m3
.thumb

.equiv __stack, 0x200

.text
.org 0

#.section RESET_VECTOR_TABLE, "dr"
.section RESET_VECTOR_TABLE

.word	__stack
.word	_start
.word	inf_loop
.word	inf_loop
.word	inf_loop

inf_loop: b inf_loop

.end #end of the src file.
