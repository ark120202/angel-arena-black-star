require("libraries/binheap")
--for book of the guardian and others like it
local baseNPC = CDOTA_BaseNPC
if IsClient() then
	baseNPC = C_DOTA_BaseNPC
end

function baseNPC:GetHighestPriorityItem(itemType)
	local heap = self:SetUpItemPriority(itemType)
	if not heap[1] then return nil end
	return heap[1].item
end

function baseNPC:InsertItemPriority(itemType, item, priority)
	local heap = self:SetUpItemPriority(itemType)
	local heapItem = item.buffPriority or {item = item, priority = -priority} --priority is inverted because binheap is bottom first
	item.buffPriority = heapItem
	if heapItem.index then print("Item buff priority already inserted! Stack traceback: "..'\n'..debug.traceback()..'\n') return end --alr. inside heap
	heap:Insert(heapItem)
end

function baseNPC:RemoveItemPriority(itemType, item)
	local heap = self:SetUpItemPriority(itemType)
	local heapItem = item.buffPriority
	heap:Remove(heapItem)
end

function baseNPC:SetUpItemPriority(itemType)
	--setup to avoid error
	local buffPriorityHeaps = self.buffPriorityHeaps
	if not buffPriorityHeaps then
		buffPriorityHeaps = {}
		self.buffPriorityHeaps = buffPriorityHeaps
	end
	local heap = buffPriorityHeaps[itemType]
	if not heap then
		heap = BinaryHeap("priority")
		buffPriorityHeaps[itemType] = heap
	end
	return heap
end
