--[[
Example DaVinci Resolve script:
Load a still from DRX file, apply the still to all clips in all timelines. Set render format and codec, add render jobs for all timelines, render to specified path and wait for rendering completion.
Once render is complete, delete all jobs
--]]

local function sleep(n)
	os.execute("sleep " .. tonumber(n))
end

local function TableConcat(t1,t2)
	for i=1, #t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

local function AddTimelineToRender( project, timeline, presetName, targetDirectory, renderFormat, renderCodec )
	project:SetCurrentTimeline(timeline)
	project:LoadRenderPreset(presetName)
	
	if not project:SetCurrentRenderFormatAndCodec(renderFormat, renderCodec) then
		return false
	end
	
	local renderSettings = {}
	renderSettings["SelectAllFrames"] = 1
	renderSettings["TargetDir"] = targetDirectory
	
	project:SetRenderSettings(renderSettings)
	return project:AddRenderJob()
end

local function RenderAllTimelines( resolve, presetName, targetDirectory, renderFormat, renderCodec )
	projectManager = resolve:GetProjectManager()
	project = projectManager:GetCurrentProject()
	if not project then
		return false
	end
	
	resolve.OpenPage("Deliver")
	local timelineCount = project:GetTimelineCount()
	
	for index = 1, timelineCount, 1 do
		if not AddTimelineToRender(project, project:GetTimelineByIndex(index), presetName, targetDirectory, renderFormat, renderCodec) then
			return false
		end
	end
	
	return project:StartRendering()
end

local function IsRenderingInProgress( resolve )
	projectManager = resolve:GetProjectManager()
	project = projectManager:GetCurrentProject()
	if not project then
		return false
	end
	
	return project.IsRenderingInProgress()
end

local function WaitForRenderingCompletion( resolve )
	while IsRenderingInProgress(resolve) do
		sleep(1)
	end
end

local function ApplyDRXToAllTimelineClips( timeline, path, gradeMode )
	gradeMode = gradeMode or 0
	
	local clips = {}
	
	local trackCount = timeline:GetTrackCount("video")
	for index = 1, trackCount, 1 do
		TableConcat(clips, timeline:GetItemsInTrack("video", index))
	end
	
	return timeline:ApplyGradeFromDRX(path, tonumber(gradeMode), clips)
end

local function ApplyDRXToAllTimelines( resolve, path, gradeMode )
	gradeMode = gradeMode or 0

	projectManager = resolve:GetProjectManager()
	project = projectManager:GetCurrentProject()
	if not project then
		return false
	end
	
	local timelineCount = project:GetTimelineCount()
	
	for index = 1, timelineCount, 1 do
		local timeline = project:GetTimelineByIndex(index)
		project:SetCurrentTimeline(timeline)
		if not ApplyDRXToAllTimelineClips(timeline, path, gradeMode) then
			return false
		end
	end
	return true
end

local function DeleteAllRenderJobs( resolve )
	projectManager = resolve:GetProjectManager()
	project = projectManager:GetCurrentProject()
	project:DeleteAllRenderJobs()
	return
end

--[[
Inputs: 
- DRX file to import grade still and apply it for clips
- grade mode (0, 1 or 2)
- preset name for rendering
- render path
- render format
- render codec
--]]

if table.getn(arg) < 6 then
	print("input parameters for scripts are [drx file path] [grade mode] [render preset name] [render path] [render format] [render codec]")
	os.exit()
end

drxPath = arg[1]
gradeMode = arg[2]
renderPresetName = arg[3]
renderPath = arg[4]
renderFormat = arg[5]
renderCodec = arg[6]

--[[
Get currently open project
--]]
resolve = Resolve()

if not ApplyDRXToAllTimelines(resolve, drxPath, gradeMode) then
	print("Unable to apply a still from drx file to all timelines")
	os.exit()
end

if not RenderAllTimelines(resolve, renderPresetName, renderPath, renderFormat, renderCodec) then
	print("Unable to set all timelines for rendering")
	os.exit()
end

WaitForRenderingCompletion(resolve)

DeleteAllRenderJobs(resolve)

print("Rendering is completed.")
