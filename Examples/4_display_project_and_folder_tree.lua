--[[
Example DaVinci Resolve script:
Draw folder and project tree from project manager window.
--]]

local function DisplayProjectsWithinFolder( projectManager, folderString, projectString )
	folderString = folderString or "- "
	projectString = projectString or "  "
	
	folderString = "  "..folderString
	projectString = "  "..projectString
	
	local projects = projectManager:GetProjectsInCurrentFolder()
	for projectIndex in pairs(projects) do
		print(projectString..projects[projectIndex])
	end
	
	local folders = projectManager:GetFoldersInCurrentFolder()
	for folderIndex in pairs(folders) do
		print(folderString..folders[folderIndex])
		if projectManager:OpenFolder(folders[folderIndex]) then
			DisplayProjectsWithinFolder(projectManager, folderString, projectString)
			projectManager:GotoParentFolder()
		end
	end
end

local function DisplayProjectTree( resolve )
	projectManager = resolve:GetProjectManager()
	projectManager:GotoRootFolder()
	print("- Root folder")
	DisplayProjectsWithinFolder(projectManager)
end

resolve = Resolve()

DisplayProjectTree(resolve)
