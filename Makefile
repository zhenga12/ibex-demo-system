make fuse:
	fusesoc --cores-root=. run --target=sim --tool=verilator         --setup --build lowrisc:ibex:demo_system

make buil:
	./build/lowrisc_ibex_demo_system_0/sim-verilator/Vibex_demo_system \ -t --meminit=ram,/home/gajjarv/Capstone/Ibex_Core/ibex-demo-system/sw/c/build/demo/cmplx_test/cmplx_test


make run_dis:
	riscv32-unknown-elf-objdump -d /home/gajjarv/Capstone/Ibex_Core/ibex-demo-system/sw/c/build/demo/cmplx_test/cmplx_test > /home/gajjarv/Capstone/Ibex_Core/ibex-demo-system/cmplx_disassembly.txt
