RUSTC=$(HOME)/.local/bin/rustc

LLC=$(HOME)/Code/Git/rust/llvm/x86_64-apple-darwin/Release+Asserts/bin/llc

# Put your source files here (or *.c, etc)
C_SRCS = zero/zero.c

# Binaries will be generated with this name (.elf, .bin, .hex, etc)
PROJ_NAME=blinky

# Normally you shouldn't need to change anything below this line!
#######################################################################################

AR=hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-ar
CC=hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-gcc
CXX=hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-g++
OBJCOPY=hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-objcopy

C_SRCS += hardware/arduino/sam/cores/arduino/cortex_handlers.c hardware/arduino/sam/cores/arduino/hooks.c hardware/arduino/sam/cores/arduino/itoa.c hardware/arduino/sam/cores/arduino/WInterrupts.c hardware/arduino/sam/cores/arduino/wiring.c hardware/arduino/sam/cores/arduino/wiring_analog.c hardware/arduino/sam/cores/arduino/wiring_digital.c hardware/arduino/sam/cores/arduino/wiring_shift.c hardware/arduino/sam/cores/arduino/iar_calls_sam3.c hardware/arduino/sam/cores/arduino/syscalls_sam3.c

CPP_SRCS = hardware/arduino/sam/cores/arduino/cxxabi-compat.cpp hardware/arduino/sam/cores/arduino/IPAddress.cpp hardware/arduino/sam/cores/arduino/main.cpp hardware/arduino/sam/cores/arduino/Print.cpp hardware/arduino/sam/cores/arduino/Reset.cpp hardware/arduino/sam/cores/arduino/RingBuffer.cpp hardware/arduino/sam/cores/arduino/Stream.cpp hardware/arduino/sam/cores/arduino/UARTClass.cpp hardware/arduino/sam/cores/arduino/USARTClass.cpp hardware/arduino/sam/cores/arduino/USB/CDC.cpp hardware/arduino/sam/cores/arduino/USB/HID.cpp hardware/arduino/sam/cores/arduino/USB/USBCore.cpp hardware/arduino/sam/cores/arduino/wiring_pulse.cpp hardware/arduino/sam/cores/arduino/WMath.cpp hardware/arduino/sam/cores/arduino/WString.cpp hardware/arduino/sam/variants/arduino_due_x/variant.cpp

CFLAGS  = -g -O0 -Wall -nostdlib -mthumb -mcpu=cortex-m3
CFLAGS += -Ihardware/arduino/sam/system/libsam -Ihardware/arduino/sam/system/CMSIS/CMSIS/Include/
CFLAGS += -Ihardware/arduino/sam/system/CMSIS/Device/ATMEL/ -Ihardware/arduino/sam/cores/arduino
CFLAGS += -Ihardware/arduino/sam/variants/arduino_due_x
CFLAGS += -ffunction-sections -fdata-sections -Dprintf=iprintf
CFLAGS += -DF_CPU=84000000L -DARDUINO=151 -D__SAM3X8E__ -DUSB_PID=0x003e -Dprintf=iprintf

CXXFLAGS = -fno-rtti -fno-exceptions

LDFLAGS  = -g -O0 -Wl,--gc-sections -mcpu=cortex-m3 
LDFLAGS += -Thardware/arduino/sam/variants/arduino_due_x/linker_scripts/gcc/flash.ld
LDFLAGS += -L$(PWD) -lm -lgcc -mthumb -Wl,--check-sections -Wl,--gc-sections
LDFLAGS += -Wl,--entry=Reset_Handler -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align
LDFLAGS += -Wl,--warn-unresolved-symbols -Wl,--start-group
LDFLAGS += $(PROJ_NAME).a hardware/arduino/sam/cores/arduino/syscalls_sam3.c.o -lc
LDFLAGS += core.s.o hardware/arduino/sam/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a
LDFLAGS += -Wl,--end-group

C_OBJS=$(C_SRCS:.c=.c.o)
CPP_OBJS = $(CPP_SRCS:.cpp=.cpp.o)

.PHONY: proj

all: clean proj

proj: $(PROJ_NAME).elf

core.s: main.rs
	$(RUSTC) --target arm-linux-noeabi --lib -c main.rs -S -o main.ll --emit-llvm -A non-uppercase-statics -A unused-imports
	sed -i .1 's/@core_loop()/@loop()/g' main.ll
	sed -i .2 's/@core_setup()/@setup()/g' main.ll
	sed -i .3 's/arm-unknown-linux-gnueabihf/arm-none-eabi/g' main.ll
	$(LLC) -march=thumb -mattr=+thumb2 -mcpu=cortex-m3 --float-abi=soft -asm-verbose main.ll -o=core.s

%.cpp.o: %.cpp
	$(CXX) -c $(CFLAGS) $(CXXFLAGS) $< -o $@

%.c.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.s.o: %.s
	$(CC) -c $(CFLAGS) $< -o $@

$(PROJ_NAME).a: $(C_OBJS) $(CPP_OBJS)
	$(AR) rcs $(PROJ_NAME).a $(C_OBJS) $(CPP_OBJS)

$(PROJ_NAME).elf: core.s.o $(PROJ_NAME).a
	$(CXX) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $(PROJ_NAME).elf
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin

clean:
	rm -f *.o $(PROJ_NAME).elf $(PROJ_NAME).hex $(PROJ_NAME).bin $(PROJ_NAME).a core.s* main.ll*

burn: proj
	ruby flash.rb