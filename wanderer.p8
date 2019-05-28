pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function flood_map()
  for y = 0,64 do
    for x = 0,127 do
      local ws = g.water[ceil(rnd(#g.water))]
      mset(x, y, ws)
    end
  end
end

function create_island()
  local w = 8 + ceil(rnd(40))
  local h = 8 + ceil(rnd(16))
  local x = flr(rnd(128 - (w / 2)))
  local y = flr(rnd(63 - (h / 2)))
  local sculpt = {0,0}
  for yi = y,y+h do
    sculpt[1] = sculpt[1] + (-1 + ceil(rnd(2)))
    sculpt[2] = sculpt[2] + (-1 + ceil(rnd(2)))
    for xi = x + sculpt[1], x+w+sculpt[2] do
      local ss = g.sand[ceil(rnd(#g.sand))]
      mset(xi, yi, ss)
    end
  end
end

function draw_edges(col, ymod)
  for y = 0, 64 do
    for x = 0, 128 do
      if fget(mget(x,y)) == 2 and fget(mget(x,y+ymod)) == 1 then
        local fs = col[ceil(rnd(#col))]
        mset(x, y+ymod, fs)
      end
    end
  end
end

function render_map()
  flood_map()
  for island = 0,16 do
    create_island()
  end
  draw_edges(g.edgeb, 1)
  draw_edges(g.edget, -1)
end

function find_flagged_sprites(f)
  local sprs = {}
  for si = 64,127 do
    if fget(si) == f then
      add(sprs, si)
    end
  end
  return sprs
end

function find_spawnable_point()
  local x = 0
  local y = 0
  local mp = null
  repeat
    x = rnd(127)
    y = rnd(64)
    mp = mget(x,y)
  until fget(mp, 1)
  return {x = x*8, y = y*8}
end

function make_player()
  local p = {}
  p.position = find_spawnable_point()
  p.tick = 1
  p.states = {
    down = {f=false, frames={0}},
    up = {f=false, frames={1}},
    right = {f=false, frames={2}},
    left = {f=true, frames={2}}
  }
  p.state = p.states.down
  p.width = 1
  p.height = 2
  return p
end

function drop_sand(p)
  local ymod = 1
  local xmod = 1
  if (p.state == p.states.up) ymod = -1
  if (p.state == p.states.left) xmod = -1
  local x = flr((p.position.x + 4) / 8) + xmod
  local y = flr((p.position.y + 8) / 8) + ymod
  mset(x, y, g.sand[ceil(rnd(#g.sand))])
  draw_edges(g.edgeb, 1)
  draw_edges(g.edget, -1)
end

function draw_sprite(thing)
  if(thing.tick > #thing.state.frames) thing.tick=1
  local frame = thing.state.frames[thing.tick]
  spr(frame, thing.position.x, thing.position.y, thing.width, thing.height, thing.state.f)
  thing.tick += 1
end

function check_feet(thing, surface)
  local mp = mget(flr(thing.position.x / 8), flr((thing.position.y + (thing.height * 8)) / 8))
  return fget(mp) == surface
end

function player_input(l,r,u,d,f1,f2)
  local lx = player.position.x
  local ly = player.position.y
  if l then
    player.position.x -= 2
    player.state = player.states.left
  end
  if r then
    player.position.x += 2
    player.state = player.states.right
  end
  if u then
    player.position.y -= 2
    player.state = player.states.up
  end
  if d then
    player.position.y += 2
    player.state = player.states.down
  end
  if check_feet(player, 2) == false then
    player.position.x = lx
    player.position.y = ly
  end
  if (f1) drop_sand(player)
end


function update_game()
 player_input(btn(0),btn(1),btn(2),btn(3),btn(4),btn(5))
 g.cam.x = player.position.x - 64
 g.cam.y = player.position.y - 64
end

function draw_game()
  cls()
  camera(g.cam.x, g.cam.y)
  if (g.ptick>#g.pcycle) g.ptick=1
  for c in all(g.pcycle[flr(g.ptick)]) do
    pal(c[1], c[2])
  end
  map(0, 0, 0, 0, 128, 64)
  pal()
  g.ptick +=0.1
  draw_sprite(player)
end

function _init()
  _update = update_game
  _draw = draw_game
  g = {
    ["water"] = find_flagged_sprites(1),
    ["sand"] = find_flagged_sprites(2),
    ["edgeb"] = find_flagged_sprites(3),
    ["edget"] = find_flagged_sprites(4),
    ["cam"] = {["x"] = 0,["y"] = 0},
    ["pcycle"] = {{},{{6,12}, {7,6}},{{7,12},{6,7}}, {{6,12}}, {{7,6}}, {{7,12}}},
    ["ptick"] = 1
  }
  render_map()
  player = make_player()
end
__gfx__
00566650005666500056665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049940
0677777606777776067777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f994
004444400045554000554440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff999
00f1f1f0008454800054f180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff99
00ef4fe000f444f00044eef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff99
0045554000e848e000e84440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f4999
00044400000eee00000ef400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022fff99
0effffe00effffe00eefff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000226fff4
effffffeeffeeffe0eefef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000622fff
f4f66f4ff4feef4f0efefe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000062224f
e06ff60ee0effe0e08eff8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000001ddff220f
806ff60880ffef08008ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c10001dcdfff640f
00dddd0000dddd0000ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc01dccccdfff00f
00dd1dd00dd0dd0000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001cccccccccdfd00f
00dd1dd00dd0dd00000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dcdcdcdccccc004
067606766760676000677600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c111000dccd000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc9999999999999999c4c994cccc64c6cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
67cccccccc667ccc999999999999999f4999999f9999696900000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc6ccccccccc9b9eb9999999e999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc6679999999999f99999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc9999999999999999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
cc6cc7cccccccccc99999bfb99b9999999e999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc99b999999999b99999999b999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc676ccc9999999999999999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc9999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc76ccccc6cc9b99999f99b99e99000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc6ccccc9999fb9999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc676cccccccccc6999999999efe9999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc99fef99999999bf9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc6ccccccc9999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc6ccc67cccccccc9999eb9999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccc667699999999b99fe999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004499994999949494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444444449449444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444476447474474000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c67cc6c6c6c6c6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010202040400000000000000000000010102020000000000000000000000000000030300000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
