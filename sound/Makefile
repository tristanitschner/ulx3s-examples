wav2mem: wav2mem.c
	gcc wav2mem.c -o wav2mem

sim:
	iverilog -g2005-sv top_sound_tb.v top_sound.v delta_sigma.v -o top_sound_tb

sound.json: top_sound.v delta_sigma.v
	yosys -p 'read_verilog top_sound.v delta_sigma.v; hierarchy -top top_sound; synth_ecp5; write_json sound.json'

sound.config: sound.json
	nextpnr-ecp5 --lpf ulx3s_v20.lpf --log nextpnr.log --85k --textcfg sound.config --json sound.json

sound.bit: sound.config
	ecppack sound.config sound.bit

clean:
	$(RM) *.log *.config *.bit *.json wav2mem top_sound_tb
