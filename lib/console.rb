# This is a quake-like console that handles commands,
# and includes tab completion
# 
# Author::    Steven Davidovitz (mailto:steviedizzle@gmail.com)
# Copyright:: Copyright (c) 2006, The Nebular Gauntlet DEV team
# License::   GPL
#

require 'command.rb'
require 'input.rb'
require 'keyboard.rb'

class String
  def starts_with? str
    self[0..str.length-1] == str
  end
end

class Console
  include Input
  include Keyboard
  attr_accessor :active

  # Initialize the console, default is inactive
  # - _screen_ Screen surface
  # - _font_ Font to use
  # - _height_ Height from top of window. A multiple of the font's height is recommended.
  # - _alpha_ Alpha (transparency) to set console to
  # - _activation_ Key which activates console default is tilde
  # - _background_ Console background color
  # - _inputchar_ String to signify input line
  def initialize(screen, font, height, alpha = 255, activation = 96, background = [255, 255, 255], inputchar = "[>")
    @screen, @font, @height = screen, font, height
    @background = background
    @alpha = alpha
    @inputchar = inputchar
    @activation = activation

    reset
    @id = 0
    @hpos = -1

    @tab = ""

    @active = false
  end

  # Output string to console
  # - _string_ String to output
  def put(string)
    @id += 1 # Increment the id so that each one is unique

    # Put string, @id in both console archive and the console view
    @console_archive << [string, @id]
    @console_view << [string, @id]
    room = ((@height - (@height % @font.height)) / @font.height) - 1
    while @console_view.length > room
      @console_view.shift
    end

    scroll_down
  end

  # Parses text and executes command if found
  # - _text_ Text to parse
  def execute_string(text)
    if text.include?(" ")
      index = text.index(" ")

      if index > 0
        @name = text.split(" ")[0]
        @args = text.split(" ")[1..text.length] # In case of more than one arg
      end	
    else
      # No arguments, so only command
      @name = text
      @args = nil
    end

    # Delete the last executed command so that only the result shows
    @console_view.delete_at(-1) 
    @console_archive.delete_at(-1)

    begin
        self.__send__(@name, @args)
    rescue
      begin
        self.__send__(@name, "usage")
      rescue
        put("unknown command: #{@name}")
      end
    end

    # Reset buffer and cursorPos
    @buffer = "" 
    @cursor_pos = 0
  end

  def reset
    @buffer = ""
    @cursor_pos = 0
    @console_view = []
    @console_archive = []
    @command_archive = []
  end

  def method_missing(meth, *args)
    put("unknown command: #{@name}")
  end

  # Find all user-executable commands
  def find_commands
    Console.protected_instance_methods(false)
  end

  # Tab complete string from buffer
  def tab_complete
    cmds = find_commands.sort

    e = cmds.find {|i| i.starts_with?(@buffer)}

    if !e.nil?
      @buffer = e
      cursor_end
    end
  end

  # What to do on keypress
  # - _key_ Key which is pressed
  def keypress?(key)	
    if key.sym != @activation
      case key.sym
      when SDL::Key::RETURN
        if @buffer != ""
          @command_archive << @buffer
          put(@buffer)
          execute_string(@buffer)
        end
      when SDL::Key::SPACE
        insert(" ")
      when SDL::Key::BACKSPACE
        @buffer.slice!(@cursor_pos - 1..@cursor_pos - 1) unless @cursor_pos == 0
        cursor_left
      when SDL::Key::DELETE
        @buffer.slice!(@cursor_pos..@cursor_pos)
      when SDL::Key::PAGEUP
        scroll_up
      when SDL::Key::PAGEDOWN
        scroll_down
      when SDL::Key::UP
        history_up
      when SDL::Key::DOWN
        history_down
      when SDL::Key::LEFT
        cursor_left
      when SDL::Key::RIGHT
        cursor_right
      when SDL::Key::ESCAPE
        @active = !@active
      when SDL::Key::TAB
        tab_complete
      else
        display_key(key.sym, key.mod)
      end if @active
    else
      @active = !@active
    end
  end


  # Render console
  def draw
    return if !@active

    x = @font.textSize(@inputchar)[0] # Can be any key or number, just for a test
    y = @height - (@font.height * 2)

    @screen.drawFilledRectAlpha(0, 0, @screen.w, @height, @background, @alpha) # Draw white console with space for 5 lines

    @font.drawBlendedUTF8(@screen, @inputchar, 0, @height - @font.height, 0, 0, 0) # Draw input symbol 

    @font.drawBlendedUTF8(@screen, @buffer, x, @height - @font.height, 0, 0, 0) # Draw buffer

    @screen.drawLine(x + (@cursor_pos * @font.textSize("a")[0]), @height - @font.height, x + (@cursor_pos * @font.textSize("a")[0]), @height, [0, 0, 0])

    @console_view.reverse_each do |message| # Draw each message that is in view
      @font.drawBlendedUTF8(@screen, message[0], 0, y, 0, 0, 0)
      y -= @font.height
    end
  end
end
