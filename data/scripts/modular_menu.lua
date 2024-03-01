local WEAPONS = {"Weapon1", "Weapon2", "Weapon3"} -- Example list of weapons

-- Button class
local Button = {}

function Button:new(img, hoverimg, x, y, width, height)
    local newObj = {
        img = img,
        hoverimg = hoverimg,
        x = x,
        y = y,
        width = width,
        height = height,
        hovered = false,
        functionToCall = nil
    }
    setmetatable(newObj, self)
    self.__index = self
    return newObj
end

function Button:setFunction(func)
    self.functionToCall = func
end

function Button:checkHover(mouseX, mouseY)
    self.hovered = (mouseX >= self.x and mouseX <= self.x + self.width and mouseY >= self.y and mouseY <= self.y + self.height)
end

function Button:handleRightClick()
    if self.hovered and self.functionToCall then
        self.functionToCall()
    end
end

function Button:draw()
    local img = self.hovered and self.hoverimg or self.img
    Hyperspace.Resources.RenderImageString(img, self.x, self.y, 0, {r=1, g=1, b=1, a=1}, 1, false)
end

-- Frame class
local Frame = {}

function Frame:new(x, y, image)
    local newObj = {
        x = x,
        y = y,
        image = image,
        buttons = {}
    }
    setmetatable(newObj, self)
    self.__index = self
    return newObj
end

function Frame:addButton(button)
    table.insert(self.buttons, button)
end

function Frame:removeButton(button)
    for i, b in ipairs(self.buttons) do
        if b == button then
            table.remove(self.buttons, i)
            break
        end
    end
end

function Frame:draw()
    Hyperspace.Resources.RenderImageString(self.image, self.x, self.y, 0, {r=1, g=1, b=1, a=1}, 1, false)
    for i, button in ipairs(self.buttons) do
        button:draw()
    end
end

-- Create the frame
local frameX = 20
local frameY = 20
local frameImage = "frame.png"
local frame = Frame:new(frameX, frameY, frameImage)

-- Create weapon buttons
for i, weapon in ipairs(WEAPONS) do
    local buttonX = frameX + 10 -- Adjust these values as needed
    local buttonY = frameY + 30 * i -- Adjust these values as needed
    local buttonWidth = 100 -- Adjust these values as needed
    local buttonHeight = 25 -- Adjust these values as needed
    local weaponButton = Button:new("weapon.png", "weapon_hover.png", buttonX, buttonY, buttonWidth, buttonHeight)
    weaponButton:setFunction(function()
        -- Handle weapon selection here
        print("Selected weapon: " .. weapon)
        -- You can open the next set of buttons for modules here
    end)
    frame:addButton(weaponButton)
end

-- Render function
script.on_internal_event(Defines.RenderEvents.MOUSE_CONTROL, function ()
    frame:draw()
end)
