#!/usr/bin/env ruby
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
	def queuepush(value)#Should really rewrite this >.>
		#push element onto the bottom of the stack
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
	def queuepop #should really rewrite this >.>
		#pop element from the bottom of the stack
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
	#queuepush and queuepop both start to act horribly as the stack gets bigger and bigger
	#and since queuepush is used every time anything is entered, the program will get slower
	#and slower as the undo stack gets larger and larger

	def pop
		curr = @head
		if curr.nil?
			return nil
		else
			@head = @head.next
			return curr.value
		end
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
		
		stackStart = (lines * (3.0/4.0)).to_i #pick a line for the stack to start at
		
		#draw area for stack
		Curses.setpos(stackStart,0)
		for col in 0..cols-1
			Curses.addch("-")
		end
		for row in 0..stackStart-1
			write(row,cols/2,"|")
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
				write(line,(cols/2+1),"...")
				break
			end
			write(line,(cols/2+1),itter.value.to_s)
			line -= 1
			itter.next
		end
		
		Curses.setpos(lines,0)
	end
	def is_a_number?(s)
		s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end

	def rule(&block)
	#this function is designed to simplify doing any math operation
	#by getting the needed number of things off of the stack and 
	#pushing the result back on the stack
	#ex rule {|a,b| b + a }
	#would result in two numbers being popped off of the stack and passed
	#into the block. The result of the block is returned, captured and
	# pushed onto the stack
		stuff = []
		for x in 0..(block.arity-1)
			new = @s.pop
			if(new.nil?)
				#if we run out of stuff on the stack to pop off
				#and the rule still needs more, we should push
				#everything back on the stack and bail out
				stuff.each do |a|
					@s.push(a)
				end
				raise "Stack Empty"
			end
			stuff.push(new)
		end
		#I'm not entirely sure as to why this works the way it does,
		#but apparently if you pass an array to a yield, it passes
		#each element individually? I guess? However if you pass
		#an array with only one element it passes an array? IDK
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
			when "+"#Add two things
				rule {|a,b| b + a}
			when "-"#Subtract two things
				rule {|a,b| b - a}
			when "*"#multiply two things
				rule {|a,b| b * a}
			when "/"#divide two things
				rule {|a,b| b / a}
			when "q"#quit the program
				exit
			when "^"#exponentiate (raise b to the a power)
				rule {|a,b| b ** a}
			when "s"#swap the two top elements on the stack
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
			when "d"#duplicate the top element
				a = @s.pop
				if a.nil?
					raise "Stack Empty"
				end
				2.times do  @s.push(a) end
			when "c"#delete the top element
				@s.pop
			when "cc"#clear the stack
				@s.clear
			when "sqrt"#take the square root of the top element
				rule {|a| Math.sqrt(a) }
			when "sin"#take the sine of the top element(assuming radians)
				rule {|a| Math.sin(a) }
			when "sind"#sin in degrees
				rule {|a| Math.sin((a/180)*Math::PI) }
			when "cos"#cos in radians
				rule {|a| Math.cos(a) }
			when "cosd"#cos in degrees
				rule {|a| Math.cos((a/180)*Math::PI) }
			when "tan"#tan in radians
				rule {|a| Math.tan(a) }
			when "tand"#tan in degrees
				rule {|a| Math.tan((a/180)*Math::PI) }
			when "atan"#the arctangent in radians
				rule {|a| Math.atan(a) }
			when "atand"#the arctangent in degrees
				rule {|a| (Math.atan(a) * 180) / Math::PI }
			when "asin"#arcsine in radians
				rule {|a| Math.asin(a) }
			when "asind"#arcsine in degrees
				rule {|a| (Math.asin(a) * 180) / Math::PI }
			when "acos"#arccosine in radians
				rule {|a| Math.acos(a) }
			when "r"#set precision
				@r = @s.pop
			when "ckck"#clear everything, including undo stack
				nopush = true
				@s.clear
				@u.clear
			when "u"#undo last operation
				nopush = true
				@u.queuepop
				@s.clear
				itter = @u.itter
				@u.clear
				while !(itter.done?)
					parse(itter.value)
					itter.next
				end
			else#push something onto the stack
				if is_a_number?(part)
					@s.push(part.to_f.round(@r))
				else
					raise "Not a number~"
				end
			end
			if(nopush)#some operations shouldn't push to the undo
				#stack, this flag prevents them from being pushed
				nopush = false	
			else
				@u.queuepush(part)
			end
		end
		rescue RuntimeError => e#this bit handles an exceptions that parse
		#raised and points an arrow at the term in the given string that
		#caused the issue
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
