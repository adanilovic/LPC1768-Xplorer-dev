TARGET=target
CC=arm-unknown-eabi-gcc
AS=arm-unknown-eabi-as
LINKER=arm-unknown-eabi-ld
OBJDUMP=arm-unknown-eabi-objdump
SYMBOLDUMP=arm-unknown-eabi-nm
DISS_EXT=.dis
DISS_DIR=disassembly
COMPILEFLAGS=-c
ODIR=obj
DEPDIR=dep
SRCDIR=src
INCDIR=inc
MAKEFILE=makefile
INCLUDES:=$(wildcard $(INCDIR)/*.hpp)
CPPSRC:=$(wildcard $(SRCDIR)/*.c)
CPPOBJS:=$(patsubst $(SRCDIR)/%.c,$(ODIR)/%.o,$(CPPSRC))
ASSRC:=$(wildcard $(SRCDIR)/*.s)
ASOBJS:=$(patsubst $(SRCDIR)/%.s,$(ODIR)/%.o,$(ASSRC))
DEPS:=$(patsubst $(SRCDIR)/%.c,$(DEPDIR)/%.d,$(CPPSRC))
DISS:=$(patsubst $(SRCDIR)/%.c,$(DISS_DIR)/%.dis,$(CPPSRC))

#/home/dman/x-tools/arm-unknown-eabi/lib/gcc/arm-unknown-eabi/4.3.4/libgcc.a \

#include --static and the -static in the library to link statically
#remove these to link with the shared libraries dyamically
#LIBS=~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/crt0.o             \ 
     #~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/libstdc++.a        \
     #~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/libsupc++.a        \
     #~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/libg.a             \
     #~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/libm.a             \
     #~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/librdimon.a        \
     #~/x-tools/arm-unknown-eabi/lib/gcc/arm-unknown-eabi/4.3.4/crti.o

LIBS=~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/crt0.o             \
     ~/x-tools/arm-unknown-eabi/arm-unknown-eabi/lib/libg.a             \
     ~/x-tools/arm-unknown-eabi/lib/gcc/arm-unknown-eabi/4.3.4/crti.o


#rule for a target
CURRENT_CPP_TARGET=$(patsubst $(ODIR)/%.o, $(SRCDIR)/%.c, $@)
CURRENT_AS_TARGET=$(patsubst $(ODIR)/%.o, $(SRCDIR)/%.s, $@)

#default target
all: $(TARGET) 

include $(DEPS) 

#specify rule for each object file
#each object file is dependent on all src and header files
#even if not included, just to make things simpler for now
$(CPPOBJS): 
	$(CC) -Wall -I$(INCDIR) -c $(CURRENT_CPP_TARGET) -o $@
	$(OBJDUMP) -h $@ > ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -t $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -s $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -d $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	@echo "\n-----------------Symbol Dump-----------------" >> \
		./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(SYMBOLDUMP) $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)

$(ASOBJS):
	$(AS) $(CURRENT_AS_TARGET) -o $@
	$(OBJDUMP) -h $@ > ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -t $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -s $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(OBJDUMP) -d $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	@echo "\n-----------------Symbol Dump-----------------" >> \
		./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)
	$(SYMBOLDUMP) $@ >> ./$(DISS_DIR)/$(subst $(ODIR)/,,$*)$(DISS_EXT)

#link all object files to create executable
$(TARGET): $(CPPOBJS) $(ASOBJS)
	@echo
	#the -M option generates a map file
	$(LINKER) -o $@ $(CPPOBJS) $(ASOBJS) $(LIBS) -M --verbose -nostartfiles -nostdlib -nodefaultlibs > Map.m
	#after linking, run the above objdump and nm dump programs on this object file, to get the full dissembly

#in bash, $$ means expand to shell process ID.
#This guarantees uniqueness of a file name
$(DEPDIR)/%.d: $(SRCDIR)/%.c
	@echo "Building dependencies for $@"
	@set -e; rm -f $@; \
	$(CC) -MM -MT $(ODIR)/$*.o  -I$(INCDIR) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

.PHONY: tool_ver
tool_ver:
	@echo
	$(CC) -v
	@echo

TEST_VAR=obj/main.o
.PHONY: print_vars
print_vars:
	@echo
	@echo $(CPPOBJS)
	@echo $(SRCDIR)
	@echo $(CPPSRC)
	@echo $(INCLUDES)
	@echo $(SRCDIR)/%.cpp
	@echo $(DEPS)
	@echo $(subst $(ODIR)/, ,$(TEST_VAR))
	@echo

.PHONY: clean
clean: 
	rm -f $(TARGET) \
	$(CPPOBJS) 	\
	$(ASOBJS)	\
	$(DEPS)		\
	$(DISS);

#The vpath directive only controls how Make finds dependencies; it doesn't affect in any way how GCC works. If you have headers in some other directory, you explicitly need to tell GCC with -I:
#INCLUDE := include
#$(CC) -I$(INCLUDE) $c $< -o $@
