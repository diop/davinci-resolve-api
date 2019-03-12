#!/usr/bin/env python

"""
Example DaVinci Resolve script:
Draw folder and project tree from project manager window.
"""

from python_get_resolve import GetResolve

def DisplayProjectsWithinFolder( projectManager, folderString = "- ", projectString = "  " ):
	folderString = "  " + folderString
	projectString = "  " + projectString
	
	projects = sorted(projectManager.GetProjectsInCurrentFolder().values())
	for projectName in projects:
		print(projectString + projectName)
	
	folders = sorted(projectManager.GetFoldersInCurrentFolder().values())
	for folderName in folders:
		print(folderString + folderName)
		if projectManager.OpenFolder(folderName):
			DisplayProjectsWithinFolder(projectManager, folderString, projectString)
			projectManager.GotoParentFolder()
	return

def DisplayProjectTree( resolve ):
	projectManager = resolve.GetProjectManager()
	projectManager.GotoRootFolder()
	print("- Root folder")
	DisplayProjectsWithinFolder(projectManager)
	return

# Get currently open project
resolve = GetResolve()

DisplayProjectTree(resolve)
