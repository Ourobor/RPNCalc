module Commands
require './stack'
class CommandBuilder
	@r = 6
	@rules = nil
	@args = nil
	@objtable = nil
	def initialize
		@rules = Hash.new
		@args = Hash.new
		@objtable = Hash.new
		@r = 6
		addRule("+", lambda {|a| return [a[1].to_f + a[0].to_f] }, 2)
		addRule("q", Proc.new { exit }, 0)
		addRule("-", lambda {|a| return [a[1].to_f - a[0].to_f] }, 2)
		addRule("*", lambda {|a| return [a[1].to_f * a[0].to_f] }, 2)
		addRule("/", lambda {|a| return [a[1].to_f / a[0].to_f] }, 2)
		addRule("^", lambda {|a| return [a[1].to_f ** a[0].to_f] } , 2)
		addRule("s", lambda {|a| return [a[0].to_f,a[1].to_f]}, 2)
		addRule("d", lambda {|a| return [a[0].to_f,a[0].to_f]},1)
		addRule("c", lambda {|a| return []}, 1)
		addRule("cc", lambda {|a| Stack.S.clear;return []}, 0)
		addRule("sqrt", lambda {|a| return [Math.sqrt(a[0].to_f)]}, 1)
		addRule("sin", lambda {|a| return [Math.sin(a[0].to_f)]}, 1)
		addRule("sind", lambda {|a| return [Math.sin((a[0].to_f/180)*Math::PI)]}, 1)
		addRule("cos", lambda {|a| return [Math.cos(a[0].to_f)]}, 1)
		addRule("cosd", lambda {|a| return [Math.cos((a[0].to_f/180)*Math::PI)]}, 1)
		addRule("tan", lambda {|a| return [Math.tan(a[0].to_f)]}, 1)
		addRule("tand", lambda {|a| return [Math.tan((a[0].to_f/180)*Math::PI)]}, 1)
		addRule("atan", lambda {|a| return [Math.atan(a[0].to_f)]}, 1)
		addRule("atand", lambda {|a| return [(Math.atan(a[0].to_f) * 180) / Math::PI]}, 1)
		addRule("asin", lambda {|a| return [Math.asin(a[0].to_f)]}, 1)
		addRule("asind", lambda {|a| return [(Math.asin(a[0].to_f) * 180) / Math::PI]}, 1)
		addRule("acos", lambda {|a| return [Math.acos(a[0].to_f)]}, 1)
		addRule("acosd", lambda {|a| return [(Math.acos(a[0].to_f) * 180) / Math::PI]}, 1)
		addRule("r", lambda {|a| @r = a[0].to_f; return []}, 1)
		addRule("ckck", lambda {|a| Stack.S.clear; Stack.U.clear; return [] }, 0)
		addRule("u", lambda {|a| Stack.U.pop; Stack.U.pop.undo; return []}, 0)
	end
	def addRule(name,code,args)
		@rules[name] = code
		@args[name] = args
	end
	def is_a_number?(s)
		s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end
	def parse(string)
		sections = string.split(" ")
		i = 0
		nopush = false
		begin
		itter = (0...sections.length).to_enum


		begin
		while true
 			i = itter.next
			part = sections[i]	
			if(@rules.has_key?(part))
				#parse thing
				cmd = buildCommand(part)
				Stack.U.push(cmd)
				cmd.do
			elsif(is_a_number?(part))
				#push
				num = Command.new(lambda { }, [], part.to_f.round(@r))
				num.isanum
				Stack.U.push(num)
				Stack.S.push(part.to_f.round(@r))
			elsif(part == ">>")
				var = sections[itter.next]
				@objtable[var] = Stack.S.top
			elsif(@objtable.has_key?(part))
				num = Command.new(lambda { }, [], @objtable[part].to_f.round(@r))
				num.isanum
				Stack.U.push(num)
				Stack.S.push(@objtable[part].to_f.round(@r))

			else
				#bail
				raise("Invalid command")
			end
		end
		rescue StopIteration
		
		end


		rescue RuntimeError => e#this bit handles an exceptions that parse
		#raised and points an arrow at the term in the given string that
		#caused the issue
			Stack.U.pop
			x = 0
			for y in 0...i+1
				x += sections[y].length + 1
			end
			message =  string + "\n"
			(x - 2).times { message += " " } 
			message +=  "^" + "\n" + e.message 
			raise message
		end
	end
	def objtable
		return @objtable
	end
	def buildCommand(command)		
		args = []
		for x in 0...@args[command]
			args << Stack.S.pop
		end
		command = Command.new(@rules[command],args,command)	
		return command
	end
end
class Command
	@exec = nil
	@args = nil
	@name = nil

	@numberOfConsequences = nil

	def initialize(lamb,args,name)
		@exec = lamb
		@args = args
		@name = name
		@numberOfConsequences = 0
	end
	def isanum
		@numberOfConsequences = 1
	end
	def do
		topush = @exec.call(@args)
		for item in topush
			Stack.S.push(item)
			@numberOfConsequences += 1
		end
		p topush
	end
	def undo
	#to undo a command, we're gonna need two things
	#crap to push onto the stack => @args
	#a number of things to pop from the stack => @numberOfConsequences
			for x in 0...@numberOfConsequences
				Stack.S.pop#Take the number of things off the stack that we put on
			end
			for y in @args.reverse#put the things we took off the stack back on
				Stack.S.push(y)
			end
	end
	def to_s
		args = ""
		if @args.length > 0
		args << "["
		for item in @args.reverse
			args << item.to_s + ", "
		end
		args = args[0..-3]
		args << "]"
		end
		return  args + ' ' + @name.to_s
	end
	def to_f
		return @name.to_f
	end
end
CB = CommandBuilder.new
end
