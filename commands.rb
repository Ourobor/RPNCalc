module Commands
require './stack'
class CommandBuilder
	@r = 6
	@rules = nil
	@args = nil
	def initialize
		@rules = Hash.new
		@args = Hash.new
		@r = 6
		addRule("+", lambda {|a| return [a[1] + a[0]] }, 2)
		addRule("q", Proc.new { exit }, 0)
		addRule("-", lambda {|a| return [a[1] - a[0]] }, 2)
		addRule("*", lambda {|a| return [a[1] * a[0]] }, 2)
		addRule("/", lambda {|a| return [a[1] / a[0]] }, 2)
		addRule("^", lambda {|a| return [a[1] ** a[0]] } , 2)
		addRule("s", lambda {|a| return [a[0],a[1]]}, 2)
		addRule("d", lambda {|a| return [a[0],a[0]]},1)
		addRule("c", lambda {|a| return []}, 1)
		addRule("cc", lambda {|a| Stack.S.clear;return []}, 0)
		addRule("sqrt", lambda {|a| return [Math.sqrt(a[0])]}, 1)
		addRule("sin", lambda {|a| return [Math.sin(a[0])]}, 1)
		addRule("sind", lambda {|a| return [Math.sin((a[0]/180)*Math::PI)]}, 1)

		addRule("cos", lambda {|a| return [Math.cos(a[0])]}, 1)

		addRule("cosd", lambda {|a| return [Math.cos((a[0]/180)*Math::PI)]}, 1)
		addRule("tan", lambda {|a| return [Math.tan(a[0])]}, 1)
		addRule("tand", lambda {|a| return [Math.tan((a[0]/180)*Math::PI)]}, 1)
		addRule("atan", lambda {|a| return [Math.atan(a[0])]}, 1)
		addRule("atand", lambda {|a| return [(Math.atan(a[0]) * 180) / Math::PI]}, 1)
		addRule("asin", lambda {|a| return [Math.asin(a[0])]}, 1)
		addRule("asind", lambda {|a| return [(Math.asin(a[0]) * 180) / Math::PI]}, 1)
		addRule("acos", lambda {|a| return [Math.acos(a[0])]}, 1)
		addRule("acosd", lambda {|a| return [(Math.acos(a[0]) * 180) / Math::PI]}, 1)
		addRule("r", lambda {|a| @r = a[0]; return []}, 1)
		addRule("ckck", lambda {|a| Stack.S.clear; Stack.U.clear; return [] }, 0)
		addRule("u", lambda {|a| return []}, 0)
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
		for part in sections
			i += 1
			if(@rules.has_key?(part))
				#parse thing
				buildCommand(part).do
			elsif(is_a_number?(part))
				#push
				Stack.S.push(part.to_f.round(@r))
			else
				#bail
				raise("Invalid command")
			end
		end
		rescue RuntimeError => e#this bit handles an exceptions that parse
		#raised and points an arrow at the term in the given string that
		#caused the issue
			Stack.U.pop
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
	def buildCommand(command)		
		args = []
		for x in 0...@args[command]
			args << Stack.S.pop
		end
		command = Command.new(@rules[command],args)	
		return command
	end
end
class Command
	@exec = nil
	@args = nil
	@value = nil
	def initialize(lamb,args)
		@exec = lamb
		@args = args
	end
	def do
		topush = @exec.call(@args)
		for item in topush
			Stack.S.push(item)
		end
		p topush
	end
end
CB = CommandBuilder.new
end
