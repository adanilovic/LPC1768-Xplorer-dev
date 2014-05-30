SEARCH_DIR()

ENTRY(_start)

SECTIONS
{
	. = 0x0
	.text : { *(.text) }
	. = 0x8000000;
	.data : { *(.data) }
	.bss : { *(.bss) }
}

