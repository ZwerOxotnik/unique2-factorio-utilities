

local Event = require("stdlib/event/event")

local Output = {}

if not storage.Output then storage.Output = { floating_texts = {} } end


function Output.output(str)
	if str then
		if (#game.players <= 1) then
			game.show_message_dialog{text = str}
		end
		game.print(str)
	end
end

-- Debug-Type String Output
-- Waiting for 0.16's script.mod_name ...
-- s - string. Message to be shown
-- player (optional). Player to show the output to.
-- local mod_name = "Exp"
-- function Output.print(s, player)
--     if player == nil then
--         game.print(mod_name .. ": " .. s)
--     else 
--         player.print(mod_name .. ": " .. s)
--     end
-- end



function Output.display_floating_text(position, text, stay, color)
	local pos = position.position or position
	local entity_info = {
		surface = game.surfaces.nauvis,
		target  = pos,
		color   = color,
		text    = text,
	}

	local entity = game.surfaces.nauvis.create_entity(entity_info)

	storage.Output.floating_texts[#storage.Output.floating_texts + 1] = {entity, entity_info, stay}

	return #storage.Output.floating_texts
end

function Output.remove_floating_text(index)
	storage.Output.floating_texts[index][1].destroy()
	storage.Output.floating_texts[index] = nil
end

function Output.update_floating_text(index, new_text)
	local text_data = storage.Output.floating_texts[index]
	text_data[1].destroy()
	text_data[2].text = new_text
	text_data[1] = rendering.draw_text(text_data[2])
	text_data[1].position = text_data[2].position -- TODO: recheck, it seems pointless
end

Event.register(defines.events.on_tick, function ()
	for i,text_data in pairs(storage.Output.floating_texts) do
		if text_data[1] and text_data[1].valid then
			text_data[1].teleport(text_data[2].position)
		else
			if text_data[3] then
				text_data[1] = rendering.draw_text(text_data[2])
			else
				storage.Output.floating_texts[i] = nil
			end
		end
	end
end)


return Output