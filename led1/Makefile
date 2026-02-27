led.bin :led.s
	arm-linux-gnueabihf-gcc -c -g led.s -o led.o
	arm-linux-gnueabihf-ld -Ttext 0x87800000 led.o -o led.elf
	arm-linux-gnueabihf-objcopy -O binary -S -g led.elf led.bin
	arm-linux-gnueabihf-objdump -D led.elf > led.dis

clean:
	rm -f led.o led.elf led.bin led.dis