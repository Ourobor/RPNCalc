class Stack
	@@S = Stack.new
	@@U = Stack.new

        def self.S()
		return @@S
	end
	def self.U()
		return @@U
	end


	@head = nil

        def initialize
        end

	def top
		return @head.value
	end

        def push(value)
                newHead = Element.new(value)
                newHead.next = @head
                @head = newHead
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
