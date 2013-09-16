#!/usr/bin/env ruby
#Undo by implementing another stack that holds all commands run
require 'curses'
class Stack
	@head = nil
	def initialize
	end
	def push(value)
		newHead = Element.new(value)
		newHead.next = @head
		@head = newHead
	end
	def queuepush(value)
		if @head == nil
			push(value)
		else
			itt = itter
			current = nil
			while itt.done? == false
				current = itt.node
				itt.next
			end
			newHead = Element.new(value)
                	newHead.next = nil
			current.next = newHead
		end
	end
	def queuepop
		if @head == nil
                        
                else
                        itt = itter
                        current = nil
			previous = nil
                        while itt.done? == false
				previous = current
                                current = itt.node
				itt.next
                        end
                        previous.next = nil
                end	
	end
	def pop
		curr = @head
		if curr.nil?
			return nil
		else
			@head = @head.next
			return curr.value
		end
	end
	def to_s
		current = @head
		returnStr = ""
		while current != nil
			returnStr += current.value.to_s + "\n"
			current = current.next
		end
		return returnStr
	end
	def clear
		@head = nil
	end
	def itter
		return StackItter.new(@head)
	end
end

class StackItter
	@current = nil
	def initialize(head)
		@current = head
	end
	def next
		@current = @current.next
	end
	def nextdone?
		if @current == nil
			
		else
			return @current.next == nil
		end
	end
	def value
		return @current.value
	end
	def node
		return @current
	end
	def done?
		if @current == nil
			return true
		else
			return false
		end
	end
end

class Element
	@next = nil
	@value = nil
	def initialize(value)
		@value = value
	end
	def next=(nextval)
		@next = nextval
	end
	def next
		return @next
	end
	def value
		return @value
	end
end

class Game
	@s = nil
	@u = nil
	@r = 6
	def initialize()
		@s = Stack.new 
		@r = 6
		@u = Stack.new
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
		
			#pick a line for the stack to start at
		stackStart = (lines * (3.0/4.0)).to_i
		Curses.setpos(stackStart,0)
		for col in 0..cols-1
			Curses.addch("-")
		end
		for row in 0..stackStart-1
			write(row,cols/2,"|")
		end
		#draw area for stack
		
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
				write(line,(cols/2+1),"...")
				break
			end
			write(line,(cols/2+1),itter.value.to_s)
			line -= 1
			itter.next
		end
		#write stack
		
		Curses.setpos(lines,0)
	end
	def is_a_number?(s)
		s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end
	def rule(&block)
		stuff = []
		for x in 0..(block.arity-1)
			new = @s.pop
			if(new.nil?)
				stuff.each do |a|
					@s.push(a)
				end
				raise "Stack Empty"
			end
			stuff.push(new)
		end
		if(stuff.length == 1)
			ret = yield(stuff[0])
		else
			ret = yield(stuff)
		end
		p ret
		if !(ret.nil?)
			@s.push(ret.round(@r))
		end
	end
	def parse(string)
		sections = string.split(" ")
		i = 0
		nopush = false
		begin
		for part in sections
			i += 1
			case part
			when "+"
				rule {|a,b| b + a}
			when "-"
				rule {|a,b| b - a}
			when "*"
				rule {|a,b| b * a}
			when "/"
				rule {|a,b| b / a}
			when "q"
				exit
			when "^"
				rule {|a,b| b ** a}
			when "s"
				a = @s.pop
				if a.nil?
					raise "Stack Empty"
				end
                                b = @s.pop
				if b.nil?
					@s.push(a)
					raise "Stack Empty"
				end
				@s.push(a)
				@s.push(b)	
			when "d"
				a = @s.pop
				if a.nil?
					raise "Stack Empty"
				end
				2.times do  @s.push(a) end
			when "c"
				@s.pop
			when "cc"
				@s.clear
			when "sqrt"
				rule {|a| Math.sqrt(a) }
			when "sin"
				rule {|a| Math.sin(a) }
			when "sind"
				rule {|a| Math.sin((a/180)*Math::PI) }
			when "cos"
				rule {|a| Math.cos(a) }
			when "cosd"
				rule {|a| Math.cos((a/180)*Math::PI) }
			when "tan"
				rule {|a| Math.tan(a) }
			when "tand"
				rule {|a| Math.tan((a/180)*Math::PI) }
			when "atan"
				rule {|a| Math.atan(a) }
			when "atand"
				rule {|a| (Math.atan(a) * 180) / Math::PI }
			when "asin"
				rule {|a| Math.asin(a) }
			when "asind"
				rule {|a| (Math.asin(a) * 180) / Math::PI }
				
			when "acos"
				rule {|a| Math.acos(a) }
			when "r"
				@r = @s.pop
			when "ckck"
				nopush = true
				@s.clear
				@u.clear
			when "u"
				nopush = true
				@u.queuepop
				@s.clear
				itter = @u.itter
				@u.clear
				while !(itter.done?)
					parse(itter.value)
					itter.next
				end
			else#numeral
				#push op
				if is_a_number?(part)
					@s.push(part.to_f.round(@r))
				else
					raise "Not a number~"
				end
			end
			if(nopush)
				nopush = false	
			else
				@u.queuepush(part)
			end
		end
		rescue RuntimeError => e
			@u.pop
			x = 0
			for y in 0...i
				x += sections[y].length + 1
			end
			message =  string + "\n"
			(x - 2).times { message += " " } 
			message +=  "^" + "\n" + e.message 
			raise message
		end

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
