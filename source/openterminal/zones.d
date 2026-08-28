/**
 * Contained tiling / nested zone model types (product application).
 * HCI pattern: contained-tiling; product page: nested-tiling-zones.
 */
module openterminal.zones;

/// A region (possibly its own OS window) that holds tiled surfaces.
struct Zone
{
	string zoneId;
	/// Optional monitor hint (`mon1`, display index, etc.).
	string monitorHint;
	/// Empty zones may render faded until populated.
	bool fadedUntilPopulated = true;
	/// Product-defined layout key (bsp/grid TBD).
	string tileLayout = "grid";
}

/// Where a group (or its sessions) currently display.
struct GroupDisplayBinding
{
	string groupId;
	string zoneId;
	/// sessionId -> tile slot label inside the zone.
	string[string] sessionPlacements;
}

/// Mutable zone desk state (in-process spike).
final class ZoneDesk
{
	Zone[] zones;
	GroupDisplayBinding[] bindings;

	Zone* findZone(string zoneId) pure nothrow
	{
		foreach (ref z; zones)
			if (z.zoneId == zoneId)
				return &z;
		return null;
	}

	void spawnZone(string zoneId, string monitorHint = null)
	{
		zones ~= Zone(zoneId, monitorHint, true, "grid");
	}

	/// Register a group into a zone; clears faded flag when tiles placed.
	void registerGroup(GroupDisplayBinding binding)
	{
		auto z = findZone(binding.zoneId);
		if (z is null)
			return;
		// replace existing binding for group
		foreach (i, b; bindings)
		{
			if (b.groupId == binding.groupId)
			{
				bindings[i] = binding;
				goto populated;
			}
		}
		bindings ~= binding;
	populated:
		if (binding.sessionPlacements.length > 0)
			z.fadedUntilPopulated = false;
	}
}
