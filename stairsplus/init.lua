--[[
More Blocks: Stairs+

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

-- Nodes will be called <modname>:{stair,slab,panel,micro,slope}_<subname>

local modpath = minetest.get_modpath("moreblocks").. "/stairsplus"

stairsplus = {}
stairsplus.expect_infinite_stacks = false

stairsplus.shapes_list = {}

if
	not minetest.get_modpath("unified_inventory")
	and minetest.settings:get_bool("creative_mode")
then
	stairsplus.expect_infinite_stacks = true
end

local do_not_copy_groups = {
	wood = true,
	stone = true,
	wool = true,
	tree = true,
	marble = true,
	leaves = true
}

function stairsplus:prepare_groups(groups)
	local result = {}
	if groups then
		for k, v in pairs(groups) do
			if not do_not_copy_groups[k] then
				result[k] = v
			end
		end
	end
	if not moreblocks.config.stairsplus_in_creative_inventory then
		result.not_in_creative_inventory = 1
	end
	return result
end

local function get_tile(node_def, index)
	if not index then index = 1 end
	return 
		((node_def.tiles and node_def.tiles[index] and
			(node_def.tiles[index].name or node_def.tiles[index]))
		or (node_def.tile_images and node_def.tile_images[index]))
end

function stairsplus:register_all(modname, subname, recipeitem, fields, stairs_subname)

	if not stairs_subname then stairs_subname = subname end
	-- This could be distributed amongst the various sub-calls, or put in register-single, but we almost always use register_all so this works
	local possible_stairs_items = {
		["stairs:stair_" .. stairs_subname]       = modname .. ":stair_" .. subname,
		["stairs:stair_outer_" .. stairs_subname] = modname .. ":stair_" .. subname .. "_outer",
		["stairs:stair_inner_" .. stairs_subname] = modname .. ":stair_" .. subname .. "_inner",
		["stairs:slab_"  .. stairs_subname]       = modname .. ":slab_"  .. subname
	}
	local cleanup_stairs = false
	local stairs_items = {}
	local original_def = minetest.registered_nodes[recipeitem]
	local original_tile = original_def and get_tile(original_def)
	if original_tile then
		for stair_item,alias in pairs(possible_stairs_items) do
			local def = minetest.registered_nodes[stair_item]
			if def and (
				original_def.mod_origin == def.mod_origin or
				original_tile == get_tile(def)
			) then
				stairs_items[stair_item] = alias
				cleanup_stairs = true
			end
		end
	end

	if cleanup_stairs then
		for stair_item, _ in pairs(stairs_items) do
			minetest.clear_craft({ output=stair_item })
		end

		local existing_recipes = minetest.get_all_craft_recipes(recipeitem)

		if existing_recipes then
			local standard_recipes = {}
			for i,existing_recipe in pairs(existing_recipes) do
				if existing_recipe.type == "normal" then
					local standard = false
					for _,item in pairs(existing_recipe.items) do
						if not stairs_items[item] then
							standard = true
							break
						end
					end
					if standard then
						local recipe_obj = {
							output = existing_recipe.output,
						}
						if existing_recipe.width == 0 then
							recipe_obj.type = "shapeless"
							recipe_obj.recipe = existing_recipe.items
						else
							recipe_obj.recipe = {{},{},{}}
							for x=1,3 do
								for y=1,existing_recipe.width do
									local p = ((x-1)*existing_recipe.width)+y
									recipe_obj.recipe[x][y] = existing_recipe.items[p] or ""
								end
							end
						end
						table.insert(standard_recipes, recipe_obj)
					end
				end
			end

			minetest.clear_craft({ output=recipeitem })
			for _,recipe in pairs(standard_recipes) do
				minetest.register_craft(recipe)
			end
		end
	end

	self:register_stair(modname, subname, recipeitem, fields)
	self:register_slab(modname, subname, recipeitem, fields)
	self:register_slope(modname, subname, recipeitem, fields)
	self:register_panel(modname, subname, recipeitem, fields)
	self:register_micro(modname, subname, recipeitem, fields)

	if cleanup_stairs then
		for stair_item, alias in pairs(stairs_items) do
			minetest.register_alias_force(stair_item, alias)
		end
	end
end

function stairsplus:register_alias_all(modname_old, subname_old, modname_new, subname_new)
	self:register_stair_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_slab_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_slope_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_panel_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_micro_alias(modname_old, subname_old, modname_new, subname_new)
end
function stairsplus:register_alias_force_all(modname_old, subname_old, modname_new, subname_new)
	self:register_stair_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_slab_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_slope_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_panel_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_micro_alias_force(modname_old, subname_old, modname_new, subname_new)
end

-- luacheck: no unused
local function register_stair_slab_panel_micro(modname, subname, recipeitem, groups, images, description, drop, light)
	stairsplus:register_all(modname, subname, recipeitem, {
		groups = groups,
		tiles = images,
		description = description,
		drop = drop,
		light_source = light
	})
end

dofile(modpath .. "/defs.lua")
dofile(modpath .. "/recipes.lua")
dofile(modpath .. "/common.lua")
dofile(modpath .. "/stairs.lua")
dofile(modpath .. "/slabs.lua")
dofile(modpath .. "/slopes.lua")
dofile(modpath .. "/panels.lua")
dofile(modpath .. "/microblocks.lua")
dofile(modpath .. "/custom.lua")
dofile(modpath .. "/registrations.lua")
