/**
 * open-terminal scaffold entry.
 *
 * Product: multi-mode layouts (standalone | decoupled index | other) plus
 * session re-association / thumbnail handshake stubs (no IPC yet).
 *
 * Spikes:
 *   dub run -c spike-cells
 *   dub run -c spike-pane
 */
module openterminal.app;

import std.stdio;
import openterminal.association;

void main(string[] args)
{
	writeln("open-terminal scaffold");
	writeln("Layouts: standalone | decoupled-index | other (future).");
	writeln("Association stubs: LayoutMode=", LayoutMode.decoupledIndex,
		" producer=", ThumbnailProducer.sessionHost);
	writeln("Near-term env-refresh host remains openshellorg/terminal (WT fork).");
	writeln();
	writeln("Try:");
	writeln("  dub run -c spike-cells   # vt-d cell dump (no GPU)");
	writeln("  dub run -c spike-pane    # dew window showing cells (needs vello bridge)");
	if (args.length > 1)
		writeln("args: ", args[1 .. $]);
}