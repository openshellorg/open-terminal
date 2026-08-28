/**
 * Headless spike: feed vt-d and dump the character-cell grid.
 * Proves VT/ANSI -> Screen without GPU or PTY.
 */
module spike_cells;

import std.conv : to;
import std.stdio;
import vt;

void main()
{
	auto em = new Emulator(40, 8);
	em.feed("\033[1;32mopen-terminal\033[0m spike-cells\n");
	em.feed("\033[36mvt-d\033[0m character-cell surface\n");
	em.feed("session windows = separate HWND\n");
	em.feed("index window = tabs / thumb grid\n");

	auto s = em.screen;
	foreach (r; 0 .. s.rows)
	{
		dchar[] line;
		line.reserve(s.cols);
		foreach (c; 0 .. s.cols)
		{
			const ch = s.at(c, r).ch;
			line ~= (ch == 0 || ch == ' ') ? ' ' : ch;
		}
		writeln(to!string(line));
	}
	writeln("-- ok: vt-d Emulator + Screen --");
}