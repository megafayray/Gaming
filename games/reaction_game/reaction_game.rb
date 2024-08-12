require 'ruby2d' 

set title: "Reaction Game"
set background: "black"

message = Text.new('Click to begin', x: 20, y: 20)
game_started = false
square = nil
start_time = nil
duration = nil

on :mouse_down do |event|
  puts event.x, event.y
  
  if game_started
    if square.contains?(event.x, event.y)
      duration = ((Time.now - start_time)*1000).round
      message = Text.new("You took: #{duration} milliseconds. Click to try again", x: 20, y: 20)
      square.remove
      game_started = false
    end
  else
    message.remove

    square = Square.new(
    x: rand(get(:width)-25), y: rand(get(:height)-25),
    size: 25,
    color: 'random',
    )

    start_time = Time.now
    game_started = true
  end
end

show