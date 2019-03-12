#!/usr/bin/env python


"""
Example DaVinci Resolve script:
Add composition to currently open timeline to timeline clips what do not have any compositions yet
"""

from python_get_resolve import GetResolve
import sys

# Get currently open project
resolve = GetResolve()
projectManager = resolve.GetProjectManager()
project = projectManager.GetCurrentProject()

if not project:
	print("No project is loaded")
	sys.exit()

# Get current timeline. If no current timeline try to load it from timeline list
timeline = project.GetCurrentTimeline()
if not timeline:
	if project.GetTimelineCount() > 0:
		timeline = project.GetTimelineByIndex(1)
		project.SetCurrentTimeline(timeline)

if not timeline:
	print("Current project has no timelines")
	sys.exit()

# add compositions for all clips in timeline
timelineVideoTrackCount = timeline.GetTrackCount("video")

for i in range(int(timelineVideoTrackCount)):
	clips = timeline.GetItemsInTrack("video", i + 1)
	for clipIdx in clips:
		if clips[clipIdx].GetFusionCompCount() < 1:
			clips[clipIdx].AddFusionComp()
