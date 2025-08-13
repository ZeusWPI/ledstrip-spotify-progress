BORDER_THICKNESS = 2
BORDER_COLOR = {0xFF, 0xFF, 0xFF}
BAR_COLOR = {0x00, 0xFF, 0x00}
MAILBOX_TOPIC = "spotify_progress"

Length = led.count - 2 * BORDER_THICKNESS

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

function DrawBorder()
    SetSlice(0, BORDER_THICKNESS, BORDER_COLOR)
    SetSlice(led.count - BORDER_THICKNESS, led.count, BORDER_COLOR)

end

function DrawProgress(progress)
    DrawBorder()

    -- draw progress
    local ledsToDraw = Length * progress
    -- clamp ledsToDraw between 0 and max value
    ledsToDraw = math.min(
        ledsToDraw,
        Length
    )
    ledsToDraw = math.max(
        ledsToDraw,
        0
    )
    
    SetSlice(BORDER_THICKNESS, BORDER_THICKNESS + ledsToDraw, BAR_COLOR)
end


function CountUp(seconds)
    local SLEEP_MS = 100
    local step = 1 * (SLEEP_MS / 1000) / seconds
    local progress = 0
    local msg = mailbox.consume(MAILBOX_TOPIC)
    while msg ~= "stop" do
        progress = progress + step
        msg = mailbox.consume(MAILBOX_TOPIC)
        DrawProgress(progress)
        time.sleepMsecs(SLEEP_MS)
    end
    Erase()
end

function Main()
    mailbox.subscribe(MAILBOX_TOPIC)
    
    Erase()
    DrawProgress(0)

    while true do
        local seconds = mailbox.consume(MAILBOX_TOPIC)

        if tonumber(seconds) ~= nil then
            Erase()
            CountUp(tonumber(seconds))
        end
        time.sleepMsecs(100)
    end
end

Main()

