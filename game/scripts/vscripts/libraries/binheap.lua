-- Binary Heap implementation copy-pasted from https://gist.github.com/starwing/1757443a1bd295653c39
-- BinaryHeap[1] always points to the element with the lowest "key" variable
-- API
-- BinaryHeap(key) - Creates a new BinaryHeap with key. The key is the name of the integer variable used to sort objects.
-- BinaryHeap:Insert - Inserts an object into BinaryHeap
-- BinaryHeap:Remove - Removes an object from BinaryHeap

BinaryHeap = BinaryHeap or {}
BinaryHeap.__index = BinaryHeap

function BinaryHeap:Insert(item)
	local index = #self + 1
	local key = self.key
	item.index = index
	self[index] = item
	while index > 1 do
		local parent = math.floor(index/2)
		if self[parent][key] <= item[key] then
			break
		end
		self[index], self[parent] = self[parent], self[index]
		self[index].index = index
		self[parent].index = parent
		index = parent
	end
	return item
end

function BinaryHeap:Remove(item)
	local index = item.index
	if self[index] ~= item then return end
	local key = self.key
	local heap_size = #self
	if index == heap_size then
		self[heap_size] = nil
		return
	end
	self[index] = self[heap_size]
	self[index].index = index
	self[heap_size] = nil
	while true do
		local left = index*2
		local right = left + 1
		if not self[left] then break end
		local newindex = right
		if self[index][key] >= self[left][key] then
			if not self[right] or self[left][key] < self[right][key] then
				newindex = left
			end
		elseif not self[right] or self[index][key] <= self[right][key] then
			break
		end
		self[index], self[newindex] = self[newindex], self[index]
		self[index].index = index
		self[newindex].index = newindex
		index = newindex
	end
end

setmetatable(BinaryHeap, {__call = function(self, key) return setmetatable({key=key}, self) end})
