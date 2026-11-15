-- ModuleScript  ReplicatedStorage/UIKit
-- Shared GUI builder following the figma-to-roblox-ui rules:
--   * Scale everywhere, Offset = 0 (Size, Position, padding, corner radius, stroke).
--   * AnchorPoint (0.5,0.5) by default; any other anchor must say why (AnchorReason).
--   * UIStroke in ScaledSize mode, UICorner in Scale, TextScaled + UITextSizeConstraint.
--   * Proportions held with UIAspectRatioConstraint, never with UIScale (UIScale mis-scales
--     ScaledSize strokes).
-- Every element is placed from a design frame measured in px (the "mockup"), and converted
-- to Scale relative to its direct parent -- so nothing here can ever produce an Offset.
local K={}
local CENTER=Vector2.new(0.5,0.5)

function K.r4(n) return math.floor(n*10000+0.5)/10000 end

function K.new(cls,props,parent)
  local o=Instance.new(cls)
  for k,v in pairs(props or {}) do o[k]=v end
  if parent then o.Parent=parent end
  return o
end

-- design px (x,y,w,h) inside a parent of design size (pw,ph) -> Scale
function K.place(obj,x,y,w,h,pw,ph,anchor,reason)
  anchor=anchor or CENTER
  if anchor~=CENTER then
    assert(reason,obj.Name..": non-centre AnchorPoint needs a reason")
    obj:SetAttribute("AnchorReason",reason)
  end
  obj.AnchorPoint=anchor
  obj.Size=UDim2.fromScale(K.r4(w/pw),K.r4(h/ph))
  obj.Position=UDim2.fromScale(K.r4((x+w*anchor.X)/pw),K.r4((y+h*anchor.Y)/ph))
  return obj
end

function K.corner(obj,radiusPx,w,h)
  return K.new("UICorner",{CornerRadius=UDim.new(math.min(0.5,K.r4(radiusPx/math.min(w,h))),0)},obj)
end

function K.stroke(obj,weightPx,w,h,color,transparency)
  return K.new("UIStroke",{
    StrokeSizingMode=Enum.StrokeSizingMode.ScaledSize,
    Thickness=K.r4(weightPx/math.min(w,h)),
    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    Color=color, Transparency=transparency or 0,
  },obj)
end

function K.aspect(obj,w,h,axis)
  return K.new("UIAspectRatioConstraint",{AspectRatio=w/h,
    DominantAxis=axis or Enum.DominantAxis.Width},obj)
end

function K.text(obj,designSize)
  obj.TextScaled=true
  K.new("UITextSizeConstraint",{MaxTextSize=math.floor(designSize*1.5),MinTextSize=8},obj)
  return obj
end

-- a text label in one call
function K.label(parent,name,text,font,color,size,x,y,w,h,pw,ph,align)
  local l=K.new("TextLabel",{Name=name,BackgroundTransparency=1,Font=font,TextColor3=color,
    Text=text,TextXAlignment=align or Enum.TextXAlignment.Left,TextWrapped=true},parent)
  K.place(l,x,y,w,h,pw,ph)
  K.text(l,size)
  return l
end

-- the skill's validator: returns a list of rule breaks under root (empty = clean)
function K.validate(root)
  local bad={}
  local function udim(v) return typeof(v)=="UDim" and v.Offset~=0 end
  local function udim2(v) return typeof(v)=="UDim2" and (v.X.Offset~=0 or v.Y.Offset~=0) end
  for _,d in ipairs(root:GetDescendants()) do
    local p=d:GetFullName()
    if d:IsA("GuiObject") then
      if udim2(d.Size) then table.insert(bad,p.." Size offset") end
      if udim2(d.Position) then table.insert(bad,p.." Position offset") end
      if d.AnchorPoint~=CENTER and not d:GetAttribute("AnchorReason") then
        table.insert(bad,p.." AnchorPoint not centre (set AnchorReason if intentional)") end
      if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and not d.TextScaled then
        table.insert(bad,p.." TextScaled=false") end
    elseif d:IsA("UIStroke") then
      if d.StrokeSizingMode~=Enum.StrokeSizingMode.ScaledSize then table.insert(bad,p.." Stroke not ScaledSize") end
      if d.Thickness>1 then table.insert(bad,p.." Stroke Thickness>1 (looks like px)") end
    elseif d:IsA("UICorner") then
      if udim(d.CornerRadius) then table.insert(bad,p.." CornerRadius offset") end
    elseif d:IsA("UIListLayout") then
      if udim(d.Padding) then table.insert(bad,p.." Padding offset") end
    elseif d:IsA("UIPadding") then
      for _,k in ipairs({"PaddingLeft","PaddingRight","PaddingTop","PaddingBottom"}) do
        if udim(d[k]) then table.insert(bad,p.." "..k.." offset") end
      end
    elseif d:IsA("UIScale") then
      table.insert(bad,p.." UIScale present (mis-scales ScaledSize strokes)")
    end
  end
  return bad
end

-- ---------- converter for screens first written in pixels ----------
-- Rewrites a finished pixel layout into the skill's form, keeping exactly how it looks at
-- the 1280x720 design frame: every Size/Position/padding/corner/stroke becomes Scale of the
-- direct parent, text becomes TextScaled (capped at the old size x1.5), UIScale is removed and
-- the root panels get a UIAspectRatioConstraint so they keep their shape on phones.
-- Objects keep their original AnchorPoint when the screen's own code positions them by it;
-- that is recorded in AnchorReason. Later changes that bring Offsets back are converted again.
local DW,DH=1280,720
local function px(u,pw,ph) return u.X.Scale*pw+u.X.Offset, u.Y.Scale*ph+u.Y.Offset end
local function hasOff(u) return u.X.Offset~=0 or u.Y.Offset~=0 end
local convert
local function designOf(o)
  local w,h=o:GetAttribute("DW"),o:GetAttribute("DH")
  if w then return w,h end
  if o:IsA("LayerCollector") or not o:IsA("GuiObject") then return DW,DH end
  local pw,ph=designOf(o.Parent)
  return px(o.Size,pw,ph)
end
local function convertProps(o,pw,ph)
  if o:IsA("GuiObject") then
    local w,h=px(o.Size,pw,ph)
    if o.AutomaticSize~=Enum.AutomaticSize.None then
      -- self-sizing: freeze at the size it has laid out to, in design px
      local par=o.Parent
      local k=(par and par:IsA("GuiObject") and par.AbsoluteSize.X>0) and pw/par.AbsoluteSize.X or 1
      w,h=math.max(w,o.AbsoluteSize.X*k),math.max(h,o.AbsoluteSize.Y*k)
      if o:IsA("TextLabel") or o:IsA("TextButton") then
        local ok,sz=pcall(function() return game:GetService("TextService"):GetTextSize(o.Text,o.TextSize,o.Font,Vector2.new(math.max(w,1),1e4)) end)
        h=math.max(h,(ok and sz.Y or 0)+2,o.TextSize*1.4)
      end
      o.AutomaticSize=Enum.AutomaticSize.None
    end
    local x,y=px(o.Position,pw,ph)
    o:SetAttribute("DW",w); o:SetAttribute("DH",h)
    o.Size=UDim2.fromScale(K.r4(w/pw),K.r4(h/ph))
    o.Position=UDim2.fromScale(K.r4(x/pw),K.r4(y/ph))
    if o.AnchorPoint~=CENTER and not o:GetAttribute("AnchorReason") then
      o:SetAttribute("AnchorReason","positioned by this anchor in the screen's own layout code")
    end
    if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and not o.TextScaled then
      local ts=o.TextSize; o.TextScaled=true
      if not o:FindFirstChildOfClass("UITextSizeConstraint") then
        K.new("UITextSizeConstraint",{MaxTextSize=math.max(9,math.floor(ts*1.15)),MinTextSize=math.min(8,ts)},o)
      end
    end
    if o:IsA("ScrollingFrame") then
      o.ScrollBarThickness=math.max(4,o.ScrollBarThickness)
    end
  elseif o:IsA("UIStroke") then
    if o.StrokeSizingMode~=Enum.StrokeSizingMode.ScaledSize then
      local m=math.max(1,math.min(pw,ph))
      o.StrokeSizingMode=Enum.StrokeSizingMode.ScaledSize
      o.Thickness=K.r4(o.Thickness/m)
    end
  elseif o:IsA("UICorner") then
    local r=o.CornerRadius
    if r.Offset~=0 then o.CornerRadius=UDim.new(math.min(0.5,K.r4(r.Scale+r.Offset/math.max(1,math.min(pw,ph)))),0) end
  elseif o:IsA("UIListLayout") then
    local pd=o.Padding
    if pd.Offset~=0 then
      local along=o.FillDirection==Enum.FillDirection.Horizontal and pw or ph
      o.Padding=UDim.new(K.r4(pd.Scale+pd.Offset/math.max(1,along)),0)
    end
  elseif o:IsA("UIGridLayout") then
    local cw,ch=px(o.CellSize,pw,ph); local gx,gy=px(o.CellPadding,pw,ph)
    o.CellSize=UDim2.fromScale(K.r4(cw/pw),K.r4(ch/ph)); o.CellPadding=UDim2.fromScale(K.r4(gx/pw),K.r4(gy/ph))
  elseif o:IsA("UIPadding") then
    for _,k in ipairs({"PaddingLeft","PaddingRight"}) do local v=o[k]; if v.Offset~=0 then o[k]=UDim.new(K.r4(v.Scale+v.Offset/pw),0) end end
    for _,k in ipairs({"PaddingTop","PaddingBottom"}) do local v=o[k]; if v.Offset~=0 then o[k]=UDim.new(K.r4(v.Scale+v.Offset/ph),0) end end
  elseif o:IsA("UIScale") then
    o.Parent=nil
  end
end
local watched=setmetatable({},{__mode="k"})
local function watch(o)
  if watched[o] or not o:IsA("GuiObject") then return end
  watched[o]=true
  local busy=false
  local function again()
    if busy then return end
    if not (hasOff(o.Size) or hasOff(o.Position)) then
      -- pure Scale written by the screen's code: just refresh the stored design size
      local pw,ph=designOf(o.Parent); local w,h=px(o.Size,pw,ph); o:SetAttribute("DW",w); o:SetAttribute("DH",h)
      return
    end
    busy=true; local pw,ph=designOf(o.Parent); convertProps(o,pw,ph); busy=false
  end
  o:GetPropertyChangedSignal("Size"):Connect(again)
  o:GetPropertyChangedSignal("Position"):Connect(again)
end
convert=function(o)
  if o:GetAttribute("NoScale") then return end
  if not o:IsA("LayerCollector") then
    local pw,ph=designOf(o.Parent)
    -- strokes/corners/paddings measure against their owner, not the owner's parent
    if not o:IsA("GuiObject") then pw,ph=designOf(o.Parent) end
    convertProps(o,pw,ph); watch(o)
  end
  for _,c in ipairs(o:GetChildren()) do convert(c) end
end
function K.adopt(gui)
  -- root panels: hold their designed shape
  for _,c in ipairs(gui:GetChildren()) do
    if c:IsA("GuiObject") and not c:FindFirstChildOfClass("UIAspectRatioConstraint") then
      local w,h=px(c.Size,DW,DH)
      if w>40 and h>40 and w<DW*0.98 and h<DH*0.98 then K.new("UIAspectRatioConstraint",{AspectRatio=w/h},c) end
    end
  end
  convert(gui)
  gui.DescendantAdded:Connect(function(d) task.defer(function() if d.Parent then convert(d) end end) end)
end

return K
