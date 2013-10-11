#The intent of this is to provide a facade that will remove all of the dumb things I've been doing so far with singletons and crap.
require './stack'
class Database
	def initialize
		@mainStack = Stack.new
		@commandStack = Stack.new
		@objtable = Hash.new
		@r = 6
	end
	def round(num)
		return num.to_f.round(@r)
	end
	def setRound(num)
		@r = num
	end
	def getMain
		return @mainStack
	end
	def getCommand
		return @commandStack
	end
	def emptyObjtable
		@objtable = Hash.new
	end
	def isVariable(name)
		return @objtable.has_key?(name)
	end
	def setVariable(name, value)
		@objtable[name] = value
	end
	def getVariable(name)
		return @objtable[name]
	end
	def objtable
		return @objtable
	end
end
