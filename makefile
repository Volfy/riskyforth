uart:
	rm -rf uart
	riscv64-linux-gnu-gcc -march=rv64g -mabi=lp64 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -Tuart.ld -I. uart.s -o uart