--[[
Example DaVinci Resolve script:
Based on a given media folder path, this script creates a new project, a default timeline and appends clips into the timeline sorted by name

Inputs: 
- project name
- project framerate
- project width, in pixels
- project height, in pixels
- path to media
--]]

if table.getn(arg) < 5 then
	print("input parameters for scripts are [project name] [framerate] [width] [height] [path to media]")
	os.exit()
end

projectName = arg[1]
framerate = arg[2]
width = arg[3]
height = arg[4]
mediaPath = arg[5]

--[[
Create project and set parameters:
--]]
resolve = Resolve()
projectManager = resolve:GetProjectManager()
project = projectManager:CreateProject(projectName)

if not project then
	print("Unable to create a project '"..projectName.."'")
	os.exit()
end

project:SetSetting("timelineFrameRate", tostring(framerate))
project:SetSetting("timelineResolutionWidth", tostring(width))
project:SetSetting("timelineResolutionHeight", tostring(height))

--[[
Add folder contents to Media Pool:
--]]
mediapool = project:GetMediaPool()
rootFolder = mediapool:GetRootFolder()
clips = resolve:GetMediaStorage():AddItemsToMediaPool(mediaPath)

--[[
Create timeline:
--]]
timelineName = "Timeline 1"
timeline = mediapool:CreateEmptyTimeline(timelineName)
if not timeline then
	print("Unable to create timeline '"..timelineName.."'")
	os.exit()
end

--[[
Sort by name
--]]
table.sort(clips, function(a,b) return a:GetClipProperty("File Name")["File Name"] < b:GetClipProperty("File Name")["File Name"] end)

for clipIndex in pairs(clips) do
	mediapool:AppendToTimeline(clips[clipIndex])
end

projectManager:SaveProject()

print("'"..projectName.."' has been added")
