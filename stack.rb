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

