--[[
	MIDI Extension
	By: bellum128
	This is a wrapper for the GMCL MIDI Library by FPtje
	https://github.com/FPtje/gmcl_midi
]]--

E2Lib.RegisterExtension("midi", false, "Allows the E2 to communicate with a physical MIDI controller.")

local run_on = {
	clk = 0,
	ents = {}
}

util.AddNetworkString("wire_expression2_midi_note")
net.Receive("wire_expression2_midi_note", function(netlen, ply)
	ply.lastMidi = {}
	ply.lastMidi["time"] = net.ReadFloat()
	ply.lastMidi["command"] = net.ReadUInt(8)
	ply.lastMidi["note"] = net.ReadUInt(7)
	ply.lastMidi["velocity"] = net.ReadUInt(7)

	ply.midiClk = 1
	for ent,eply in pairs( run_on.ents ) do
		if IsValid( ent ) and ent.Execute and eply == ply then
			ent:Execute()
		end
	end
	ply.midiClk = 0
end )

e2function number midiLastTime()
	if (self.player.lastMidi != nil) then
		return self.player.lastMidi["time"]
	else
		return nil
	end
end

e2function number midiLastNote()
	if (self.player.lastMidi != nil) then
		return self.player.lastMidi["note"]
	else
		return nil
	end
end

e2function number midiLastCommand()
	if (self.player.lastMidi != nil) then
		return self.player.lastMidi["command"]
	else
		return nil
	end
end

e2function number midiLastVelocity()
	if (self.player.lastMidi != nil) then
		return self.player.lastMidi["velocity"]
	else
		return nil
	end
end

util.AddNetworkString("wire_expression2_midi_open")
e2function void midiOpen( number port )
	net.Start("wire_expression2_midi_open")
	net.WriteInt(port, 4)
	net.Send(self.player)
end

util.AddNetworkString("wire_expression2_midi_close")
e2function void midiClose( number port )
	net.Start("wire_expression2_midi_close")
	net.WriteInt(port, 4)
	net.Send(self.player)
end

util.AddNetworkString("wire_expression2_midi_print_ports")
e2function void midiPrintPorts()
	net.Start("wire_expression2_midi_print_ports")
	net.Send(self.player)
end

e2function void runOnMidi( number romidi )
	run_on.ents[self.entity] = ( romidi != 0 ) and self.player or nil
end

e2function number midiClk()
	return self.player.midiClk
end
