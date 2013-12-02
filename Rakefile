ARDUINO = '/Users/Jens/Applications/Arduino\ 1.5.5.app/Contents/Resources/Java'
RUSTC = "#{ENV['HOME']}/.local/bin/rustc"
LLC   = "#{ENV['HOME']}/Code/Git/rust2/x86_64-apple-darwin/llvm/Release+Asserts/bin/llc"

PORT = "tty.usbmodem411"

RUST_SRC = 'core.rs'

# ---------------------------------------------------------------
# Normally you shouldn't need to change anything below this line!
# ---------------------------------------------------------------

USR_C_SRCS = []
USR_CPP_SRCS = []
USR_INCLUDES = []

# ----------------------------------------------------------------------
# Normally you really shouldn't need to change anything below this line!
# ----------------------------------------------------------------------

AR      = "#{ARDUINO}/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-ar"
CC      = "#{ARDUINO}/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-gcc"
CXX     = "#{ARDUINO}/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-g++"
OBJCOPY = "#{ARDUINO}/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-objcopy"

C_SRCS = ['hardware/arduino/sam/cores/arduino/cortex_handlers.c', 'hardware/arduino/sam/cores/arduino/hooks.c', 'hardware/arduino/sam/cores/arduino/itoa.c', 'hardware/arduino/sam/cores/arduino/WInterrupts.c', 'hardware/arduino/sam/cores/arduino/wiring.c', 'hardware/arduino/sam/cores/arduino/wiring_analog.c', 'hardware/arduino/sam/cores/arduino/wiring_digital.c', 'hardware/arduino/sam/cores/arduino/wiring_shift.c', 'hardware/arduino/sam/cores/arduino/iar_calls_sam3.c', 'hardware/arduino/sam/cores/arduino/syscalls_sam3.c'] + USR_C_SRCS

CPP_SRCS = ['hardware/arduino/sam/cores/arduino/cxxabi-compat.cpp', 'hardware/arduino/sam/cores/arduino/IPAddress.cpp', 'hardware/arduino/sam/cores/arduino/Print.cpp', 'hardware/arduino/sam/cores/arduino/Reset.cpp', 'hardware/arduino/sam/cores/arduino/RingBuffer.cpp', 'hardware/arduino/sam/cores/arduino/Stream.cpp', 'hardware/arduino/sam/cores/arduino/UARTClass.cpp', 'hardware/arduino/sam/cores/arduino/USARTClass.cpp', 'hardware/arduino/sam/cores/arduino/USB/CDC.cpp', 'hardware/arduino/sam/cores/arduino/USB/HID.cpp', 'hardware/arduino/sam/cores/arduino/USB/USBCore.cpp', 'hardware/arduino/sam/cores/arduino/wiring_pulse.cpp', 'hardware/arduino/sam/cores/arduino/WMath.cpp', 'hardware/arduino/sam/cores/arduino/WString.cpp', 'hardware/arduino/sam/variants/arduino_due_x/variant.cpp'] + USR_CPP_SRCS

INCLUDES = ['hardware/arduino/sam/system/libsam', 'hardware/arduino/sam/system/CMSIS/CMSIS/Include',
'hardware/arduino/sam/cores/arduino',
'hardware/arduino/sam/system/CMSIS/Device/ATMEL', 'hardware/arduino/sam/variants/arduino_due_x'] + USR_INCLUDES

@cflags = '-c -g -Os -w -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 -Dprintf=iprintf -mcpu=cortex-m3 -DF_CPU=84000000L -DARDUINO=155 -DARDUINO_SAM_DUE -DARDUINO_ARCH_SAM -D__SAM3X8E__ -mthumb -DUSB_VID=0x2341 -DUSB_PID=0x003e -DUSBCON ' + INCLUDES.map { |x| "-I#{x}" }.join(' ')

@cxxflags = "#{@cflags} -fno-rtti -fno-exceptions"

@ldflags = '-Os -Wl,--gc-sections -mcpu=cortex-m3'
@ldflags += " -T#{ARDUINO}/hardware/arduino/sam/variants/arduino_due_x/linker_scripts/gcc/flash.ld"
@ldflags += ' -Loutput'
@ldflags += ' -lm -lgcc -mthumb -Wl,--cref'
@ldflags += ' -Wl,--check-sections'
@ldflags += ' -Wl,--gc-sections'
@ldflags += ' -Wl,--entry=Reset_Handler'
@ldflags += ' -Wl,--unresolved-symbols=report-all'
@ldflags += ' -Wl,--warn-common'
@ldflags += ' -Wl,--warn-section-align'
@ldflags += ' -Wl,--warn-unresolved-symbols'
@ldflags += ' -Wl,--start-group'
@ldflags += " #{ARDUINO}/hardware/arduino/sam/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a"
@ldflags += ' output/arduino.a'
@ldflags += ' output/core.o'
@ldflags += ' -Wl,--end-group'

task :all => :core
task :core => 'output/core.bin'
task :clean do
  sh 'rm -r output/'
end

task :flash => :core do
  require 'serialport'

  SerialPort.open("/dev/#{PORT}", 1200) {|sp| puts "Reset Board" }

  # Upload to Board
  sh "#{ARDUINO}/hardware/tools/bossac --port=#{PORT} -U false -e -w -v -b output/core.bin -R"
end

directory 'output'

file 'output/core.s' => [RUST_SRC, 'arduino.rs', 'output'] do
  sh "#{RUSTC} --target arm-unknown-linux-gnueabihf --lib -c #{RUST_SRC} -S -o output/main.ll --emit-llvm -A non-uppercase-statics -A unused-imports"
  sh "sed -i .1 's/arm-unknown-linux-gnueabihf/arm-none-eabi/g' output/main.ll"
  sh "#{LLC} -march=thumb -mattr=+thumb2 -mcpu=cortex-m3 --float-abi=soft -asm-verbose output/main.ll -o=output/core.s"
end

file 'output/core.o' => 'output/core.s' do
  sh "#{CC} #{@cflags} output/core.s -o output/core.o"
end

file 'output/core.elf' => ['output/core.o', 'output/arduino.a'] do
  sh "#{CXX} #{@ldflags} -o output/core.elf"
end

file 'output/core.bin' => 'output/core.elf' do
  sh "#{OBJCOPY} -O binary output/core.elf output/core.bin"
end

file 'output/arduino.a' => ['output'] do
  C_SRCS.each do |src|
    output = "output/#{File.basename(src, '.c')}.o"
    sh "#{CC} #{@cflags} #{src} -o '#{output}'"
    sh "#{AR} rcs output/arduino.a '#{output}'"
  end

  CPP_SRCS.each do |src|
    output = "output/#{File.basename(src, '.cpp')}.o"
    sh "#{CXX} #{@cxxflags} #{src} -o '#{output}'"
    sh "#{AR} rcs output/arduino.a '#{output}'"
  end
end
