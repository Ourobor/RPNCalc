#!/usr/bin/env ruby
require 'curses'
require './stack'
require './parse'
class Game
	@s = nil
	@u = nil
	@o = nil
	def initialize()
		@s = Stack.new 
		@u = Stack.new
		@o = Hash.new
		@o["hello"] = "123"
		StringParse.setS(@s)
		StringParse.setU(@u)
		StringParse.setO(@o)
	end
	def init_screen
		Curses.noecho # do not show typed keys
		Curses.init_screen
		Curses.stdscr.keypad(true) # enable arrow keys
		begin
			yield
		ensure
			Curses.close_screen
		end
	end
	def write(line, column, text)
		Curses.setpos(line, column)
		Curses.addstr(text);
		Curses.setpos(line, column)
	end
	def drawScreen()
		cols = Curses.cols
		lines = Curses.lines
		#get width and height of terminal
		
		stackStart = (lines * (3.0/4.0)).to_i #pick a line for the stack to start at
		
		#draw area for stack
		Curses.setpos(stackStart,0)
		for col in 0..cols-1
			Curses.addch("-")
		end
		for row in 0..stackStart-1
			write(row,cols/3,"|")
			write(row,cols/3*2,"|")
		end
		
		#draw stacks on screen
		itter = @s.itter
		line = stackStart - 1
		while itter.done? == false
			write(line,0,itter.value.to_s)
			line -= 1
			itter.next
		end
		line = stackStart - 1
		itter = @u.itter
		while itter.done? == false
			if(line == 0)
				#it seems perfectly likely that the undo stack
				#will overflow the screen in normal operation
				#so if it does, we just write "..." on the 0th
				#line and call it a day
				write(line,(cols/3+1),"...")
				break
			end
			write(line,(cols/3+1),itter.value.to_s)
			line -= 1
			itter.next
		end
		@o.each do |key,value|
			line = stackStart -1
			write(line,cols/3*2+1,key + " => " + value.to_s)
		end
		
		Curses.setpos(lines,0)
	end
	def parse(string)
		StringParse.parse(string)
	end
	def main()
		init_screen do
		loop do
			drawScreen
			Curses.setpos((Curses.lines  * (3.0/4.0)).to_i + 1, 0)	
			Curses.echo
                        string = Curses.getstr()
			Curses.noecho
			Curses.clear
			begin
                        	parse(string)
			rescue RuntimeError => e
				write((Curses.lines  * (3.0/4.0)).to_i + 2, 0, e.message)
			end
		end
		end
	end
end

g = Game.new()
g.main
