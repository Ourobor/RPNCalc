require './stack'
class CommandBuilder
	def initialize
	end
	def buildCommand(command,lamb,numArgs)		
		args = []
		for x in 0...numArgs
			args << Stack.S.pop
		end
		command = Command.new(lamb,args,command)	
		return command
	end
end
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
			Stack.S.push(Parser.round(item))##TODO
			@numberOfConsequences += 1
		end
	end
	def undo#undo the command
		for x in 0...@numberOfConsequences
			Stack.S.pop#Take the number of things off the stack that we put on
		end
		for y in @args.reverse#put the things we took off the stack back on
			Stack.S.push(Parser.round(y))##TODO
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
