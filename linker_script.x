SEARCH_DIR()

//this tells the linker what format to use for input files
//TARGET(bdfname)

//this tells the linker the format of the output file, e.g. BFD, or elf, etc
//OUTPUT_FORMAT(default, big, little)

//define the Cortex-M3 memory regions
MEMORY
{
	FLASH : ORIGIN = 0, 	LENGTH = 500M
	SRAM  : ORIGIN = 500M,	LENGTH = 500M
}

//create aliases for the Cortex-M3 memory regions
//REGION_ALIAS()


//need to place the exception table at address 0

//The Sections command tells the linker how to map input sections into output sections
SECTIONS
{
	ENTRY(_start)
	. = 0x0
	.text . : 
	{_
		_stext = . ; 
		SORT_BY_ALIGNMENT(*(.text)) ; 	//SORT_BY_ALIGNMENT to try and reduce the padding neccessary
		_etext = . ;
	}>FLASH					//Assign the .text section to FLASH memory
	. = 0x8000000;
	.data : { *(.data) } =0x77777777		//Fill unused space with lucky 7's
	.bss : { *(.bss) }
}

