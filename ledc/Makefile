objs := start.o main.o

ledc.bin: $(objs)
	arm-linux-gnueabihf-ld -Ttext 0x87800000 -o ledc.elf $(objs)
	arm-linux-gnueabihf-objcopy -O binary -S ledc.elf $@
	arm-linux-gnueabihf-objdump -D -m  arm ledc.elf > ledc.dis

%.o: %.c
	arm-linux-gnueabihf-gcc -c -o $@ $< -Wall -nostdlib
%.o: %.s
	arm-linux-gnueabihf-gcc -c -o $@ $< -Wall -nostdlib
%.o: %.S
	arm-linux-gnueabihf-gcc -c -o $@ $< -Wall -nostdlib

clean:
	rm -f *.o ledc.bin ledc.elf ledc.dis