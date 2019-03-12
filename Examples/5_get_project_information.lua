--[[
Example DaVinci Resolve script:
Display project information: timeline, clips within timelines and media pool structure.
--]]

local function DisplayTimelineTrack( timeline, trackType, displayShift )
	local trackCount = timeline:GetTrackCount(trackType)
	for index = 1, trackCount, 1 do
		print(displayShift.."- "..trackType.." "..index)
		clips = timeline:GetItemsInTrack(trackType, index)
		for clipIndex in pairs(clips) do
			print(displayShift.."    "..clips[clipIndex]:GetName())
		end
	end
end

local function DisplayTimelineInfo( timeline, displayShift )
	print(displayShift.."- "..timeline:GetName())
	displayShift = "  "..displayShift
	DisplayTimelineTrack(timeline , "video", displayShift)
	DisplayTimelineTrack(timeline , "audio", displayShift)
	DisplayTimelineTrack(timeline , "subtitle", displayShift)
	return
end

local function DisplayTimelinesInfo( project )
	print("- Timelines")
	local timelineCount = project:GetTimelineCount()
	
	for index = 1, timelineCount, 1 do
		DisplayTimelineInfo(project:GetTimelineByIndex(index), "  ")
	end
end

local function DisplayFolderInfo( folder, displayShift )
	print(displayShift.."- "..folder:GetName())
	local clips = folder:GetClips()
	for clipIndex in pairs(clips) do
		print(displayShift.."  "..clips[clipIndex]:GetClipProperty("File Name")["File Name"])
	end
	
	displayShift = "  "..displayShift
	
	local folders = folder:GetSubFolders()
	for folderIndex in pairs(folders) do
		DisplayFolderInfo(folders[folderIndex], displayShift)
	end
end

local function DisplayMediaPoolInfo( project )
	mediaPool = project:GetMediaPool()
	print("- Media pool")
	DisplayFolderInfo(mediaPool:GetRootFolder(), "  ")
end

local function DisplayProjectInfo( project )
	print("-----------")
	print("Project '"..project:GetName().."':")
	print("  Framerate " .. project:GetSetting("timelineFrameRate"))
	print("  Resolution " .. project:GetSetting("timelineResolutionWidth") .. "x" .. project:GetSetting("timelineResolutionHeight"))
	
	DisplayTimelinesInfo(project)
	print("")
	DisplayMediaPoolInfo(project)
end


resolve = Resolve()
projectManager = resolve:GetProjectManager()
project = projectManager:GetCurrentProject()

DisplayProjectInfo(project)
