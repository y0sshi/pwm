SIM_FILE = sim_pwm_top.v
TARGET = pwm_top.v pwm.v debouncer.v
C_SOURCE = duty

#-f ${XILINX_VIVADO}/data/secureip/secureip_cell.list.f \

OPT=${XILINX_VIVADO}/data/verilog/src/glbl.v \
		-y ${XILINX_VIVADO}/data/verilog/src/unisims +libext+.v \
		-y ${XILINX_VIVADO}/data/verilog/src/unimacro +libext+.v \
		-y ${XILINX_VIVADO}/data/verilog/src/unifast +libext+.v \
		-y ${XILINX_VIVADO}/data/verilog/src/xeclib +libext+.v \
		-y ${XILINX_VIVADO}/data/verilog/src/retarget +libext+.v \
		+access+r+w 

all: $(TARGET) tab
	xmverilog +access+r $(OPT) $(SIM_FILE) $(TARGET)

tab: $(C_SOURCE).c
	gcc $(C_SOURCE).c -o $(C_SOURCE) -lm
	rm -f $(C_SOURCE).tab && ./$(C_SOURCE)

clean:
	rm -rf xmverilog.* *.shm xcelium.d .simvision $(C_SOURCE).tab $(C_SOURCE)
