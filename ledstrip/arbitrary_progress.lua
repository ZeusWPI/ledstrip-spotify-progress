BORDER_THICKNESS = 2
BORDER_COLOR = {0xFF, 0xFF, 0xFF}
BAR_COLOR = {0x00, 0xFF, 0x00}
MAILBOX_TOPIC = "spotify_progress"

function SetSlice(startIndex, endIndex, color)
    led.setSlice(
        startIndex,
        endIndex,
        color[1],
        color[2],
        color[3]
    )
end

function Erase()
    SetSlice(BORDER_THICKNESS, led.count - BORDER_THICKNESS, {0, 0, 0})
end

function DrawProgress(progress)
    -- draw border
    SetSlice(0, BORDER_THICKNESS, BORDER_COLOR)
    SetSlice(led.count - BORDER_THICKNESS, led.count, BORDER_COLOR)

    -- draw progress
    local length = led.count - 2 * BORDER_THICKNESS
    local ledsToDraw = math.ceil(length * progress)
    
    SetSlice(BORDER_THICKNESS, BORDER_THICKNESS + ledsToDraw, BAR_COLOR)
end

function Main()
    mailbox.subscribe(MAILBOX_TOPIC)
    
    Erase()
    DrawProgress(0)

    local progress = 0
    while true do
        --[[
        progress = progress + .001
        DrawProgress(progress)

        if progress >= 1 then
            progress = 0
            Erase()
        end

        time.sleepMsecs(100)
        ]]--

        local progress = mailbox.consume(MAILBOX_TOPIC)

        if tonumber(progress) ~= nil then
            Erase()
            DrawProgress(tonumber(progress))
        end
        time.sleepMsecs(100)
    end
end

Main()

