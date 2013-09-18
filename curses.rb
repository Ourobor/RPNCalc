#!/usr/bin/env ruby
require 'curses'
require './stack'
require './commands'
class Screen
	def initialize()
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
		#get width and height of terminal
		cols = Curses.cols
		lines = Curses.lines
		
		#pick a line for the stack to start at
		stackStart = (lines * (3.0/4.0)).to_i 
		
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
		itter = Stack.S.itter
		line = stackStart - 1
		while itter.done? == false
			write(line,0,itter.value.to_s)
			line -= 1
			itter.next
		end
		line = stackStart - 1
		itter = Stack.U.itter
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
		line = stackStart -1
		Commands::CB.objtable.each do |key,value|
			write(line,cols/3*2+1,key + " => " + value.to_s)
			line -= 1
		end
		
		Curses.setpos(lines,0)
	end
	def parse(string)
		Commands::CB.parse(string)
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
g = Screen.new()
g.main
