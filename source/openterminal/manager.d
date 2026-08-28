/**
 * projectGroupedManager scaffold model (UI chrome TBD — dew/dui).
 */
module openterminal.manager;

import openterminal.association;

struct ManagerSession
{
	string sessionId;
	string title;
	string lastCliAppId;
}

struct ProjectGroup
{
	string groupId;
	string projectName;
	ManagerSession[] sessions;
}

/// Structured stub for vertical-tab manager chrome.
final class ProjectGroupedManagerModel
{
	ProjectGroup[] groups;
	string activeSessionId;
	LayoutMode layout = LayoutMode.projectGroupedManager;

	string activeGroupId() const
	{
		foreach (g; groups)
			foreach (s; g.sessions)
				if (s.sessionId == activeSessionId)
					return g.groupId;
		return null;
	}
}
