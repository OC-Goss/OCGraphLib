local unicode = require("unicode")

local brailleindex = {{0x1,0x8},{0x2,0x10},{0x4,0x20},{0x40,0x80}}

local funcs = {}

-- table must be of lenght width*height
-- the w and h arguments to the functions are characters, so w = pixels / 2 and h = pixels / 4
-- to convert table into braille for a 8x8 pixel image (where sp is this lib), do sp.bmpToBraille(sp.tableToBmp({table here}, 4, 2))
-- it does not split the output string for you, you need to do that manually

funcs.tableToBmp = function(tab, w, h)
  local bmpout = ""
  local curbyte = 0
  local bimcomp = false
  for i = 1, w*h*8 do
    if i % 8 == 0 then
      bmpout = bmpout .. string.char(curbyte)
      curbyte = 0
      bimcomp = false
    end
    --print(i)
    bimcomp = true
    curbyte = (curbyte << 1) | (tab[i] or 0)
    --print((tab[i] or 0))
  end
  if bimcomp then
    bmpout = bmpout .. string.char(curbyte)
  end
  return bmpout
end

funcs.bmpToBraille = function(bmp,w,h) -- Converts a bitmap (string of bytes) into unicode braille subpixels
  local outputstr = ""
  local c, i, tx, ty, ti, b, s, p
  for y=0, h-1 do
    for x=0, w-1 do
      local c = 0
      for sy=0, 3 do
        for sx=0, 1 do
          i = brailleindex[sy+1][sx+1]
          tx, ty = x * 2 + sx, y * 4 + sy
          ti = tx+ty*w*2
          b, s = ti//8,ti%8
          --print(i,tx,ty,ti,b,s)
          p = ((bmp:byte(b+1) or 0)>>(7-s)) % 2
          c = c + p * i
        end
      end
      outputstr = outputstr .. unicode.char(0x2800+c)
    end
  end
  return outputstr
end

funcs.tableToBraille = function(tab,w,h) -- Converts a bitmap (string of bytes) into unicode braille subpixels
  local outputstr = ""
  local c, i, tx, ty, ti, b, s, p
  for y=0, h-1 do
    for x=0, w-1 do
      local c = 0
      for sy=0, 3 do
        for sx=0, 1 do
          i = brailleindex[sy+1][sx+1]
          tx, ty = x * 2 + sx, y * 4 + sy
          ti = tx+ty*w*2
          b, s = ti//8,ti%8
          --print(i,tx,ty,ti,b,s)
          p = (tab[ti] or 0) % 2
          c = c + p * i
        end
      end
      outputstr = outputstr .. unicode.char(0x2800+c)
    end
  end
  return outputstr
end

return funcs