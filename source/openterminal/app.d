/**
 * open-terminal scaffold entry — demos in-process registry + zone desk.
 *
 * Spikes:
 *   dub run -c spike-cells
 *   dub run -c spike-pane
 *   dub run -c spike-pty
 *
 * Layout mocks (web): https://hci-nerdz.github.io/shell-context-demo/
 */
module openterminal.app;

import std.stdio;
import openterminal.association;
import openterminal.manager;
import openterminal.registry;
import openterminal.zones;

void main(string[] args)
{
	writeln("open-terminal scaffold");
	writeln("Layouts: standalone | decoupledIndex | projectGroupedManager | nestedZones | other");

	auto reg = new InProcessAssociationRegistry();
	SessionRegistration regPayload;
	regPayload.groupId = "proj-a";
	regPayload.sourceLayout = LayoutMode.projectGroupedManager;
	regPayload.spawnSource = "devcentr";
	regPayload.lastCliAppId = "nu";
	regPayload.tabs = [
		TabDescriptor("a1", "nu build", "hwnd:a1"),
		TabDescriptor("a2", "docs preview", "hwnd:a2"),
	];
	regPayload.thumbnailPermission = true;
	reg.register(regPayload);
	reg.subscribe(ThumbnailSubscription("sub-mgr", "proj-a", true));
	reg.focusSurface("hwnd:a1");

	auto desk = new ZoneDesk();
	desk.spawnZone("z-mon1", "monitor-1");
	desk.spawnZone("z-mon2", "monitor-2");
	GroupDisplayBinding bind;
	bind.groupId = "proj-a";
	bind.zoneId = "z-mon1";
	bind.sessionPlacements = ["a1": "top-right", "a2": "below"];
	desk.registerGroup(bind);

	auto mgr = new ProjectGroupedManagerModel();
	mgr.activeSessionId = "a1";
	mgr.groups = [
		ProjectGroup("proj-a", "shell-architecture", [
			ManagerSession("a1", "nu build", "nu"),
			ManagerSession("a2", "docs preview", "adoc"),
		]),
	];

	writeln("Registry log:");
	foreach (line; reg.log)
		writeln("  ", line);
	writeln("Focused surface: ", reg.focusedSurfaceId);
	writeln("Active manager group: ", mgr.activeGroupId());
	writeln("Zones: ", desk.zones.length, " (z-mon1 faded=", desk.findZone("z-mon1").fadedUntilPopulated,
		", z-mon2 faded=", desk.findZone("z-mon2").fadedUntilPopulated, ")");
	writeln();
	writeln("Near-term env-refresh host remains openshellorg/terminal (WT fork).");
	writeln("Web demos: https://hci-nerdz.github.io/shell-context-demo/");
	writeln("Try:");
	writeln("  dub run                 # this registry + zone desk smoke");
	writeln("  dub run -c spike-cells  # vt-d cell dump");
	writeln("  dub run -c spike-pane   # dew window (needs vello)");
	writeln("  dub run -c spike-pty    # pty-d open/resize smoke");
	if (args.length > 1)
		writeln("args: ", args[1 .. $]);
}
