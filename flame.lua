-- flame.lua
-- originally by AKhilRaghav0
-- rewritten by TechDudie

local addvectors(v1, v2)
  return {x=v1.x+v2.x, y=v1.y+v2.y, z=v1.z+v2.z}
end

minetest.register_tool("flamethrower:flamethrower", {
  description = "Flamethrower",
  inventory_image = "flamethrower.png",
  sound = {breaks = "default_tool_breaks"},
  on_use = function (itemstack, user, pointed_thing)
    -- No sounds
    --[[
    local sound_pos = pointed_thing.above or user:get_pos()
    minetest.sound_play("fire_flint_and_steel", {pos = sound_pos, gain = 0.5, max_hear_distance = 8}, true)
    ]]--
    local player_name = user:get_player_name()
    -- Throw fire
    local pos = user:getpos()
    local vel = user:get_look_dir()
    local rshift = {x = vel.z/8, z = -vel.x/8, y = 0}
    local minp = {x=pos.x, y=pos.y+1.6, z=pos.z}
    local maxp = {x=pos.x, y=pos.y+1.6, z=pos.z}
    minp = addvectors(minp, rshift)
    maxp = addvectors(maxp, rshift)
    local minvel = {x=vel.x*6-0.5, y=vel.y*6-0.5, z=vel.z*6-0.5}
    local maxvel = {x=vel.x*6+0.5, y=vel.y*6+0.5, z=vel.z*6+0.5}
    minetest.add_particlespawner(300, 0.2, minp, maxp, minvel, maxvel, {x=0, y=0, z=0}, {x=0, y=1, z=0}, 1.2, 2, 0.1, 1, false, "fire_basic_flame.png")
    -- Burn nodes
    local np = minp
    for i = 0, 5 do
      np = addvectors(np, vel)
      if minetest.is_protected(np, player_name) then
        minetest.chat_send_player(player_name, "This area is protected")
        return
      end
      local node = minetest.env:get_node(np)
      if minetest.get_item_group(node.name, "flammable") ~= 0 then
        minetest.env:set_node(np, {name="fire:basic_flame"})
      end
      if node.name == "default:dirt_with_grass" then
        minetest.env:set_node(np, {name="default:dirt"})
      end
    end
    if not minetest.is_creative_enabled(player_name) then
      -- Wear tool
      local wdef = itemstack:get_definition()
      itemstack:add_wear(256)
      -- Tool break sound
      if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
        minetest.sound_play(wdef.sound.breaks, {pos = sound_pos, gain = 0.5}, true)
      end
      return itemstack
    end
  end
})

minetest.register_craft({
  type = "shaped",
  output = "flamethrower:flamethrower",
  recipe = {{"fire:flint_and_steel","",""},
           {"basic_materials:steel_strip","technic:sulfur_lump",""},
           {"","technic:sulfur_lump","basic_materials:steel_strip"},},
})
