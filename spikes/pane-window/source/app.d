/**
 * Pane spike: dew + Vello window showing vt-d cells as monospace text rows.
 *
 * Does not yet attach ConPTY (pty-d). Goal: prove "dew window showing cells".
 * Build requires Rust cargo for vello-d bridge and MSVC link on Windows.
 */
module spike_pane;

import std.conv : to;
import std.file : exists, read;
import std.math : abs;
import std.stdio;
import std.string : stripRight;

import dew;
import glfw3.api;
import vt;

version (Windows)
{
	import core.sys.windows.windows;
	extern (C) HWND glfwGetWin32Window(GLFWwindow* window);
}

void main()
{
	writeln("open-terminal spike-pane: dew + vt-d cells");

	auto em = new Emulator(48, 12);
	em.feed("\033[1;37mopen-terminal\033[0m\n");
	em.feed("decoupled index  |  session windows\n");
	em.feed("\033[32mcells via vt-d\033[0m  |  paint via dew/vello\n");
	em.feed("Consolas preferred (setUiFont)\n");

	version (Windows)
	{
		loadConsolasIfPresent();
		runWindowed(em);
	}
	else
	{
		stderr.writeln("spike-pane: windowed path is Windows-first in this scaffold.");
		dumpCells(em);
	}
}

void loadConsolasIfPresent()
{
	foreach (p; [
		`C:\Windows\Fonts\consola.ttf`,
		`C:\Windows\Fonts\Consolas.ttf`
	])
	{
		if (exists(p))
		{
			setUiFont(cast(ubyte[]) read(p), 0);
			writeln("UI font: ", p);
			return;
		}
	}
	writeln("Consolas not found; dew default UI font will be used.");
}

void dumpCells(Emulator em)
{
	auto s = em.screen;
	foreach (r; 0 .. s.rows)
	{
		dchar[] line;
		foreach (c; 0 .. s.cols)
		{
			const ch = s.at(c, r).ch;
			line ~= (ch == 0) ? ' ' : ch;
		}
		writeln(stripRight(to!string(line)));
	}
}

string[] cellLines(Emulator em)
{
	string[] lines;
	auto s = em.screen;
	foreach (r; 0 .. s.rows)
	{
		dchar[] line;
		foreach (c; 0 .. s.cols)
		{
			const ch = s.at(c, r).ch;
			line ~= (ch == 0) ? ' ' : ch;
		}
		lines ~= stripRight(to!string(line));
	}
	return lines;
}

bool approxEqualScale(ScaleFactor a, ScaleFactor b, float eps = 1e-3f) @safe @nogc pure nothrow
{
	return abs(a.x - b.x) <= eps && abs(a.y - b.y) <= eps;
}

version (Windows)
{
	extern (C) void glfwContentScaleThunk(void* win, float* sx, float* sy) nothrow @nogc
	{
		glfwGetWindowContentScale(cast(GLFWwindow*) win, sx, sy);
	}

	bool attachBackend(VelloRenderBackend gpu, GLFWwindow* window, uint w, uint h) @trusted
	{
		HWND hwnd = glfwGetWin32Window(window);
		HINSTANCE hinstance = GetModuleHandleA(null);
		gpu.attach(cast(void*) hwnd, cast(void*) hinstance, w, h);
		return gpu.attached;
	}

	void runWindowed(Emulator em)
	{
		if (!glfwInit())
		{
			stderr.writeln("glfwInit failed");
			return;
		}
		scope (exit)
			glfwTerminate();

		glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
		enum uint winW = 900;
		enum uint winH = 520;
		auto window = glfwCreateWindow(winW, winH, "open-terminal spike-pane", null, null);
		if (window is null)
		{
			stderr.writeln("glfwCreateWindow failed");
			return;
		}
		scope (exit)
			glfwDestroyWindow(window);

		auto gpu = new VelloRenderBackend();
		if (!attachBackend(gpu, window, winW, winH))
		{
			stderr.writeln("VelloRenderBackend attach failed");
			return;
		}
		scope (exit)
			gpu.shutdown();

		Arena frameArena;
		scope (exit)
			frameArena.dispose();

		App app;
		app.ui.arena = &frameArena;
		beginUi(app.ui);
		scope (exit)
			endUi();

		auto lines = cellLines(em);

		void rebuild() @safe
		{
			app.ui.beginFrame();
			beginUi(app.ui);
			app.setRoot(VStack(
				Text("open-terminal -- session pane spike").fontSize(18).bold(),
				Text("Index window TBD; this HWND is a session surface mock.").fontSize(13),
				Text(lines.length > 0 ? lines[0] : " ").fontSize(14),
				Text(lines.length > 1 ? lines[1] : " ").fontSize(14),
				Text(lines.length > 2 ? lines[2] : " ").fontSize(14),
				Text(lines.length > 3 ? lines[3] : " ").fontSize(14),
				Text(lines.length > 4 ? lines[4] : " ").fontSize(14),
				Text(lines.length > 5 ? lines[5] : " ").fontSize(14),
			).spacing(4).padding(12));
		}

		rebuild();
		app.backend = gpu;

		{
			int fbW, fbH;
			glfwGetFramebufferSize(window, &fbW, &fbH);
			auto scale = contentScaleFromGlfw(cast(void*) window,
				cast(GlfwContentScaleFn) &glfwContentScaleThunk);
			app.syncFromFramebuffer(fbW, fbH, scale);
		}
		app.frame();

		while (!glfwWindowShouldClose(window))
		{
			glfwPollEvents();

			int fbW, fbH;
			glfwGetFramebufferSize(window, &fbW, &fbH);
			float sx, sy;
			glfwGetWindowContentScale(window, &sx, &sy);
			auto scale = ScaleFactor(sx, sy);
			if (fbW > 0 && fbH > 0
				&& (fbW != cast(int) app.physicalWidth
					|| fbH != cast(int) app.physicalHeight
					|| !approxEqualScale(app.contentScale, scale)))
				app.syncFromFramebuffer(fbW, fbH, scale);

			app.frame();
		}
	}
}