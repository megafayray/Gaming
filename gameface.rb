require 'ruby2d'

set title: "Game Selector"
set background: "white"

# Create the text
text = Text.new(
  'Choose your game!',
  x: 0, y: 0,
  size: 40,
  color: 'purple',
)

# Center the text horizontally and vertically
text_x = (Window.width - text.width) / 2
text_y = (Window.height - text.height) / 2

# Set the text position
text.x = text_x
text.y = text_y

# Create images
image_size = 150
spacing = 50  # Space between images
total_width = 3 * image_size + 2 * spacing

# Calculate starting position for the images to be centered
start_x = (Window.width - total_width) / 2

# Load and position images above the text
@image1 = Image.new('images/flappy_bird.png', x: start_x, y: text.y - image_size - spacing, width: image_size, height: image_size)
@image2 = Image.new('images/reaction_game.png', x: start_x + image_size + spacing, y: text.y - image_size - spacing, width: image_size, height: image_size)
@image3 = Image.new('images/snake.png', x: start_x + 2 * (image_size + spacing), y: text.y - image_size - spacing, width: image_size, height: image_size)

# Load and position images below the text
@image4 = Image.new('images/minesweeper.png', x: start_x, y: text.y + 50 + spacing, width: image_size, height: image_size)
@image5 = Image.new('images/pong.png', x: start_x + image_size + spacing, y: text.y + 50 + spacing, width: image_size, height: image_size)
@image6 = Image.new('images/space_invaders.png', x: start_x + 2 * (image_size + spacing), y: text.y + 50 + spacing, width: image_size, height: image_size)

# Function to check if a click is within an image's bounds
def image_clicked?(image, x, y)
  x > image.x && x < image.x + image.width &&
  y > image.y && y < image.y + image.height
end

# Handle mouse click events
on :mouse_down do |event|
  x, y = event.x, event.y
  
  if image_clicked?(@image1, x, y)
    puts "Play Flappy Bird!"
    system("ruby /home/kids/repos/Gaming/games/flappy_bird/main.rb") #this doesn't work...yet!
  elsif image_clicked?(@image2, x, y)
    puts "Play Reaction Game!"
    system("ruby games/reaction_game/reaction_game.rb")
  elsif image_clicked?(@image3, x, y)
    puts "Play Snake Game!"
    system("ruby games/newsnake/snake.rb")
  elsif image_clicked?(@image4, x, y)
    puts "Play Minesweeper!"
    system("ruby games/minesweeper/minesweeper.rb")
  elsif image_clicked?(@image5, x, y)
    puts "Play Pong!"
    system("ruby games/pong/pong.rb")
  elsif image_clicked?(@image6, x, y)
    puts "Play Space Invaders!"
    system("ruby games/space_invaders/space_invaders.rb") 
  end

end
show