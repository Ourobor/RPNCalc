require './commands'
class Parser
	def initialize(database)
		@database = database
		@rules = Hash.new
		@args = Hash.new
		@cBuilder = CommandBuilder.new(database)

		@sections = nil 	#sections of the text the parser is parsing
		@iter = nil		#the iterator the parser is using to itterate though the text

	addRule("+", \
		lambda {|a| return [a[1].to_f + a[0].to_f] }, 2)
	addRule("q", \
		Proc.new { exit }, 0)
	addRule("-", \
		lambda {|a| return [a[1].to_f - a[0].to_f] }, 2)
	addRule("*", \
		 lambda {|a| return [a[1].to_f * a[0].to_f] }, 2)
	addRule("/", \
		lambda {|a| return [a[1].to_f / a[0].to_f] }, 2)
	addRule("^", \
		lambda {|a| return [a[1].to_f ** a[0].to_f] } , 2)
	addRule("s", \
		lambda {|a| return [a[0].to_f,a[1].to_f]}, 2)
	addRule("d", \
		lambda {|a| return [a[0].to_f,a[0].to_f]},1)
	addRule("c", \
		lambda {|a| return []}, 1)
	addRule("cc", \
		lambda {|a| @database.getMain.clear;return []}, 0)
	addRule("sqrt", \
		lambda {|a| return [Math.sqrt(a[0].to_f)]}, 1)
	addRule("sin", \
		lambda {|a| return [Math.sin(a[0].to_f)]}, 1)
	addRule("sind", \
		lambda {|a| return [Math.sin((a[0].to_f/180)*Math::PI)]}, 1)
	addRule("cos", \
		lambda {|a| return [Math.cos(a[0].to_f)]}, 1)
	addRule("cosd", \
		lambda {|a| return [Math.cos((a[0].to_f/180)*Math::PI)]}, 1)
	addRule("tan", \
		lambda {|a| return [Math.tan(a[0].to_f)]}, 1)
	addRule("tand", \
		lambda {|a| return [Math.tan((a[0].to_f/180)*Math::PI)]}, 1)
	addRule("atan", \
		lambda {|a| return [Math.atan(a[0].to_f)]}, 1)
	addRule("atand", \
		lambda {|a| return [(Math.atan(a[0].to_f) * 180) / Math::PI]}, 1)
	addRule("asin", \
		lambda {|a| return [Math.asin(a[0].to_f)]}, 1)
	addRule("asind", \
		lambda {|a| return [(Math.asin(a[0].to_f) * 180) / Math::PI]}, 1)
	addRule("acos", \
		lambda {|a| return [Math.acos(a[0].to_f)]}, 1)
	addRule("acosd", \
		lambda {|a| return [(Math.acos(a[0].to_f) * 180) / Math::PI]}, 1)
	addRule("r", \
		lambda {|a| @database.setRound(a[0].to_f); return []}, 1)
	addRule("ckck", \
		lambda {|a| @database.getMain.clear; @database.getCommand.clear; return [] }, 0)
	addRule("u", \
		lambda {|a| @database.getCommand.pop; @database.getCommand.pop.undo; return []}, 0)
	addRule("clrt", \
		lambda {|a| @database.getCommand.pop; @database.emptyObjtable}, 0)
	#If you read this code and want to add more rules to it or
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

	def parse(string)
		@sections = string.split(" ")
		i = 0
		nopush = false
		begin
		@iter = (0...@sections.length).to_enum
		while true
 			i = @iter.next
			part = @sections[i]	
			parseNormalMode(part)
		end
		rescue StopIteration
			#iterators only throw an exception when they're done
		rescue RuntimeError => e
		#this bit handles an exceptions that parse
		#raised and points an arrow at the term in the given string that
		#caused the issue
			x = 0
			for y in 0...i+1
				x += @sections[y].length + 1
			end
			message =  string + "\n"
			(x - 2).times { message += " " } 
			message +=  "^" + "\n" + e.message 
			raise message
		end
	end
	def parseNormalMode(part)
		if(@rules.has_key?(part))
			cmd = @cBuilder.buildCommand(part,@rules[part],@args[part])
			@database.getCommand.push(cmd)
			cmd.do
		elsif(is_a_number?(part))
			
			num = Command.new(lambda {|a| return [@database.round(part)] }, [], @database.round(part),@database)
			
			num.isanum
			@database.getCommand.push(num)
			num.do
		elsif(part == ">>")
			var = @sections[@iter.next]
			if @rules.has_key?(var)
				raise("Can't name a variable the same name as a rule!")
			end
			@database.setVariable(var, @database.getMain.top)
		elsif(@database.isVariable(part))

			num = Command.new(lambda {|a| return [@database.round(@database.getVariable(part))] }, [], @database.round(@database.getVariable(part)),@database)
			
			num.isanum
			@database.getCommand.push(num)
			num.do
		else
			raise("Invalid command")
		end
	end
end
