--[[
	================================================================
	Script: Sistema de ESP Avançado com Interface Moderna
	Versão: 2.0
	Descrição: Sistema de ESP otimizado com interface gráfica moderna,
	configurações de cores avançadas e animações suaves.
	================================================================
]]

--// SERVIÇOS E CONFIGURAÇÕES GLOBAIS
--// =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer

-- Configuração principal do ESP
local ESP_CONFIG = {
	IsEnabled = false,
	FillColor = Color3.fromRGB(0, 255, 127),
	OutlineColor = Color3.fromRGB(255, 255, 255),
	FillTransparency = 0.6,
	OutlineTransparency = 0,
	Cache = {}
}

-- Cores predefinidas para seleção rápida
local PRESET_COLORS = {
	{Name = "Verde", Color = Color3.fromRGB(0, 255, 127)},
	{Name = "Vermelho", Color = Color3.fromRGB(255, 50, 50)},
	{Name = "Azul", Color = Color3.fromRGB(50, 150, 255)},
	{Name = "Amarelo", Color = Color3.fromRGB(255, 255, 0)},
	{Name = "Roxo", Color = Color3.fromRGB(150, 50, 255)},
	{Name = "Branco", Color = Color3.fromRGB(255, 255, 255)}
}

-- Configurações de animação
local ANIMATION_CONFIG = {
	Duration = 0.3,
	EasingStyle = Enum.EasingStyle.Quart,
	EasingDirection = Enum.EasingDirection.Out
}

-- Adicionando variáveis para controle de janela
local isMinimized = false
local isDragging = false
local dragStart = nil
local startPos = nil

--// FUNÇÕES UTILITÁRIAS
--// =================================================================

-- Cria uma animação de tween suave
local function createTween(object, properties, duration)
	duration = duration or ANIMATION_CONFIG.Duration
	local tweenInfo = TweenInfo.new(
		duration,
		ANIMATION_CONFIG.EasingStyle,
		ANIMATION_CONFIG.EasingDirection
	)
	return TweenService:Create(object, tweenInfo, properties)
end

-- Valida valores RGB (0-255)
local function validateRGB(r, g, b)
	return r and g and b and 
		   (r >= 0 and r <= 255) and 
		   (g >= 0 and g <= 255) and 
		   (b >= 0 and b <= 255)
end

-- Extrai números de uma string
local function extractNumbers(text)
	local numbers = {}
	for num in string.gmatch(text, "%d+") do
		table.insert(numbers, tonumber(num))
	end
	return numbers
end

--// SISTEMA DE ESP
--// =================================================================

-- Remove highlight de um jogador específico
local function removeHighlight(player)
	if ESP_CONFIG.Cache[player] then
		ESP_CONFIG.Cache[player]:Destroy()
		ESP_CONFIG.Cache[player] = nil
	end
end

-- Cria ou atualiza highlight para um jogador
local function createOrUpdateHighlight(player)
	local character = player.Character
	if not character or player == localPlayer then return end

	local highlight = ESP_CONFIG.Cache[player]
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight_" .. player.Name
		highlight.Parent = CoreGui
		ESP_CONFIG.Cache[player] = highlight
	end

	-- Atualiza propriedades do highlight
	highlight.Adornee = character
	highlight.Enabled = ESP_CONFIG.IsEnabled
	highlight.FillColor = ESP_CONFIG.FillColor
	highlight.OutlineColor = ESP_CONFIG.OutlineColor
	highlight.FillTransparency = ESP_CONFIG.FillTransparency
	highlight.OutlineTransparency = ESP_CONFIG.OutlineTransparency
end

-- Aplica ESP a todos os jogadores
local function applyToAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		createOrUpdateHighlight(player)
	end
end

-- Remove todos os highlights
local function removeAllHighlights()
	for player, _ in pairs(ESP_CONFIG.Cache) do
		removeHighlight(player)
	end
end

-- Atualiza cor de todos os highlights existentes
local function updateAllHighlightColors()
	if ESP_CONFIG.IsEnabled then
		applyToAllPlayers()
	end
end

--// CRIAÇÃO DA INTERFACE GRÁFICA
--// =================================================================

-- Cria o ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_GUI_Advanced"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Frame principal do menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = screenGui

-- Efeitos visuais do frame principal
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 120)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
})
mainGradient.Rotation = 45
mainGradient.Transparency = NumberSequence.new(0.95)
mainGradient.Parent = mainFrame

-- Título do menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
titleLabel.Text = "🎯 SISTEMA ESP AVANÇADO"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Adicionando botão de minimizar no título
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeButton.TextSize = 18
minimizeButton.Parent = titleLabel

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 15)
minimizeCorner.Parent = minimizeButton

-- Criando bolinha minimizada (inicialmente oculta)
local minimizedBall = Instance.new("TextButton")
minimizedBall.Name = "MinimizedBall"
minimizedBall.Size = UDim2.new(0, 50, 0, 50)
minimizedBall.Position = UDim2.new(0, 20, 0, 20)
minimizedBall.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
minimizedBall.Font = Enum.Font.SourceSansBold
minimizedBall.Text = "ESP"
minimizedBall.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedBall.TextSize = 12
minimizedBall.Visible = false
minimizedBall.Parent = screenGui

local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(0, 25)
ballCorner.Parent = minimizedBall

local ballStroke = Instance.new("UIStroke")
ballStroke.Color = Color3.fromRGB(255, 255, 255)
ballStroke.Thickness = 2
ballStroke.Parent = minimizedBall

-- Adicionando efeito de brilho na bolinha
local ballGradient = Instance.new("UIGradient")
ballGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
})
ballGradient.Rotation = 45
ballGradient.Transparency = NumberSequence.new(0.7)
ballGradient.Parent = minimizedBall

-- Frame de configuração de cores (inicialmente oculto)
local colorFrame = Instance.new("Frame")
colorFrame.Name = "ColorFrame"
colorFrame.Size = UDim2.new(0, 320, 0, 280)
colorFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
colorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
colorFrame.BorderSizePixel = 0
colorFrame.AnchorPoint = Vector2.new(0.5, 0.5)
colorFrame.Visible = false
colorFrame.Parent = screenGui

-- Efeitos visuais do frame de cores
local colorFrameCorner = mainCorner:Clone()
colorFrameCorner.Parent = colorFrame

local colorFrameStroke = mainStroke:Clone()
colorFrameStroke.Parent = colorFrame

local colorFrameGradient = mainGradient:Clone()
colorFrameGradient.Parent = colorFrame

-- Título do frame de cores
local colorTitleLabel = Instance.new("TextLabel")
colorTitleLabel.Name = "ColorTitleLabel"
colorTitleLabel.Size = UDim2.new(1, 0, 0, 40)
colorTitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
colorTitleLabel.Text = "🎨 CONFIGURAÇÃO DE CORES"
colorTitleLabel.Font = Enum.Font.SourceSansBold
colorTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorTitleLabel.TextSize = 16
colorTitleLabel.Parent = colorFrame

local colorTitleCorner = titleCorner:Clone()
colorTitleCorner.Parent = colorTitleLabel

-- Container para botões de cores predefinidas
local colorButtonsFrame = Instance.new("Frame")
colorButtonsFrame.Name = "ColorButtonsFrame"
colorButtonsFrame.Size = UDim2.new(0.9, 0, 0, 120)
colorButtonsFrame.Position = UDim2.new(0.5, 0, 0, 60)
colorButtonsFrame.AnchorPoint = Vector2.new(0.5, 0)
colorButtonsFrame.BackgroundTransparency = 1
colorButtonsFrame.Parent = colorFrame

local colorButtonsLayout = Instance.new("UIGridLayout")
colorButtonsLayout.CellSize = UDim2.new(0, 85, 0, 35)
colorButtonsLayout.CellPadding = UDim2.new(0, 5, 0, 5)
colorButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
colorButtonsLayout.Parent = colorButtonsFrame

-- Cria botões de cores predefinidas
for i, colorData in ipairs(PRESET_COLORS) do
	local colorButton = Instance.new("TextButton")
	colorButton.Name = "ColorButton_" .. colorData.Name
	colorButton.BackgroundColor3 = colorData.Color
	colorButton.Font = Enum.Font.SourceSansBold
	colorButton.Text = colorData.Name
	colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	colorButton.TextSize = 12
	colorButton.TextStrokeTransparency = 0
	colorButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	colorButton.Parent = colorButtonsFrame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = colorButton
	
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 255)
	buttonStroke.Thickness = 1
	buttonStroke.Transparency = 0.5
	buttonStroke.Parent = colorButton
	
	-- Evento de clique do botão de cor
	colorButton.MouseButton1Click:Connect(function()
		ESP_CONFIG.FillColor = colorData.Color
		updateAllHighlightColors()
		
		-- Animação de feedback
		local originalSize = colorButton.Size
		local tween1 = createTween(colorButton, {Size = originalSize * 0.9}, 0.1)
		local tween2 = createTween(colorButton, {Size = originalSize}, 0.1)
		
		tween1:Play()
		tween1.Completed:Connect(function()
			tween2:Play()
		end)
	end)
end

-- Campo de texto para cor personalizada
local customColorBox = Instance.new("TextBox")
customColorBox.Name = "CustomColorBox"
customColorBox.Size = UDim2.new(0.9, 0, 0, 35)
customColorBox.Position = UDim2.new(0.5, 0, 0, 195)
customColorBox.AnchorPoint = Vector2.new(0.5, 0)
customColorBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
customColorBox.PlaceholderText = "Digite R,G,B (ex: 255,100,50)"
customColorBox.Font = Enum.Font.SourceSans
customColorBox.TextColor3 = Color3.fromRGB(255, 255, 255)
customColorBox.TextSize = 14
customColorBox.ClearTextOnFocus = false
customColorBox.Parent = colorFrame

local customColorCorner = Instance.new("UICorner")
customColorCorner.CornerRadius = UDim.new(0, 6)
customColorCorner.Parent = customColorBox

local customColorStroke = Instance.new("UIStroke")
customColorStroke.Color = Color3.fromRGB(100, 100, 120)
customColorStroke.Thickness = 1
customColorStroke.Parent = customColorBox

-- Botão Voltar
local backButton = Instance.new("TextButton")
backButton.Name = "BackButton"
backButton.Size = UDim2.new(0.9, 0, 0, 35)
backButton.Position = UDim2.new(0.5, 0, 0, 240)
backButton.AnchorPoint = Vector2.new(0.5, 0)
backButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
backButton.Font = Enum.Font.SourceSansBold
backButton.Text = "⬅️ VOLTAR"
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.TextSize = 14
backButton.Parent = colorFrame

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backButton

local backStroke = customColorStroke:Clone()
backStroke.Parent = backButton

--// LÓGICA E EVENTOS DA INTERFACE
--// =================================================================

-- Atualiza aparência do botão toggle
local function updateToggleButtonVisuals()
	if ESP_CONFIG.IsEnabled then
		toggleButton.Text = "🟢 ESP: ATIVADO"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
	else
		toggleButton.Text = "🔴 ESP: DESATIVADO"
		toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	end
end

-- Toggle do ESP
local function onTogglePressed()
	ESP_CONFIG.IsEnabled = not ESP_CONFIG.IsEnabled
	updateToggleButtonVisuals()
	
	if ESP_CONFIG.IsEnabled then
		applyToAllPlayers()
	else
		removeAllHighlights()
	end
	
	-- Animação de feedback
	local tween = createTween(toggleButton, {Size = toggleButton.Size * 0.95}, 0.1)
	tween:Play()
	tween.Completed:Connect(function()
		createTween(toggleButton, {Size = UDim2.new(0.85, 0, 0, 40)}, 0.1):Play()
	end)
end

-- Abre menu de cores com animação
local function openColorMenu()
	colorFrame.Visible = true
	colorFrame.Size = UDim2.new(0, 0, 0, 0)
	
	local tween = createTween(colorFrame, {
		Size = UDim2.new(0, 320, 0, 280)
	}, 0.4)
	tween:Play()
	
	-- Esconde o menu principal
	createTween(mainFrame, {
		Size = UDim2.new(0, 0, 0, 0)
	}, 0.3):Play()
end

-- Fecha menu de cores com animação
local function closeColorMenu()
	local tween = createTween(colorFrame, {
		Size = UDim2.new(0, 0, 0, 0)
	}, 0.3)
	tween:Play()
	
	tween.Completed:Connect(function()
		colorFrame.Visible = false
	end)
	
	-- Mostra o menu principal
	createTween(mainFrame, {
		Size = UDim2.new(0, 280, 0, 180)
	}, 0.4):Play()
end

-- Processa cor personalizada
local function onCustomColorChanged()
	local text = customColorBox.Text
	local numbers = extractNumbers(text)
	
	if #numbers == 3 then
		local r, g, b = numbers[1], numbers[2], numbers[3]
		
		if validateRGB(r, g, b) then
			ESP_CONFIG.FillColor = Color3.fromRGB(r, g, b)
			customColorStroke.Color = Color3.fromRGB(50, 200, 100)
			updateAllHighlightColors()
		else
			customColorStroke.Color = Color3.fromRGB(255, 50, 50)
		end
	else
		customColorStroke.Color = Color3.fromRGB(255, 50, 50)
	end
end

-- Função para minimizar janela
local function minimizeWindow()
	isMinimized = true
	
	-- Anima o fechamento da janela principal
	local tween = createTween(mainFrame, {
		Size = UDim2.new(0, 0, 0, 0)
	}, 0.3)
	tween:Play()
	
	-- Mostra a bolinha após a animação
	tween.Completed:Connect(function()
		mainFrame.Visible = false
		minimizedBall.Visible = true
		minimizedBall.Size = UDim2.new(0, 0, 0, 0)
		
		-- Anima a aparição da bolinha
		createTween(minimizedBall, {
			Size = UDim2.new(0, 50, 0, 50)
		}, 0.3):Play()
	end)
end

-- Função para restaurar janela
local function restoreWindow()
	isMinimized = false
	
	-- Anima o desaparecimento da bolinha
	local tween = createTween(minimizedBall, {
		Size = UDim2.new(0, 0, 0, 0)
	}, 0.3)
	tween:Play()
	
	-- Mostra a janela principal após a animação
	tween.Completed:Connect(function()
		minimizedBall.Visible = false
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		
		-- Anima a aparição da janela
		createTween(mainFrame, {
			Size = UDim2.new(0, 280, 0, 180)
		}, 0.3):Play()
	end)
end

-- Função para iniciar arraste
local function startDrag(input)
	isDragging = true
	dragStart = input.Position
	startPos = mainFrame.Position
end

-- Função para atualizar posição durante arraste
local function updateDrag(input)
	if isDragging then
		local delta = input.Position - dragStart
		local newPosition = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		mainFrame.Position = newPosition
	end
end

-- Função para parar arraste
local function stopDrag()
	isDragging = false
end

-- Função para iniciar arraste da bolinha
local function startBallDrag(input)
	isDragging = true
	dragStart = input.Position
	startPos = minimizedBall.Position
end

-- Função para atualizar posição da bolinha durante arraste
local function updateBallDrag(input)
	if isDragging then
		local delta = input.Position - dragStart
		local newPosition = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		minimizedBall.Position = newPosition
	end
end

--// CONEXÕES DE EVENTOS
--// =================================================================

-- Eventos da interface
toggleButton.MouseButton1Click:Connect(onTogglePressed)
colorConfigButton.MouseButton1Click:Connect(openColorMenu)
backButton.MouseButton1Click:Connect(closeColorMenu)
customColorBox.FocusLost:Connect(onCustomColorChanged)

-- Eventos do botão minimizar
minimizeButton.MouseButton1Click:Connect(minimizeWindow)

-- Evento para restaurar da bolinha
minimizedBall.MouseButton1Click:Connect(restoreWindow)

-- Eventos de arraste da janela principal
titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		startDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag(input)
		updateBallDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		stopDrag()
	end
end)

-- Eventos de arraste da bolinha
minimizedBall.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		startBallDrag(input)
	end
end)

-- Eventos de jogadores
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		wait(0.1) -- Pequeno delay para garantir que o personagem carregou
		createOrUpdateHighlight(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	removeHighlight(player)
end)

-- Conecta jogadores já existentes
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		createOrUpdateHighlight(player)
	end
	player.CharacterAdded:Connect(function(character)
		wait(0.1)
		createOrUpdateHighlight(player)
	end)
end

--// INICIALIZAÇÃO
--// =================================================================

-- Adiciona GUI ao jogador
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Inicializa estado visual
updateToggleButtonVisuals()

-- Mensagem de inicialização
print("🎯 Sistema ESP Avançado carregado com sucesso!")
print("📋 Funcionalidades:")
print("   • Toggle ESP on/off")
print("   • 6 cores predefinidas")
print("   • Cores personalizadas RGB")
print("   • Interface moderna com animações")
print("   • Sistema otimizado de cache")
print("   • Janela arrastável e minimizável")
