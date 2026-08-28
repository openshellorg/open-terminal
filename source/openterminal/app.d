/**
 * open-terminal scaffold entry.
 *
 * Product model: calling/index window (tabs / thumbnail grid) owns session
 * references; each live PTY surface may be a separate OS window.
 *
 * Spikes:
 *   dub run -c spike-cells
 *   dub run -c spike-pane
 */
module openterminal.app;

import std.stdio;

void main(string[] args)
{
	writeln("open-terminal scaffold");
	writeln("Product: decoupled session index (tabs/thumbs) + separate session windows.");
	writeln("Near-term env-refresh host remains openshellorg/terminal (WT fork).");
	writeln();
	writeln("Try:");
	writeln("  dub run -c spike-cells   # vt-d cell dump (no GPU)");
	writeln("  dub run -c spike-pane    # dew window showing cells (needs vello bridge)");
	if (args.length > 1)
		writeln("args: ", args[1 .. $]);
}