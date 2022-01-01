local addvectors = function (v1, v2)
	return {x=v1.x+v2.x, y=v1.y+v2.y, z=v1.z+v2.z}
end

minetest.register_craftitem("flamethrower:tool", {
	description = "Flamethrower",
	inventory_image = "flamethrower.png",
	on_use = function (itemstack, player, pointed_thing)
		-- Throw fire
		local pos = player:getpos()
		local vel = player:get_look_dir()

		local rshift = {x = vel.z/8, z = -vel.x/8, y = 0}

		local minp = {x=pos.x, y=pos.y+1.6, z=pos.z}
		local maxp = {x=pos.x, y=pos.y+1.6, z=pos.z}
		minp = addvectors(minp, rshift)
		maxp = addvectors(maxp, rshift)

		local minvel = {x=vel.x*6-0.5, y=vel.y*6-0.5, z=vel.z*6-0.5}
		local maxvel = {x=vel.x*6+0.5, y=vel.y*6+0.5, z=vel.z*6+0.5}

		minetest.add_particlespawner(300, 0.2,
			minp, maxp,
			minvel, maxvel,
			{x=0, y=0, z=0}, {x=0, y=1, z=0},
			1.2, 2,
			0.1, 1,
			false, "fire_basic_flame.png")
		--max use
		local stack = ItemStack("flamethrower:tool")
		local max_use = 60
		stack:add_wear(65535 / (max_use - 1))
		-- Make stuff burn
		local np = minp
		for i = 0, 5 do
			np = addvectors(np, vel)
			local node = minetest.env:get_node(np)
			if minetest.get_item_group(node.name, "flammable") ~= 0 then
				minetest.env:set_node(np, {name="fire:basic_flame"})
			end

			if node.name == "default:dirt_with_grass" then
				minetest.env:set_node(np, {name="default:dirt"})
			end
		end
	end,
})

minetest.register_craft({
	type = "shaped",
	output = "Flamethrower:tool 1",
	recipe = {
		{"fire:flint_and_steel","",""},
		{"basic_materials:steel_strip","technic:sulfur_lump",""},
		{"","technic:sulfur_lump","basic_materials:steel_sstrip"},
	},
})


