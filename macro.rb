module MacroSystem
require './stack'
class Macro
	def initialize()
		@commands = []
		@stack = []
	end
	def add(command)
		@commands.push(command)
	end
	def do()
		@commands.each do |command|
			command.do()
		end
		#grab the state of the stack
		#push the results onto the actual stack
		#push self onto the commandStack
	end
	def undo()
		#pop a number of things that were pushed 
		#onto the stack off of the stack
	end
	def to_s()
		#print out all of the commands that will be executed in RPN
		returnString = ""
		@commands.each do |thing|
			returnString << thing.to_s
		end
		return returnString
	end
end
class Object
	def getValue(name)
		#look up in object table the value of that name
	end
	def do()
		#getValue and push to the stack
	end
end
class MacroTable
	def initialize
		@macros = Hash.new
	end
	def executeMacro(name)
		#for each command in macro name
		#	command.do
	end
	def addMacro(name)
		#add a new macro of name "name"
		@macros[name] = Macro.new
	end
	def addToMacro(name, command)
		#add a command to the macro "name"
		@macros[name].add(command)
	end
	def getTable
		return @macros
	end
end
end
