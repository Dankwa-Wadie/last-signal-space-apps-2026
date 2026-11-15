-- Layout check, run on the CLIENT during a playtest.
-- Every full-screen panel must stay inside the viewport. Part 1 measures the real panels in
-- Studio's viewport. Part 2 applies the same fit rule (scale to fit, centred on the panel's
-- own middle) to common phone and tablet screens, which Studio cannot be resized to.
local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local cam=workspace.CurrentCamera
local VP=cam.ViewportSize
-- AbsolutePosition is reported below Roblox's top bar even when a ScreenGui ignores the
-- inset, so add the inset back to get true screen coordinates.
local INSET=game:GetService("GuiService"):GetGuiInset()
local pass,fail,lines=0,{},{}
local function check(name,cond,detail)
  if cond then pass+=1 else table.insert(fail,name..(detail and ("  ["..detail.."]") or "")) end
end

local GUIS={"Archive","TrophyRoom","Controls","SurveyMap","Panel","Console","Handover"}
local sizes={}
for _,gname in ipairs(GUIS) do
  local g=pg:FindFirstChild(gname)
  if not g then check(gname.." exists",false) else
    -- the panel is the frame that owns a UIScale
    local panel
    for _,d in ipairs(g:GetDescendants()) do
      if d:IsA("UIScale") and d.Parent:IsA("Frame") then panel=d.Parent break end
    end
    if not panel then check(gname.." has a scaling panel",false) else
      local was=g.Enabled
      g.Enabled=true
      task.wait(0.15)
      local p,s=panel.AbsolutePosition+INSET,panel.AbsoluteSize
      g.Enabled=was
      local inside=p.X>=0 and p.Y>=0 and p.X+s.X<=VP.X+0.5 and p.Y+s.Y<=VP.Y+0.5
      local centred=math.abs((p.X+s.X/2)-VP.X/2)<2 and math.abs((p.Y+s.Y/2)-VP.Y/2)<2
      check(gname.." inside the viewport",inside,
        ("at %.0f,%.0f size %.0fx%.0f in %dx%d"):format(p.X,p.Y,s.X,s.Y,VP.X,VP.Y))
      check(gname.." centred",centred)
      local base=panel.Size.X.Offset
      sizes[gname]={panel.Size.X.Offset,panel.Size.Y.Offset}
      table.insert(lines,("%-11s %4dx%-4d -> on screen at (%4.0f,%4.0f)"):format(
        gname,panel.Size.X.Offset,panel.Size.Y.Offset,p.X,p.Y))
    end
  end
end

-- the same rule on screens Studio cannot imitate
local SCREENS={{"phone landscape",844,390},{"phone portrait",390,844},
  {"small phone",667,375},{"tablet",1180,820}}
for _,scr in ipairs(SCREENS) do
  local W,H=scr[2],scr[3]
  for gname,wh in pairs(sizes) do
    local w,h=wh[1],wh[2]
    local s=math.min(1,(W-20)/w,(H-20)/h)
    local left,top=(W-w*s)/2,(H-h*s)/2
    check(("%s fits a %s"):format(gname,scr[1]),
      left>=0 and top>=0 and left+w*s<=W and top+h*s<=H,
      ("scale %.2f, left %.0f top %.0f"):format(s,left,top))
  end
end

-- map markers: their outline must be a border, not an outline round the "?"
local map=pg:FindFirstChild("SurveyMap")
local stroked,bad=0,0
if map then
  for _,d in ipairs(map:GetDescendants()) do
    if d:IsA("UIStroke") and d.Parent:IsA("GuiButton") then
      stroked+=1
      if d.ApplyStrokeMode~=Enum.ApplyStrokeMode.Border then bad+=1 end
    end
  end
end
check("button outlines are borders ("..stroked.." checked)",bad==0)

local msg=("Layout: %d/%d passed\n%s"):format(pass,pass+#fail,table.concat(lines,"\n"))
if #fail>0 then msg=msg.."\nFAILED:\n  "..table.concat(fail,"\n  ") end
return msg
