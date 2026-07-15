--[[
    MONITOR DE TELA (sem automacao)
    ---------------------------------
    Este script SO LE informacoes que ja aparecem na tela do jogo
    (ex: texto de um cooldown, status de um botao) e te avisa com som +
    notificacao quando algo muda. Ele NAO clica em nada, NAO envia
    inputs e NAO executa acoes pelo jogador. Voce ainda precisa jogar
    manualmente.

    COMO CONFIGURAR:
    1. No Roblox Studio (ou no explorer do executor que voce usa),
       abra PlayerGui e ache o elemento de texto que mostra o cooldown
       ou status que voce quer monitorar (ex: um TextLabel que mostra
       "Pronto em: 4s" ou "Disponivel").
    2. Copie o caminho dele e cole na tabela ALVOS abaixo.
    3. Rode o script. Ele vai ficar de olho nesse texto e te avisar
       quando o valor mudar para o que voce configurou.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===================================================================
-- CONFIGURE AQUI: cada alvo eh um texto que voce quer monitorar
-- path: uma funcao que retorna a instancia do TextLabel/TextButton
-- condicao: funcao que recebe o texto atual e retorna true quando
--           deve disparar o aviso (ex: texto contem "Pronto")
-- ===================================================================
local ALVOS = {
    {
        nome = "Exemplo: Roll disponivel",
        path = function()
            -- Ajuste este caminho para o elemento real do jogo.
            -- Exemplo fake, substitua pelos nomes corretos:
            -- return playerGui:FindFirstChild("RollFrame", true) and
            --        playerGui.RollFrame.StatusLabel
            return nil
        end,
        condicao = function(texto)
            if not texto then return false end
            local t = texto:lower()
            return t:find("pronto") or t:find("disponivel") or t == "0s"
        end,
    },
    -- Adicione mais entradas aqui seguindo o mesmo formato
}

-- ===================================================================
-- UI DE AVISOS (overlay simples, azul celeste, so leitura)
-- ===================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MonitorTela"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local painel = Instance.new("Frame")
painel.Size = UDim2.new(0, 280, 0, 40)
painel.Position = UDim2.new(1, -300, 0, 20)
painel.BackgroundColor3 = Color3.fromRGB(235, 247, 255)
painel.BorderSizePixel = 0
painel.Parent = gui

local painelCorner = Instance.new("UICorner")
painelCorner.CornerRadius = UDim.new(0, 10)
painelCorner.Parent = painel

local painelStroke = Instance.new("UIStroke")
painelStroke.Color = Color3.fromRGB(56, 176, 255)
painelStroke.Thickness = 2
painelStroke.Parent = painel

local titulo = Instance.new("TextLabel")
titulo.Text = "Monitor: aguardando..."
titulo.Font = Enum.Font.GothamMedium
titulo.TextSize = 14
titulo.TextColor3 = Color3.fromRGB(20, 40, 60)
titulo.BackgroundTransparency = 1
titulo.Size = UDim2.new(1, -16, 1, 0)
titulo.Position = UDim2.new(0, 8, 0, 0)
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextTruncate = Enum.TextTruncate.AtEnd
titulo.Parent = painel

local function piscarAviso(texto)
    titulo.Text = texto
    TweenService:Create(painel, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 225, 255)}):Play()
    task.wait(0.3)
    TweenService:Create(painel, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(235, 247, 255)}):Play()

    -- Som de notificacao (padrao do Roblox)
    local som = Instance.new("Sound")
    som.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    som.Volume = 0.6
    som.Parent = SoundService
    som:Play()
    game:GetService("Debris"):AddItem(som, 2)
end

-- ===================================================================
-- LOOP DE LEITURA (so le texto, nunca clica ou envia input)
-- ===================================================================
local ultimoEstado = {}

task.spawn(function()
    while true do
        for _, alvo in ipairs(ALVOS) do
            local ok, instancia = pcall(alvo.path)
            if ok and instancia then
                local texto = instancia.Text
                local jaAvisado = ultimoEstado[alvo.nome]

                if alvo.condicao(texto) and not jaAvisado then
                    piscarAviso(alvo.nome .. " -> " .. tostring(texto))
                    ultimoEstado[alvo.nome] = true
                elseif not alvo.condicao(texto) then
                    ultimoEstado[alvo.nome] = false
                end
            end
        end
        task.wait(1) -- checa a cada 1 segundo
    end
end)
