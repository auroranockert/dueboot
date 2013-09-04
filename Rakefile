RUSTC = "#{ENV['HOME']}/.local/bin/rustc"
LLC   = "#{ENV['HOME']}/Code/Git/rust/llvm/x86_64-apple-darwin/Release+Asserts/bin/llc"

PORT = "tty.usbmodem411"

RUST_SRC = 'core.rs'

# ---------------------------------------------------------------
# Normally you shouldn't need to change anything below this line!
# ---------------------------------------------------------------

AR      = "hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-ar"
CC      = "hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-gcc"
CXX     = "hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-g++"
OBJCOPY = "hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-objcopy"

C_SRCS = ['zero/zero.c']
CPP_SRCS = []

# ----------------------------------------------------------------------
# Normally you really shouldn't need to change anything below this line!
# ----------------------------------------------------------------------

C_SRCS.push('hardware/arduino/sam/cores/arduino/cortex_handlers.c', 'hardware/arduino/sam/cores/arduino/hooks.c', 'hardware/arduino/sam/cores/arduino/itoa.c', 'hardware/arduino/sam/cores/arduino/WInterrupts.c', 'hardware/arduino/sam/cores/arduino/wiring.c', 'hardware/arduino/sam/cores/arduino/wiring_analog.c', 'hardware/arduino/sam/cores/arduino/wiring_digital.c', 'hardware/arduino/sam/cores/arduino/wiring_shift.c', 'hardware/arduino/sam/cores/arduino/iar_calls_sam3.c', 'hardware/arduino/sam/cores/arduino/syscalls_sam3.c')

CPP_SRCS.push('hardware/arduino/sam/cores/arduino/cxxabi-compat.cpp', 'hardware/arduino/sam/cores/arduino/IPAddress.cpp', 'hardware/arduino/sam/cores/arduino/Print.cpp', 'hardware/arduino/sam/cores/arduino/Reset.cpp', 'hardware/arduino/sam/cores/arduino/RingBuffer.cpp', 'hardware/arduino/sam/cores/arduino/Stream.cpp', 'hardware/arduino/sam/cores/arduino/UARTClass.cpp', 'hardware/arduino/sam/cores/arduino/USARTClass.cpp', 'hardware/arduino/sam/cores/arduino/USB/CDC.cpp', 'hardware/arduino/sam/cores/arduino/USB/HID.cpp', 'hardware/arduino/sam/cores/arduino/USB/USBCore.cpp', 'hardware/arduino/sam/cores/arduino/wiring_pulse.cpp', 'hardware/arduino/sam/cores/arduino/WMath.cpp', 'hardware/arduino/sam/cores/arduino/WString.cpp', 'hardware/arduino/sam/variants/arduino_due_x/variant.cpp')

@cflags = "-g -O0 -Wall -nostdlib -mthumb -mcpu=cortex-m3"
@cflags += " -Ihardware/arduino/sam/system/libsam -Ihardware/arduino/sam/system/CMSIS/CMSIS/Include/"
@cflags += " -Ihardware/arduino/sam/system/CMSIS/Device/ATMEL/ -Ihardware/arduino/sam/cores/arduino"
@cflags += " -Ihardware/arduino/sam/variants/arduino_due_x"
@cflags += " -ffunction-sections -fdata-sections -Dprintf=iprintf"
@cflags += " -DF_CPU=84000000L -DARDUINO=151 -D__SAM3X8E__ -DUSB_PID=0x003e -Dprintf=iprintf"


@cxxflags = "#{@cflags} -fno-rtti -fno-exceptions"

@ldflags = "-g -O0 -Wl,--gc-sections -mcpu=cortex-m3"
@ldflags += " -Thardware/arduino/sam/variants/arduino_due_x/linker_scripts/gcc/flash.ld"
@ldflags += " -Loutput/} -lm -lgcc -mthumb -Wl,--check-sections -Wl,--gc-sections"
@ldflags += " -Wl,--entry=Reset_Handler -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align"
@ldflags += " -Wl,--warn-unresolved-symbols -Wl,--start-group"
@ldflags += " output/arduino.a output/syscalls_sam3.o -lc"
@ldflags += " output/core.o hardware/arduino/sam/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a"
@ldflags += " -Wl,--end-group"

task :all => :core
task :core => 'output/core.bin'
task :clean do
  sh 'rm -r output/'
end

task :flash => :core do
  require 'serialport'

  SerialPort.open("/dev/#{PORT}", 1200) {|sp| puts "Reset Board" }

  # Upload to Board
  sh "hardware/tools/bossac --port=#{PORT} -U false -e -w -v -b output/core.bin -R"
end

directory 'output'

file 'output/core.s' => [RUST_SRC, 'arduino.rs', 'output'] do
  sh "#{RUSTC} --target arm-linux-noeabi --lib -c #{RUST_SRC} -S -o output/main.ll --emit-llvm -A non-uppercase-statics -A unused-imports"
  sh "sed -i .1 's/@core_loop()/@loop()/g' output/main.ll"
  sh "sed -i .2 's/@core_setup()/@setup()/g' output/main.ll"
  sh "sed -i .3 's/arm-unknown-linux-gnueabihf/arm-none-eabi/g' output/main.ll"
  sh "#{LLC} -march=thumb -mattr=+thumb2 -mcpu=cortex-m3 --float-abi=soft -asm-verbose output/main.ll -o=output/core.s"
end

file 'output/core.o' => 'output/core.s' do
  sh "#{CC} -c #{@cflags} output/core.s -o output/core.o"
end

file 'output/core.bin' => ['output/core.o', 'output/arduino.a'] do
  sh "#{CXX} #{@cxxflags} #{@ldflags} -o output/core.elf"
  sh "#{OBJCOPY} -O ihex output/core.elf output/core.hex"
  sh "#{OBJCOPY} -O binary output/core.elf output/core.bin"
end

file 'output/arduino.a' => ['output'] do
  C_SRCS.each do |src|
    output = "output/#{File.basename(src, '.c')}.o"
    sh "#{CC} -c #{@cflags} #{src} -o '#{output}'"
    sh "#{AR} rcs output/arduino.a '#{output}'"
  end

  CPP_SRCS.each do |src|
    output = "output/#{File.basename(src, '.cpp')}.o"
    sh "#{CXX} -c #{@cxxflags} #{src} -o '#{output}'"
    sh "#{AR} rcs output/arduino.a '#{output}'"
  end
end
