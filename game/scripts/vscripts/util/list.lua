--Lists are slightly less efficient when traversing (due to cpu cache misses, not really important stuff) and is NOT a random-access data structure, but writes a constant amount of memory when things are appended to it. Each item in a list contains a pointer to the next item in the list.
--This barebones list is designed for the re-written timers system
--DO NOT PLACE AN ITEM IN 2 LISTS
--coded by Celireor

LinkedList = LinkedList or {}

--Call should be a function with 2-3 variables (item, index, and optional tabledata) which returns true if it should stop looping
function LinkedList:Traverse(list, call, tabledata)
	local currentItem = list
	local index = 0
	if not currentItem.next then return false end
	while currentItem.next ~= list do
		index = index + 1
		currentItem = currentItem.next
		if (call(currentItem, index, tabledata)) then return true end
	end
	return true
end

function LinkedList:AppendBefore(item, list, next)
	local next = next or list
	local prev = next.prev or list
	self:append(item, prev, next)
end

function LinkedList:AppendAfter(item, list, prev)
	local prev = prev or list
	local next = prev.next or list
	self:append(item, prev, next)
end

--internal, do not use
function LinkedList:append(item, prev, next)
	prev.next = item
	next.prev = item
	item.prev = prev
	item.next = next
end

function LinkedList:Remove(item)
	local prev = item.prev
	local next = item.next
	if prev ~= next then
		prev.next = next
		next.prev = prev
	else
		prev.next = nil
		next.prev = nil
	end
	item.prev = nil
	item.next = nil
end
