local addonName, addonTable = ...

local tooltip = {}
addonTable.tooltip = tooltip

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local GameTooltip = _G.GameTooltip
local NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR = _G.NORMAL_FONT_COLOR, _G.HIGHLIGHT_FONT_COLOR

local tframe = CreateFrame("frame", nil, _G.UIParent)
tframe:Hide()
tframe.lines = {}
tframe.columns = {}
tframe:SetClampedToScreen(true)
tframe:SetFrameStrata("FULLSCREEN_DIALOG")
local H_PADDING = 6
local V_PADDING = 3
local H_MARGIN = 10
local V_MARGIN = 10

local ResetTooltipSize, SetTooltipSize
local _SetLineScript

local acquireCell, releaseCell, acquireColumn, releaseColumn, acquireLine, releaseLine
do
	local cells, columns, lines = {}, {}, {}
	function acquireCell()
		local cell = table.remove(cells)
		if not cell then
			cell = CreateFrame("frame")
			cell.fontString = cell:CreateFontString()
			cell.fontString:SetAllPoints(cell)
			cell.fontString:SetNonSpaceWrap(false)
		end
		return cell
	end
	function releaseCell(cell)
		cell:Hide()
		cell:ClearAllPoints()
		cell:SetParent(nil)
		table.insert(cells, cell)
	end
	function acquireColumn()
		local col = table.remove(columns)
		if not col then
			col = CreateFrame("frame")
		end
		return col
	end
	function releaseColumn(col)
		col:Hide()
		col:ClearAllPoints()
		col:SetParent(nil)
		table.insert(columns, col)
	end
	function acquireLine()
		local line = table.remove(lines)
		if not line then
			line = CreateFrame("frame")
			line.cells = {}
			line.scripts = {}
		end
		return line
	end
	function releaseLine(line)
		line:Hide()
		line:ClearAllPoints()
		line:SetParent(nil)
		for k in pairs(line.scripts) do
			_SetLineScript(line, k, nil)
		end
		table.insert(lines, line)
	end
end

-- Clear([col1, [padding1,] col2, [padding2,] ...])
--
-- Clears the tooltip of all lines.
-- If arguments are given, this sets up the column layout for the tooltip.
-- Each column argument is a string denoting the column justification,
-- either "LEFT", "CENTER", or "RIGHT".
-- Between each column is an optional number denoting the padding to use between the columns.
-- If no padding is given, a default is used.
function tooltip:Clear(...)
	for i, line in ipairs(tframe.lines) do
		for j, cell in ipairs(line.cells) do
			if cell then releaseCell(cell) end
			line.cells[j] = nil
		end
		releaseLine(line)
		tframe.lines[i] = nil
	end

	if select('#', ...) > 0 then
		for i, col in ipairs(tframe.columns) do
			releaseColumn(col)
			tframe.columns[i] = nil
		end

		local i, n = 1, select('#', ...)
		while i <= n do
			local arg = select(i, ...)
			i = i + 1
			local padding = H_PADDING
			if type(arg) == "number" then
				if arg < 0 then
					error("Padding cannot be less than zero", 2)
				end
				if #tframe.columns == 0 then
					error("Padding cannot be given before the first column", 2)
				elseif i > n then
					error("Padding cannot be given after the last column", 2)
				end
				padding = arg
				arg = select(i, ...)
				i = i + 1
			end
			if arg ~= "LEFT" and arg ~= "CENTER" and arg ~= "RIGHT" then
				error("Unexpected column specification given: " .. tostring(arg), 2)
			end

			local col = acquireColumn()
			col.justification = arg
			col.width = 0
			col:SetWidth(1)
			col:SetParent(tframe)
			col:SetPoint("TOP", tframe)
			col:SetPoint("BOTTOM", tframe)
			col:SetFrameLevel(tframe:GetFrameLevel() + 1)
			if #tframe.columns > 0 then
				col:SetPoint("LEFT", tframe.columns[#tframe.columns], "RIGHT", padding, 0)
				col.left_padding = padding
			else
				col:SetPoint("LEFT", tframe, "LEFT", H_MARGIN, 0)
				col.left_padding = 0
			end
			col:Show()
			table.insert(tframe.columns, col)
		end
	else
		for i, col in ipairs(tframe.columns) do
			col.width = 0
			col:SetWidth(1)
		end
	end

	ResetTooltipSize()

	-- pull current GameTooltip values
	tframe:SetBackdrop(GameTooltip:GetBackdrop())
	tframe:SetBackdropColor(GameTooltip:GetBackdropColor())
	tframe:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
	tframe:SetScale(GameTooltip:GetScale())
	tframe.font = _G.GameTooltipText
	tframe.headerFont = _G.GameTooltipHeaderText
end

-- local
function ResetTooltipSize()
	local width, height = 0, 0
	for _, col in ipairs(tframe.columns) do
		width = width + col.left_padding + col.width
	end
	for _, line in ipairs(tframe.lines) do
		height = height + line.top_padding + line.height
	end
	SetTooltipSize(width, height)
end

-- local
function SetTooltipSize(width, height)
	tframe.width = width
	tframe:SetWidth(2*H_MARGIN + width)
	tframe.height = height
	tframe:SetHeight(2*V_MARGIN + height)
end

local _AddLine

-- AddLine(value1, ...)
--
-- Adds a line to the tooltip.
-- The number of values provided may not be larger than the number of columns.
-- A nil or missing value for a column leaves an empty cell.
-- Providing no values adds a blank line.
--
-- Returns the index of the line that was added.
do
	local t = {}
	function tooltip:AddLine(...)
		table.wipe(t)
		local i, j, n = 1, 1, select('#', ...)
		while i <= n do
			t[j] = 1
			--t[j+1] = nil
			t[j+2] = select(i, ...)
			j = j + 3
			i = i + 1
		end
		local ok, ret = pcall(self.AddColspanLine, self, unpack(t, 1, j-1))
		if not ok then
			error(ret, 2)
		end
		return ret
	end
end

-- AddColspanLine(colCount1, justification1, value1, colCount2, justification2, value2, ...)
--
-- Adds a line to the tooltip, with colspans.
-- Each value is preceeded by a number indicating the number of columns it is to span,
-- and a justification for the colspan. A nil justification uses the justification of the first column.
--
-- Returns the index of the line that was added.
function tooltip:AddColspanLine(...)
	return _AddLine(false, ...)
end

-- AddHeader(value1, ...)
--
-- Adds a header line to the tooltip.
--
-- Returns the index of the line that was added.
do
	local t = {}
	function tooltip:AddHeader(...)
		table.wipe(t)
		local i, j, n = 1, 1, select('#', ...)
		while i <= n do
			t[j] = 1
			--t[j+1] = nil
			t[j+2] = select(i, ...)
			j = j + 3
			i = i + 1
		end
		local ok, ret = pcall(self.AddColspanHeader, self, unpack(t, 1, j-1))
		if not ok then
			error(ret, 2)
		end
		return ret
	end
end

-- AddColspanHeader(colCount1, justification1, value1, colCount2, justification2, value2, ...)
--
-- Adds a header line to the tooltip, with colspans.
--
-- Returns the index of the line that was added.
function tooltip:AddColspanHeader(...)
	return _AddLine(true, ...)
end

-- local
function _AddLine(isHeader, ...)
	local line = acquireLine()
	line:SetParent(tframe)
	line:SetFrameLevel(tframe:GetFrameLevel()+1)
	line:SetPoint("LEFT", tframe, "LEFT", H_MARGIN, 0)
	line:SetPoint("RIGHT", tframe, "RIGHT", -H_MARGIN, 0)
	if #tframe.lines > 0 then
		line:SetPoint("TOP", tframe.lines[#tframe.lines], "BOTTOM", 0, -V_PADDING)
		line.top_padding = V_PADDING
	else
		line:SetPoint("TOP", tframe, "TOP", 0, -V_MARGIN)
		line.top_padding = 0
	end
	local font = isHeader and tframe.headerFont or tframe.font
	line.height = select(2, font:GetFont())
	line:SetHeight(line.height)
	line:Show()
	table.insert(tframe.lines, line)

	SetTooltipSize(tframe.width, tframe.height + line.height + line.top_padding)

	local coli = 1
	for i = 1, select('#', ...), 3 do
		local count, justification, value = select(i, ...)
		if type(count) ~= "number" or count < 1 then
			error("Column count must be a positive number, not "..tostring(count), 2)
		end
		local left, right = coli, coli + count - 1
		coli = coli + count
		if count > #tframe.columns then
			error("Not enough columns", 2)
		end
		if justification == nil then
			justification = tframe.columns[left].justification
		elseif justification ~= "LEFT" and justification ~= "CENTER" and justification ~= "RIGHT" then
			error("Unexpected value given for justification: "..tostring(justification), 2)
		end

		for i = left, right do
			line.cells[i] = false -- so ipairs works as expected
		end
		if value ~= nil then
			local cell = acquireCell(line)
			cell.fontString:SetFontObject(font)
			if isHeader then
				cell.fontString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			else
				cell.fontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			end
			cell.fontString:SetText(tostring(value))
			cell.fontString:SetJustifyH(justification)
			cell.fontString:SetJustifyV("TOP")
			cell:SetParent(line)
			cell:SetPoint("LEFT", tframe.columns[left])
			cell:SetPoint("RIGHT", tframe.columns[right])
			cell:SetPoint("TOP", line)
			cell:SetPoint("BOTTOM", line)
			cell:Show()
			line.cells[left] = cell

			local colwidth = tframe.columns[left].width
			for i = left+1, right do
				local col = tframe.columns[i]
				colwidth = colwidth + col.left_padding + col.width
			end
			local delta = cell.fontString:GetStringWidth() - colwidth
			if delta > 0 then
				-- enlarge the right column
				local width = tframe.columns[right].width
				width = width + delta
				tframe.columns[right].width = width
				tframe.columns[right]:SetWidth(width)
				SetTooltipSize(tframe.width + delta, tframe.height)
			end
		end
	end

	return #tframe.lines
end

-- SetLineScript(index, event, handler, ...)
--
-- Sets an event handler for the line at the given index.
-- Event may be one of: "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp".
-- A nil handler removes the event.
-- Any extra arguments are passed to the event handler before the event's own arguments,
-- but after the frame argument.
do
	local heap = {}
	local invoket = {}
	local function invoke(frame, script, ...)
		if script.count == 0 then
			script.handler(frame, ...)
		else
			table.wipe(invoket)
			local count, n = script.count, select('#', ...)
			for i = 1, count do
				invoket[i] = script[i]
			end
			for i = 1, n do
				invoket[count+i] = select(i, ...)
			end
			script.handler(frame, unpack(invoket, 1, count+n))
			table.wipe(invoket)
		end
	end
	local highlight = CreateFrame("frame", nil, _G.UIParent)
	highlight:Hide()
	do
		local texture = highlight:CreateTexture(nil, "OVERLAY")
		texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		texture:SetBlendMode("ADD")
		texture:SetAllPoints(highlight)
	end
	local handlers = {
		OnEnter = function(frame, ...)
			highlight:SetParent(frame)
			highlight:SetAllPoints(frame)
			highlight:Show()
			local script = frame.scripts.OnEnter
			if script then
				invoke(frame, script, ...)
			end
		end,
		OnLeave = function(frame, ...)
			highlight:SetParent(nil)
			highlight:ClearAllPoints()
			highlight:Hide()
			local script = frame.scripts.OnLeave
			if script then
				invoke(frame, script, ...)
			end
		end,
		OnMouseDown = function(frame, ...)
			invoke(frame, frame.scripts.OnMouseDown, ...)
		end,
		OnMouseUp = function(frame, ...)
			invoke(frame, frame.scripts.OnMouseUp, ...)
		end,
	}

	function tooltip:SetLineScript(index, event, handler, ...)
		if type(index) ~= "number" or index < 1 then
			error("Index must be a positive number", 2)
		elseif index > #tframe.lines then
			error("Index is out of bounds", 2)
		elseif handlers[event] == nil then
			error("Unknown event handler", 2)
		end
		_SetLineScript(tframe.lines[index], event, handler, ...)
	end

	function _SetLineScript(line, event, handler, ...)
		if handler == nil then
			if line.scripts[event] then
				table.wipe(line.scripts[event])
				table.insert(heap, line.scripts[event])
				line.scripts[event] = nil
				if event ~= "OnEnter" and event ~= "OnLeave" then
					line:SetScript(event, nil)
				end
				if next(line.scripts) == nil then
					line:SetScript("OnEnter", nil)
					line:SetScript("OnLeave", nil)
					line:EnableMouse(false)
				end
			end
			return
		end
		local script = line.scripts[event] or table.remove(heap) or {}
		table.wipe(script) -- in case we're overwriting an existing script
		script.count = select('#', ...)
		for i = 1, script.count do
			script[i] = select(i, ...)
		end
		script.handler = handler
		if not line.scripts[event] then
			if not next(line.scripts) then
				line:SetScript("OnEnter", handlers.OnEnter)
				line:SetScript("OnLeave", handlers.OnLeave)
				line:EnableMouse(true)
			end
			if event ~= "OnEnter" and event ~= "OnLeave" then
				line:SetScript(event, handlers[event])
			end
		end
		if line.scripts[event] and not rawequal(line.scripts[event], script) then
			table.insert(heap, line.scripts[event])
		end
		line.scripts[event] = script
	end
end

-- Lifted from Cork, but also appears almost-unchanged in LibQTip. Did this come from somewhere common?
local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", frame, "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

-- SmartAnchorTo(frame)
--
-- Anchors the tooltip to the frame, smartly.
function tooltip:SmartAnchorTo(frame)
	if not frame or type(frame) ~= "table" or not frame.IsObjectType or not frame:IsObjectType("Region") then
		error("Invalid frame", 2)
	end
	tframe:ClearAllPoints()
	tframe:SetPoint(GetTipAnchor(frame))
end

-- SetAutoHideDelay(delay[, frame])
--
-- Automatically hides the tooltip if the mouse stays off of the tooltip
-- (or `frame`, if given) for `delay` seconds.
-- If `delay` is nil, does not auto-hide.
do
	local function timer_OnUpdate(self, elapsed)
		-- only check every 0.1 seconds
		self.interval = self.interval + elapsed
		if self.interval > 0.1 then
			if tframe:IsMouseOver() or (self.frame and self.frame:IsMouseOver()) then
				-- mouse is still over, reset the timer
				self.elapsed = 0
			else
				-- count up the elapsed time, check if it passed our threshold
				self.elapsed = self.elapsed + self.interval
				if self.elapsed >= self.delay then
					tooltip:Hide()
				end
			end
			self.interval = 0
		end
	end
	local timer
	function tooltip:SetAutoHideDelay(delay, frame)
		if delay ~= nil and (type(delay) ~= "number" or delay < 0) then
			error("Delay must be a non-negative number", 2)
		end
		if frame ~= nil and (type(frame) ~= "table" or not frame.IsObjectType or not frame:IsObjectType("Region")) then
			error("Invalid frame", 2)
		end
		if not delay and timer and timer:IsShown() then
			timer:Hide()
			timer.frame = nil
		elseif delay then
			if not timer then
				timer = CreateFrame("frame")
				timer:SetScript("OnUpdate", timer_OnUpdate)
			end
			timer.elapsed = 0
			timer.delay = 0
			timer.interval = 0
			timer.frame = frame
			timer:Show()
		end
	end
end

--[[ Frame methods ]]

-- IsVisible()
--
-- Returns if the tooltip is visible.
function tooltip:IsVisible()
	return tframe:IsVisible()
end

-- IsShown()
--
-- Returns if the tooltip is shown.
function tooltip:IsShown()
	return tframe:IsShown()
end

-- Show()
--
-- Shows the tooltip.
function tooltip:Show()
	tframe:Show()
end

-- Hide()
--
-- Hides the tooltip.
function tooltip:Hide()
	self:SetAutoHideDelay(nil)
	tframe:Hide()
end
