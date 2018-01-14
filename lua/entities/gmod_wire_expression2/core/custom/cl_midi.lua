--[[
	MIDI Extension
	By: bellum128
	This is a wrapper for the GMCL MIDI Library by FPtje
	https://github.com/FPtje/gmcl_midi
]]--

E2Helper.Descriptions["midiOpen"] = "Opens the given MIDI port."
E2Helper.Descriptions["midiClose"] = "Closes the given MIDI port."
E2Helper.Descriptions["midiLastTime"] = "Returns the time of the last MIDI message."
E2Helper.Descriptions["midiLastNote"] = "Returns the note of the last MIDI message."
E2Helper.Descriptions["midiLastCommand"] = "Returns the command of the last MIDI message."
E2Helper.Descriptions["midiLastVelocity"] = "Returns the velocity of the last MIDI message."
E2Helper.Descriptions["midiPrintPorts"] = "Prints all possible MIDI ports to the console."
E2Helper.Descriptions["runOnMidi"] = "If set to 1, the chip will run when a MIDI message is received."
E2Helper.Descriptions["midiClk"] = "Returns whether the execution was run because of a received MIDI message."

function attemptMidi(port)
	local function setupMidi()
		require("midi")
		opened = midi.Open(port)
	end

	isSuccess, isError = pcall( setupMidi )
	if(isSuccess) then
		print("MIDI port", opened, "opened sucessfully!")
	else
		print("MIDI port COULD NOT be opened!")
		if(!midi) then
			print("You need the GMCL MIDI Library by FPtje to run this extension. Get it at https://github.com/FPtje/gmcl_midi")
		end
	end
end

net.Receive("wire_expression2_midi_open", function(netlen, ply)
	port = net.ReadInt(4)
	attemptMidi(port)
end )

net.Receive("wire_expression2_midi_close", function(netlen, ply)
	port = net.ReadInt(4)
	if(midi && midi.IsOpened()) then
		midi.Close(port)
		print("MIDI Port", port, "Closed.")
	else
		print("There are no open MIDI ports to close.")
	end
end )

net.Receive("wire_expression2_midi_print_ports", function(netlen, ply)
	function printPorts()
		print("MIDI Ports:")
		PrintTable(midi.GetPorts())
	end

	if(!midi) then
		require("midi")
		print("Midi: ", midi)
	end

	if(midi) then
		printPorts()
	end
end )

hook.Add("MIDI", "midiE2", function(time, command, note, velocity)
    if !midi || midi.GetCommandName( command ) != "NOTE_ON" || velocity == 0 then return end

    net.Start("wire_expression2_midi_note")
    	net.WriteFloat(time)
    	net.WriteUInt(command, 8)
    	net.WriteUInt(note, 7)
    	net.WriteUInt(velocity, 7)
    net.SendToServer()
end)
