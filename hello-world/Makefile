bit:

pll: force
	ecppll -i 25 -o 100 -f pll.v 

ulx3s_top.json: pll ulx3s_top.v uart_tx.v
	yosys -p 'read_verilog ulx3s_top.v; synth_ecp5; write_json ulx3s_top.json'

ulx3s_top.config: ulx3s_top.json
	nextpnr-ecp5 --85k --package CABGA381 --json ulx3s_top.json \
		--lpf ulx3s_v20.lpf --textcfg ulx3s_top.config

bit: ulx3s_top.config
	ecppack ulx3s_top.config ulx3s_top.bit

clean:
	$(RM) *.config *.bit *.json pll.v

force:
