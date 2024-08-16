require 'ruby2d'

WIDTH = 800
HEIGHT = 600
BACKGROUND_COLOR = '#000000'
BASE_COLOR = '#FFFFFF'

set background: BACKGROUND_COLOR
set width: WIDTH, height: HEIGHT
set title: 'pong'
@game_finished = false

def draw_dotted_line
  (0..HEIGHT).step(25) do |i|
    Line.new(x1: WIDTH/2 , x2: WIDTH/2 , y1: i , y2: i + 10, width: 3 , color: BASE_COLOR)
  end 
end 

def draw_players_score(player_score, opponent_score)
  Text.new(player_score, x: (WIDTH / 2 ) - (WIDTH / 4 ), y: 30, style: 'bold', size: 80, color: BASE_COLOR )
  Text.new(opponent_score, x: (WIDTH / 2 ) + (WIDTH / 4 ), y: 30, style: 'bold', size: 80, color: BASE_COLOR )
end 

class Paddle
  attr_accessor :score, :shape

  def initialize(direction)
    @x = direction == 'left' ? 30 : WIDTH - 30
    @y = HEIGHT / 2
    @score = 0
  end 

  def draw
    @shape = Rectangle.new(x: @x, y: @y, width: 7, height: 60, color: BASE_COLOR)
  end 

  def move_up
    @y = (@y - 10).clamp(0, HEIGHT * 0.93)
  end 

  def move_down
    @y = (@y + 10).clamp(0, HEIGHT * 0.93)
  end 

  def track_ball(ball_y, last_hit_frame)
    return unless last_hit_frame + 30 <= Window.frames

    if ball_y <= @y
      move_up
    elsif ball_y >= @y  
      move_down
    end 
  end 
end

class Ball
  attr_reader :x, :y

  def initialize
    @x = WIDTH / 2
    @y = HEIGHT  / 2
    @x_direction = -1
    @y_direction = -1
  end 

  def draw
    @shape = Circle.new(x: @x, y: @y, radius: 5, color: BASE_COLOR)
  end 

  def move
    hit_top_or_bottom?

    @x += (5 * @x_direction)
    @y += (2 * @y_direction)
  end

  def hit_paddle?(player, opponent)
    if player.shape.contains?(@x, @y) || opponent.shape.contains?(@x, @y)
      @x_direction *= -1
      return true
    end 
  end 

  def over_map?
    @x >= WIDTH || @x <= 0 
  end 

  def reset_position
    @x = WIDTH / 2
    @y = HEIGHT  / 2
    @x_direction = rand < 0.3 ? 1 : -1  
  end 

  private
  def hit_top_or_bottom?
    if @y >= HEIGHT || @y <= 0 
      @y_direction *= -1
    end 
  end 
end 

player   = Paddle.new('left')
opponent = Paddle.new('right')
ball     = Ball.new
last_hit_frame = 0
 
update do
  clear

  draw_dotted_line
  draw_players_score(player.score, opponent.score)

  player.draw
  opponent.draw
  ball.draw
  ball.move

  opponent.track_ball(ball.y, last_hit_frame)

  if ball.hit_paddle?(player, opponent)
    last_hit_frame = Window.frames
  end

  if ball.over_map?
    if ball.x == 0
      opponent.score += 1
    elsif ball.x == WIDTH
      player.score += 1
    end 

    if player.score == 10
      Text.new('YOU WON!', x: WIDTH/4, y: HEIGHT/3, size: 75, color: 'white')
      Text.new('Press "R" to restart')
      @game_finished = true
      next
    elsif opponent.score == 10
      Text.new('GAMEOVER', x: WIDTH/4, y: HEIGHT/3, size: 75, color: 'white')
      Text.new('Press "R" to restart')
      @game_finished = true
      next
    end

    ball.reset_position
  end 
end 

on :key_held do |event|
  if event.key == 'up'
    player.move_up
  elsif event.key == 'down'
    player.move_down
  end

  if @game_finished && event.key == 'r'
    @game_finished = false
    player_score = "0"
    opponent_score = "0"
    player.score = 0
    opponent.score = 0
    draw_players_score(0,0)
    ball.reset_position
  end

end

show