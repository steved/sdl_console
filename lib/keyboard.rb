# Module to control keyboard input and control console
# 
#
# Author::    Steven Davidovitz (mailto:steviedizzle@gmail.com)
# Copyright:: Copyright (c) 2006, The Nebular Gauntlet DEV team
# License::   GPL
#

module Keyboard

  # Scrolls input buffer up one command
  def scroll_up
    if @console_view[0][1] != @console_archive[0][1]
      @console_view.insert(0, @console_archive.at(@console_archive.index(@console_view[0]) - 1))
      @console_view.pop
    end
  end

  # Scrolls input buffer down one command
  def scroll_down
    if @console_view[-1][1] != @console_archive[-1][1]
      @console_view.insert(-1, @console_archive.at(@console_archive.index(@console_view[-1]) + 1))
      @console_view.shift
    end
  end

  # Scrolls history up one line
  def history_up
    if @command_archive.length != 0
      @buffer = @command_archive[@hpos]
      @cursor_pos = @buffer.length
      @hpos -= 1 if @hpos.abs < @command_archive.length
    end
  end

  # Scrolls history down one line
  def history_down	
    if @command_archive.length != 0
      if @hpos < -1
        @hpos += 1
        @buffer = @command_archive[@hpos]
        @cursor_pos = @buffer.length
      else
        @buffer = ""
        @cursor_pos = @buffer.length
      end
    end
  end

  # Moves cursor right one character
  def cursor_right
    @cursor_pos += 1 if @cursor_pos < @buffer.length
  end

  # Moves cursor left one character
  def cursor_left
    @cursor_pos -= 1 if @cursor_pos > 0
  end

  # Moves cursor to then end of the buffer
  def cursor_end
    @cursor_pos = @buffer.length
  end

  # Moves cursor to then beginning of the buffer
  def cursor_begin
    @cursor_pos = 0
  end
end
