module Commands
require './stack'
class CommandBuilder
	@@r = 6
	@rules = nil
	@args = nil
	@objtable = nil
	def initialize
		@rules = Hash.new
		@args = Hash.new
		@objtable = Hash.new
		@@r = 6
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
		addRule("r", lambda {|a| @@r = a[0].to_f; return []}, 1)
		addRule("ckck", lambda {|a| Stack.S.clear; Stack.U.clear; return [] }, 0)
		addRule("u", lambda {|a| Stack.U.pop; Stack.U.pop.undo; return []}, 0)
		addRule("clrt", lambda {|a| Stack.U.pop; @objtable = Hash.new}, 0)
		#If a single person reads this code and wants to add more rules to it or
		#something, it's fairly straightforward
		#addRule adds a rule to be parsed
		#The first arg is the name of the command, which is what will be looked for
		#by the code when you want to execute it
		#The second arg is a lambda function(or proc(Maybe block? IDK)) that is given
		#an array of arguments and expected to return an array of things that should
		#be pushed to the stack
		#The third argument is how many arguments are needed for the lambda to work
		#these are poped off of the stack
	end
	def addRule(name,code,args)
		@rules[name] = code
		@args[name] = args
	end
	def is_a_number?(s)
		s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end
	def self.round(num)
		return num.to_f.round(@@r)
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
				num = Command.new(lambda { }, [], CommandBuilder.round(part))
				num.isanum
				Stack.U.push(num)
				Stack.S.push(CommandBuilder.round(part))
			elsif(part == ">>")
				var = sections[itter.next]
				if @rules.has_key?(var)
					raise("Can't name a variable the same name as a rule!")
				end
				@objtable[var] = Stack.S.top
			elsif(@objtable.has_key?(part))
				num = Command.new(lambda { }, [], CommandBuilder.round(@objtable[part]))
				num.isanum
				Stack.U.push(num)
				Stack.S.push(CommandBuilder.round(@objtable[part]))

			else
				#bail
				raise("Invalid command")
			end
		end
		rescue StopIteration
			#iterators only throw an exception when they're done
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
#CB = CommandBuilder.new
class Command
	@exec = nil #Lambda that determines what values to push to the stack
	@args = nil #list of arguments that the lambda needs to function, popped
			#from the stack
	@name = nil #The name of the command, used for to_s stuff so the user can
			#see what the command's name is on the command stack
	@numberOfConsequences = nil #The number of things the command pushed

	def initialize(lamb,args,name)
		@exec = lamb
		@args = args
		@name = name
		@numberOfConsequences = 0
	end
	def isanum #some commands are actually numbers, they have no arguments
			#but have a single consequence(The number pushed to the stack)
		@numberOfConsequences = 1
	end
	def do#execute the command
		topush = @exec.call(@args)
		for item in topush
			Stack.S.push(CommandBuilder.round(item))
			@numberOfConsequences += 1
		end
	end
	def undo#undo the command
		for x in 0...@numberOfConsequences
			Stack.S.pop#Take the number of things off the stack that we put on
		end
		for y in @args.reverse#put the things we took off the stack back on
			Stack.S.push(CommandBuilder.round(y))
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
end
