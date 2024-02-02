EXEC = kernel
BOOT = bootloader

SRC = ./src/${EXEC}.s
BOOTLOADER = ./src/${BOOT}.s


include ./rule.mk
