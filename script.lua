--// Sky UI + Console Editável
--// Roblox Studio LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")


local gui = Instance.new("ScreenGui")
gui.Name = "SkyUI"
gui.ResetOnSpawn = false
gui.Parent = guiParent


-- Função arredondar
local function round(obj, size)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,size)
	c.Parent = obj
end


-- Janela principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0,500,0,320)
main.Position = UDim2.new(0.5,-250,0.5,-160)
main.BackgroundColor3 = Color3.fromRGB(20,30,45)
main.Parent = gui

round(main,16)


local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(80,210,255)
border.Thickness = 2
border.Parent = main



-- Barra de título (arrastar)
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,50)
top.BackgroundTransparency = 1
top.Parent = main


local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "☁ Sky UI"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = top



-- Sistema Drag
local dragging = false
local dragStart
local startPos


top.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

	end

end)


UserInputService.InputChanged:Connect(function(input)

	if dragging then
		
		local delta = input.Position - dragStart
		
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

	end

end)


UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

	end

end)



-- Botão abrir console
local open = Instance.new("TextButton")
open.Size = UDim2.new(0,180,0,45)
open.Position = UDim2.new(0,30,0,90)
open.Text = "Abrir Console"
open.Font = Enum.Font.GothamBold
open.TextSize = 18
open.TextColor3 = Color3.new(1,1,1)
open.BackgroundColor3 = Color3.fromRGB(80,210,255)
open.Parent = main

round(open,12)



-- Console
local console = Instance.new("Frame")
console.Size = UDim2.new(0,450,0,280)
console.Position = UDim2.new(0.5,-225,0.5,-140)
console.BackgroundColor3 = Color3.fromRGB(15,20,30)
console.Parent = gui
console.Visible = false

round(console,14)



local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1,-50,0,40)
consoleTitle.Position = UDim2.new(0,10,0,0)
consoleTitle.Text = "📜 Console"
consoleTitle.TextColor3 = Color3.fromRGB(120,220,255)
consoleTitle.BackgroundTransparency = 1
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.TextSize = 20
consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
consoleTitle.Parent = console



-- Fechar console
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,35,0,35)
close.Position = UDim2.new(1,-40,0,5)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(255,80,80)
close.Parent = console

round(close,10)



-- Área de logs
local logs = Instance.new("ScrollingFrame")
logs.Size = UDim2.new(1,-20,0,140)
logs.Position = UDim2.new(0,10,0,45)
logs.BackgroundColor3 = Color3.fromRGB(8,12,20)
logs.Parent = console
logs.ScrollBarThickness = 5


local layout = Instance.new("UIListLayout")
layout.Parent = logs
layout.Padding = UDim.new(0,4)



-- Caixa editar
local input = Instance.new("TextBox")
input.Size = UDim2.new(0,280,0,35)
input.Position = UDim2.new(0,10,1,-45)
input.PlaceholderText = "Digite uma mensagem..."
input.Text = ""
input.TextColor3 = Color3.new(1,1,1)
input.BackgroundColor3 = Color3.fromRGB(30,40,55)
input.Parent = console

round(input,8)



local send = Instance.new("TextButton")
send.Size = UDim2.new(0,90,0,35)
send.Position = UDim2.new(1,-100,1,-45)
send.Text = "Enviar"
send.BackgroundColor3 = Color3.fromRGB(80,210,255)
send.TextColor3 = Color3.new(1,1,1)
send.Parent = console

round(send,8)



-- Sistema de log
local function AddLog(text, tipo)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-10,0,25)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Code
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left

	label.Text =
		"["..os.date("%H:%M:%S").."] ["..tipo.."] "..text


	if tipo == "ERROR" then
		label.TextColor3 = Color3.fromRGB(255,80,80)

	elseif tipo == "SUCCESS" then
		label.TextColor3 = Color3.fromRGB(80,255,120)

	else
		label.TextColor3 = Color3.fromRGB(120,220,255)

	end


	label.Parent = logs

	task.wait()

	logs.CanvasSize =
		UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)

end



send.MouseButton1Click:Connect(function()

	if input.Text ~= "" then
		
		AddLog(input.Text,"USER")
		input.Text = ""

	end

end)



open.MouseButton1Click:Connect(function()

	console.Visible = true
	AddLog("Console aberto","SUCCESS")

end)



close.MouseButton1Click:Connect(function()

	console.Visible = false

end)



AddLog("Sky UI carregada","SUCCESS")
AddLog("Console pronto","INFO")
