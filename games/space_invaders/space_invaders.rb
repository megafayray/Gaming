require 'ruby2d'

WIDTH = 800
HEIGHT = 600
SHIP_COLOR = '#4BE0EF'
SHOT_DELAY = 400

class Enemy
  attr_reader :x, :y

  def initialize(x, y, color)
    @color = color 
    @x = x
    @y = y 
  end
  
  def draw
    Image.new("/home/vboxuser/repos/gameface/games/space_invaders/enemy_#{@color}.png", x: @x, y: @y, width: 45, height: 25)
  end

  def move_right
    @x -= 30
  end

  def move_down
    @y += 30 
    @x += 180
  end
end 

class Shot
  attr_reader :x, :y, :direction

  def initialize(x, y, direction)
    @x = x 
    @y = y 
    @direction = direction
  end

  def draw
    color = @direction == 'up' ? SHIP_COLOR : 'red'
    Line.new(x1: @x, y1: @y, x2: @x, y2: @y - 20, color: color)
  end

  def move
    incrementer = @direction == 'up' ? -7 : 7
    @y += incrementer
  end 
end

class Ship 
  attr_reader :x, :y

  def initialize
    @x = WIDTH/2 - 30 
    @y = HEIGHT - 30
  end 

  def move_left
    @x -= 8 unless @x - 8 <= 0 
  end 

  def move_right
    @x += 8 unless @x + 8 >= WIDTH - 60
  end

  def draw
    Image.new('/home/vboxuser/repos/gameface/games/space_invaders/ship.png', x: @x, y: @y, width: 60, height: 30)
  end
end


set width: WIDTH
set height: HEIGHT
set title: 'space invaders'
set fps_cap: 30

player = Ship.new 
player_shots = []
enemies_shots = []
enemies = []
lives = 3
tick = Time.now.strftime('%s%L')

6.times do |i|
  if i == 0 || i == 1
    color = 'yellow'
  elsif i == 2 || i == 3
    color = 'green'
  else 
    color = 'red'
  end

  8.times do |n| 
    x = (180 + 75 * n)
    y = (30 + 45 * i) 
    enemies << Enemy.new(x,y, color)
  end
end 

update do 
  clear 
  player.draw
  enemies.each(&:draw)

  Text.new(lives, x: 10, y: 0, size: 30, color: 'white')

  if lives == 0 
    Text.new('GAME OVER', x: WIDTH/2 - 150, y: HEIGHT/2, size: 50, color: 'red')
    next
  end 

  if enemies.empty?
    Text.new('YOU WON!', x: WIDTH/2 - 150, y: HEIGHT/2, size: 50, color: 'green')
    next
  end

  if enemies.any? {|enemy| enemy.y >= player.y - 30 }
    lives = 0
  end

  if Window.frames % 30 == 0 
    enemies.each(&:move_right)
  end

  if Window.frames % rand(30..45) == 0 
    enemy = enemies.sample 
    x,y = enemy.x, enemy.y 
    enemies_shots << Shot.new(x + 23, y, 'down')
  end 

  if Window.frames % 180 == 0 
    enemies.each(&:move_down)
  end

  enemies_shots.each_with_index do |shot, index|
    shot.draw
    shot.move

    if (player.x..player.x+60).include?(shot.x) && (player.y..player.y+30).include?(shot.y)
      lives -= 1
      enemies_shots.reject!.with_index{|_, i| i == index }
    end

    enemies_shots.reject!.with_index{|_, i| i == index } unless (0...HEIGHT).include? shot.y 
  end

  player_shots.each_with_index do |shot, index|
    shot.draw
    shot.move

    #remove enemy from array if player shoots reach it 
    enemies.each_with_index do |enemy, enemy_index|
      if (enemy.x..enemy.x+45).include?(shot.x) && (enemy.y..enemy.y+25).include?(shot.y-20)
        enemies = enemies.reject.with_index{|_, i| i == enemy_index }
        player_shots.reject!.with_index{|_, i| i == index }
        break
      end
    end
    #remove shot from array if it reaches max height
    player_shots.reject!.with_index{|_, i| i == index } unless (0...HEIGHT).include? shot.y 
  end
end  

on :key_held do |event|
  unless lives == 0 || enemies.empty?
    if event.key == 'left'
      player.move_left
    elsif event.key == 'right'
      player.move_right
    end 
  end 
end

on :key_down do |event| 
  unless lives == 0 || enemies.empty?
    if event.key == 'space' && tick.to_i + SHOT_DELAY <= Time.now.strftime('%s%L').to_i
      tick = Time.now.strftime('%s%L')
      player_shots << Shot.new(player.x + 30, player.y, 'up')
    end 
  end
end 

show 
