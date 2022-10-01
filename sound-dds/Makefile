TOP := top_sound
TARGET := sound

SIM = sound_tb.v 

SRC += top_sound.v 
SRC += sound.v
SRC += delta_sigma.v

sim:
	iverilog -g2005-sv $(SIM) $(SRC) -o sound_tb

$(TARGET).json: $(SRC)
	yosys -p 'read_verilog -sv $(SRC); hierarchy -top $(TOP); synth_ecp5; write_json $(TARGET).json'

$(TARGET).config: $(TARGET).json
	nextpnr-ecp5 --lpf ulx3s_v20.lpf --log nextpnr.log --85k --textcfg $(TARGET).config --json $(TARGET).json

$(TARGET).bit: $(TARGET).config
	ecppack $(TARGET).config $(TARGET).bit

clean:
	$(RM) *.log *.config *.bit *.json top_$(TARGET)_tb *.vcd sound_tb
