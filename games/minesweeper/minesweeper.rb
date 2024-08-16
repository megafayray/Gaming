require 'ruby2d'

GRID = 50
WIDTH = 800
HEIGHT = 600
BACKGROUND_COLOR = '#ffffff'
HIDDEN_BLOCK_COLOR = '#0058D4'
REVEALED_BLOCK_COLOR = '#2ECC40'
DIFFICULTY_LEVEL = 0.1

class Board
  attr_accessor :blocks, :game_over, :won

  def initialize
    reset_game
  end 

  def draw
    @blocks.each_with_index do |_, x|
      @blocks[x].each_with_index do |_, y|
        block = @blocks[x][y]

        begin
          if block[:revealed] && !block[:mine]
            Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: REVEALED_BLOCK_COLOR)
            Text.new(block[:mines_nearby], x: x * GRID +  (GRID / 3), y: y * GRID + (GRID / 3), size: GRID * 0.55, color: 'black') if block[:mines_nearby] > 0
          elsif block[:revealed] && block[:mine]
            Image.new('/home/kids/repos/Gaming/games/minesweeper/boom.png', x: x * GRID, y: y * GRID)
            Text.new('GAME OVER', x: WIDTH / 2 - 150, y: HEIGHT / 2, z: 2, size: 50, color: 'red')
            Text.new('Press "R" to restart', x: WIDTH / 2 - 150, y: HEIGHT / 2 + 60, size: 30, color: 'white')
          elsif !block[:revealed] && block[:flagged]
            Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: HIDDEN_BLOCK_COLOR)
            Image.new('/home/kids/repos/Gaming/games/minesweeper/flag.png', x: x * GRID, y: y * GRID)
          else
            Square.new(x: x * GRID, y: y * GRID, size: GRID - 1, color: HIDDEN_BLOCK_COLOR)
          end 

          if @won 
            Text.new('You won', x: WIDTH / 4, y: HEIGHT / 3, size: 75, color: 'white', rotate: 45)
            Text.new('Press "R" to restart', x: WIDTH / 2 - 150, y: HEIGHT / 2 + 60, size: 30, color: 'white')
          end 
        rescue => detail
          p detail
        end 
      end 
    end 
  end

  def reveal_block(x, y)
    return if @game_over || @blocks[x][y][:revealed]
    
    @blocks[x][y][:revealed] = true
    @blocks[x][y][:flagged] = false
    
    if @blocks[x][y][:mine]
      reveal_all_mines 
      @game_over = true
    end
    reveal_blocks_with_zero_bombs(x, y) if @blocks[x][y][:mines_nearby] == 0
  end

  def flag_block(x, y)
    return if @game_over || @blocks[x][y][:revealed]
    @blocks[x][y][:flagged] = !@blocks[x][y][:flagged]
    
    if all_mines_flagged?
      @game_over = true
      @won = true
    end 
  end

  def reset_game
    @blocks = []
    @cols = (WIDTH / GRID).floor
    @rows = (HEIGHT / GRID).floor
    @game_over = false
    @won = false
    generate_blocks
    plant_mines
    mined_neighbours
  end

  private

  def generate_blocks
    @cols.times do |x|
      @blocks << []
      @rows.times do |y|
        block = {
          revealed: false,
          mine: false,
          flagged: false,
          mines_nearby: 0
        }
        @blocks[x][y] = block
      end
    end
  end 

  def plant_mines
    mines_to_plant = (@cols * @rows * DIFFICULTY_LEVEL).floor

    while mines_to_plant > 0
      block_to_mine = @blocks.flatten.sample
      unless block_to_mine[:mine]
        block_to_mine[:mine] = true 
        mines_to_plant -= 1
      end
    end
  end

  def mined_neighbours  
    @blocks.each_with_index do |_, x|
      @blocks[x].each_with_index do |_, y|
        block = @blocks[x][y]
        next if block[:mine]
        block[:mines_nearby] = number_of_mines_nearby(x, y)
      end 
    end 
  end

  def number_of_mines_nearby(x, y)
    mines = 0
    (-1..1).each do |i|
      (-1..1).each do |n|
        next if !(0...@cols).include?(x + i) || !(0...@rows).include?(y + n)
        mines += 1 if @blocks[x + i][y + n][:mine]
      end 
    end 
    mines
  end

  def reveal_all_mines
    @blocks.flatten.each { |b| b[:revealed] = true if b[:mine] }
  end

  def reveal_blocks_with_zero_bombs(x, y)
    (-1..1).each do |i|
      (-1..1).each do |n|
        next if !(0...@cols).include?(x + i) || !(0...@rows).include?(y + n) || @blocks[x + i][y + n][:mine] || @blocks[x + i][y + n][:revealed]
        reveal_block(x + i, y + n)
      end 
    end 
  end

  def all_mines_flagged?
    blocks = @blocks.flatten 
    num_mines = blocks.count { |b| b[:mine] }
    num_flags = blocks.count { |b| b[:flagged] }
    flagged_mines = blocks.count { |b| b[:mine] && b[:flagged] }
    
    num_mines == num_flags && num_mines == flagged_mines
  end
end 

set width: WIDTH
set height: HEIGHT
set background: BACKGROUND_COLOR
set title: 'Minesweeper'

board = Board.new

update do
  clear 
  board.draw 
end

on :mouse_down do |event|
  if event.button == :left
    board.reveal_block(event.x / GRID, event.y / GRID)
  elsif event.button == :right
    board.flag_block(event.x / GRID, event.y / GRID)
  end
end

on :key_down do |event| 
  if event.key == 'r'
    board.reset_game
  end
end

show