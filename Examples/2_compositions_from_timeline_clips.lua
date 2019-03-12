--[[
Example DaVinci Resolve script:
Add composition to currently open timeline to timeline clips what do not have any compositions yet

Get currently open project
--]]
resolve = Resolve()
projectManager = resolve:GetProjectManager()
project = projectManager:GetCurrentProject()

if not project then
	print("No project is loaded")
	os.exit()
end

--[[
Get current timeline. If no current timeline try to load it from timeline list
--]]

timeline = project:GetCurrentTimeline()
if not timeline then
	if project:GetTimelineCount() > 0 then
		timeline = project:GetTimelineByIndex(1)
		project:SetCurrentTimeline(timeline)
	end
end

if not timeline then
	print("Current project has no timelines")
	os.exit()
end

--[[
Add compositions for all clips in timeline
--]]
timelineVideoTrackCount = timeline:GetTrackCount("video")

for index = 1, timelineVideoTrackCount, 1 do
	local clips = timeline:GetItemsInTrack("video", index)
	for clipIdx in pairs(clips) do
		if clips[clipIdx]:GetFusionCompCount() < 1 then
			clips[clipIdx]:AddFusionComp()
		end
	end
end
