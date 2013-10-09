module MacroSystem
class Macro
	def initialize()
		@commands = []
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
	def executeMacro(name)
		#for each command in macro name
		#	command.do
	end
	def addMacro(name)
		#add a new macro of name "name"
	end
	def addToMacro(name, command)
		#add a command to the macro "name"
	end
end
end
