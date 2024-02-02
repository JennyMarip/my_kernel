CROSS_COMPILE = riscv64-unknown-elf-
CFLAGS = -nostdlib -fno-builtin -march=rv32g -mabi=ilp32 -g -Wall

QEMU = qemu-system-riscv32
QFLAGS = -nographic -smp 1 -machine virt -bios ./bin/bootloader.bin -device loader,file=./bin/kernel.bin,addr=0x80200000

GDB = gdb-multiarch
CC = ${CROSS_COMPILE}gcc
OBJCOPY = ${CROSS_COMPILE}objcopy
OBJDUMP = ${CROSS_COMPILE}objdump

.DEFAULT_GOAL := all
all:
	@${CC} ${CFLAGS} ${SRC} -Ttext=0x80200000 -o ./bin/${EXEC}.elf
	@${OBJCOPY} -O binary ./bin/${EXEC}.elf ./bin/${EXEC}.bin
	@${CC} ${CFLAGS} ${BOOTLOADER} -Ttext=0x80000000 -o ./bin/${BOOT}.elf
	@${OBJCOPY} -O binary ./bin/${BOOT}.elf ./bin/${BOOT}.bin

.PHONY : run
run: all
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo "------------------------------------"
	@echo "No output, please run 'make debug' to see details"
	@${QEMU} ${QFLAGS}

.PHONY : s_debug
s_debug: all
	@echo "Press Ctrl-C and then input 'quit' to exit GDB and QEMU"
	@echo "-------------------------------------------------------"
	@${QEMU} ${QFLAGS} -s -S
	
.PHONY : c_debug
c_debug: all
	@${GDB} ./bin/${EXEC}.elf -q -x gdbinit

.PHONY : code
code: all
	@${OBJDUMP} -S ./bin/${EXEC}.elf | less

.PHONY : hex
hex: all
	@hexdump -C ./bin/${EXEC}.bin

.PHONY : clean
clean:
	rm -rf ./bin/*.o ./bin/*.bin ./bin/*.elf
