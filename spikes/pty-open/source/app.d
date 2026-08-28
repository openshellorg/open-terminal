/**
 * PTY smoke: open ConPTY/POSIX PTY via pty-d, resize, close.
 * Does not yet wire vt-d feed loop (next spike).
 */
module spike_pty;

import std.stdio;
import pty;

void main()
{
	writeln("open-terminal spike-pty: pty-d open/resize");
	auto session = Pty.open(80, 24);
	scope (exit)
		session.close();
	version (Windows)
	{
		writefln("ConPTY HPCON=%s", session.handle);
	}
	else version (Posix)
	{
		writefln("POSIX master=%s slave=%s", session.masterFd, session.slaveName);
	}
	session.resize(100, 30);
	writeln("resized to 100x30 — ok");
}
