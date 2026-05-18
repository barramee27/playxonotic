let currentcmd = [0, 0, 0]
let currentfile = "";
const sleep = ms => new Promise(r => setTimeout(r, ms));

Module['print'] = function (text) { console.log(text); }
Module['printErr'] = function (text) { console.error(text) };

// Determine WebSocket proxy URL from current page location
var wsProxyUrl = "";
try {
	var loc = window.location;
	var wsProtocol = loc.protocol === "https:" ? "wss:" : "ws:";
	wsProxyUrl = wsProtocol + "//" + loc.host + "/ws/";
} catch (e) {}

// Set arguments SYNCHRONOUSLY before Module initialization copies them.
var xonotic_args = [
	"-xonotic", "-basedir", "/xonotic",
	"+r_texture_dds_swdecode", "1",
	"+gl_texturecompression", "1",
	"+gl_picmip", "2",
	"+cl_netfps", "60",
	"+rate", "100000",
	"+vid_sRGB", "0",
	"+vid_desktopfullscreen", "0",
	/* Must be on so sys_wasm.c em_on_resize() updates vid_width/vid_height on browser resize. */
	"+vid_resizable", "1",
	"+r_hdr_scenebrightness", "1.25",
	"+r_ambient", "8",
	"+r_shadow_realtime_dlight", "0",
	"+r_shadow_realtime_world", "0",
	"+r_bloom", "0",
	"+r_coronas", "0",
	"+r_water", "0",
	"+r_glsl_deluxemapping", "0",
	"+vid_vsync", "0",
	"+cl_maxfps", "60",
	"+menu_maxfps", "30",
	"+r_drawdecals", "0",
	"+cl_particles_quality", "0.2",
	"+m_yaw", "0.05",
	"+m_pitch", "0.05",
	"+g_weapondamagefactor", "0.7",
	"+g_balance_health_regen", "0.15",
	"+g_balance_pause_health_regen", "2",
	"+g_ctf_flagcarrier_damagefactor", "2",
	"+g_ctf_flagcarrier_forcefactor", "2",
	"+sv_public", "0",
	"+sv_master1", "",
	"+sv_master2", "",
	"+sv_master3", "",
	"+sv_master4", ""
];
if (wsProxyUrl) {
	xonotic_args.push("+em_wss", wsProxyUrl, "binary");
}
/* Match initial video size to the browser viewport so the GL drawable is not 0×0 or stale
   (common cause of “menu OK, 3D black” when the canvas was hidden during SDL/WGL init). */
function getLaunchViewportSize() {
	var viewport = window.visualViewport;
	var w = Math.floor((viewport && viewport.width) || window.innerWidth || document.documentElement.clientWidth || 1280);
	var h = Math.floor((viewport && viewport.height) || window.innerHeight || document.documentElement.clientHeight || 720);
	return {
		w: Math.max(640, w),
		h: Math.max(480, h)
	};
}
(function () {
	var size = getLaunchViewportSize();
	xonotic_args.push("+vid_width", String(size.w), "+vid_height", String(size.h));
})();
var _urlParms = null;
try {
	_urlParms = new URLSearchParams(window.location.search);
	var argsParam = _urlParms.get("args");
	if (argsParam) {
		xonotic_args = xonotic_args.concat(argsParam.split(" "));
	}
	var nameParam = _urlParms.get("name");
	if (nameParam) {
		xonotic_args.push("+name", nameParam);
	}
} catch (e) {}
// Extract auth token for cloud save API
var _cloudToken = null;
try { _cloudToken = _urlParms ? _urlParms.get("token") : null; } catch (e) {}

/**
 * Bases for streaming pk3/d0pk files (HTTP GET). Each must end with / and map to
 * server paths like /game/data/*.pk3 — see playxonotic/deploy/nginx.conf.
 * Override with ?gameBase=https://cdn.example.com/game/ or window.XONOTIC_GAME_BASE.
 * When testing from localhost without a local /game mirror, we fall back to production.
 */
function computeGameAssetBases() {
	var bases = [];
	try {
		var q = _urlParms && _urlParms.get("gameBase");
		if (q) {
			var u = q.trim();
			if (!/^https?:\/\//i.test(u))
				u = new URL(u, window.location.href).href;
			u = u.replace(/\/?$/, "/");
			bases.push(u);
		}
	} catch (e) {}
	try {
		if (typeof window.XONOTIC_GAME_BASE === "string" && window.XONOTIC_GAME_BASE.length)
			bases.push(window.XONOTIC_GAME_BASE.replace(/\/?$/, "/"));
	} catch (e) {}
	try {
		bases.push(new URL("/game/", window.location.href).href);
	} catch (e) {
		bases.push("/game/");
	}
	var host = "";
	try {
		host = window.location.hostname || "";
	} catch (e) {}
	if (host === "localhost" || host === "127.0.0.1")
		bases.push("https://playxonotic.com/game/");
	var seen = {};
	var out = [];
	for (var i = 0; i < bases.length; i++) {
		var b = bases[i];
		if (b && !seen[b]) {
			seen[b] = true;
			out.push(b);
		}
	}
	return out;
}
window._xonoticAssetBases = computeGameAssetBases();

Module['arguments'] = xonotic_args;
if (_urlParms && _urlParms.get("debug")) {
	console.log("Xonotic launch arguments:", xonotic_args);
	console.log("Game asset bases (pk3/d0pk):", window._xonoticAssetBases);
}

// ---------------------------------------------------------------------------
// Cloud Save: restore from server on load, upload on exit / periodically
// ---------------------------------------------------------------------------
var SAVE_FILES = [
	'/home/web_user/.xonotic/data/config.cfg',
	'/home/web_user/.xonotic/data/onslaught.dat'
];

function cloudSaveGetApiBase() {
	try { return window.location.origin; } catch (e) { return ''; }
}

function cloudSaveRestore(depName) {
	if (!_cloudToken) return;
	Module.addRunDependency(depName);
	var xhr = new XMLHttpRequest();
	xhr.open('GET', cloudSaveGetApiBase() + '/api/save', true);
	xhr.setRequestHeader('Authorization', 'Bearer ' + _cloudToken);
	xhr.onload = function() {
		if (xhr.status === 200) {
			try {
				var resp = JSON.parse(xhr.responseText);
				if (resp.configData) {
					var raw = atob(resp.configData);
					var json = JSON.parse(raw);
					for (var fname in json) {
						if (json.hasOwnProperty(fname)) {
							try {
								var parts = fname.split('/');
								for (var d = 1; d < parts.length; d++) {
									var dir = parts.slice(0, d).join('/');
									if (dir) { try { FS.mkdir(dir); } catch (ignore) {} }
								}
								var bytes = new Uint8Array(json[fname].length);
								for (var b = 0; b < json[fname].length; b++) bytes[b] = json[fname].charCodeAt(b);
								FS.writeFile(fname, bytes);
							} catch (writeErr) { console.warn('Cloud save: skip ' + fname, writeErr); }
						}
					}
					console.log('Cloud save restored.');
				}
			} catch (parseErr) { console.warn('Cloud save parse error:', parseErr); }
		} else {
			console.log('No cloud save found (HTTP ' + xhr.status + ')');
		}
		Module.removeRunDependency(depName);
	};
	xhr.onerror = function() {
		console.warn('Cloud save fetch failed (network).');
		Module.removeRunDependency(depName);
	};
	xhr.send();
}

function cloudSaveUpload() {
	if (!_cloudToken) return;
	var payload = {};
	var hasData = false;
	for (var i = 0; i < SAVE_FILES.length; i++) {
		try {
			var data = FS.readFile(SAVE_FILES[i]);
			var str = '';
			for (var b = 0; b < data.length; b++) str += String.fromCharCode(data[b]);
			payload[SAVE_FILES[i]] = str;
			hasData = true;
		} catch (e) { /* file not found, skip */ }
	}
	if (!hasData) return;

	var encoded = btoa(JSON.stringify(payload));
	var xhr = new XMLHttpRequest();
	xhr.open('POST', cloudSaveGetApiBase() + '/api/save', true);
	xhr.setRequestHeader('Authorization', 'Bearer ' + _cloudToken);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.send(JSON.stringify({ configData: encoded }));
	console.log('Cloud save uploaded.');
}

// Auto-save every 5 minutes once the engine is running
var _cloudSaveInterval = null;
function startCloudAutoSave() {
	if (!_cloudToken || _cloudSaveInterval) return;
	_cloudSaveInterval = setInterval(cloudSaveUpload, 5 * 60 * 1000);
}

// Save on tab close / visibility change
try {
	window.addEventListener('beforeunload', function() { cloudSaveUpload(); });
	document.addEventListener('visibilitychange', function() {
		if (document.visibilityState === 'hidden') cloudSaveUpload();
	});
} catch (e) {}

// ---------------------------------------------------------------------------
// Streaming pk3 loader: fetch large game files after the tiny preload,
// but before the engine starts scanning directories.
// URLs are: <gameBase> + relpath  e.g. https://playxonotic.com/game/data/foo.pk3
// ---------------------------------------------------------------------------
var pk3Files = [
	{ relpath: 'data/font-unifont-20230620.pk3',  path: '/xonotic/data/font-unifont-20230620.pk3',  label: 'Unicode Font', sizeMB: 12 },
	{ relpath: 'data/font-xolonium-20230620.pk3',  path: '/xonotic/data/font-xolonium-20230620.pk3',  label: 'UI Font', sizeMB: 1 },
	{ relpath: 'data/xonotic-20230620-xoncompat.pk3',  path: '/xonotic/data/xonotic-20230620-xoncompat.pk3',  label: 'Compatibility Data', sizeMB: 28 },
	{ relpath: 'key_0.d0pk',  path: '/xonotic/key_0.d0pk',  label: 'Game Key', sizeMB: 1 },
	{ relpath: 'data/xonotic-20230620-data.pk3',  path: '/xonotic/data/xonotic-20230620-data.pk3',  label: 'Game Data',  sizeMB: 318 },
	{ relpath: 'data/xonotic-20230620-maps.pk3',  path: '/xonotic/data/xonotic-20230620-maps.pk3',  label: 'Maps',       sizeMB: 626 },
	{ relpath: 'data/zz_playxonotic_mod.pk3',  path: '/xonotic/data/zz_playxonotic_mod.pk3',  label: 'Custom Logic', sizeMB: 2 }
];

// Bump when loader logic changes so stale Cache API entries are not reused.
var XONOTIC_PK3_CACHE_NAME = "xonotic-pk3-cache-v2";

// Shared progress state (read by the shell HTML loading screen)
window._pk3Progress = {};

function joinGameAssetUrl(base, relpath) {
	return base.replace(/\/?$/, "/") + String(relpath).replace(/^\//, "");
}

function showPk3Fatal(message) {
	try {
		var el = document.getElementById("status");
		if (el) el.textContent = message;
	} catch (e) {}
	try {
		console.error(message);
	} catch (e) {}
}

function fileExistsInFS(path) {
	try {
		if (typeof FS === "undefined" || typeof FS.analyzePath !== "function")
			return false;
		var o = FS.analyzePath(path);
		return !!(o && o.exists);
	} catch (e) {
		return false;
	}
}

function fetchPK3(file, depName) {
	var bases = window._xonoticAssetBases && window._xonoticAssetBases.length
		? window._xonoticAssetBases
		: [ new URL("/game/", window.location.href).href ];
	var key = file.relpath;
	window._pk3Progress[key] = { loaded: 0, total: file.sizeMB * 1048576, label: file.label, done: false };

	/* Emscripten --preload-file already placed this in MEMFS; do not block on HTTP. */
	if (fileExistsInFS(file.path)) {
		window._pk3Progress[key].loaded = window._pk3Progress[key].total;
		window._pk3Progress[key].done = true;
		try {
			console.log("Using embedded package data:", file.label, file.path);
		} catch (e) {}
		return;
	}

	Module.addRunDependency(depName);

	function finishFromBuffer(buffer, cacheApi, cacheUrl) {
		var data = new Uint8Array(buffer);
		try {
			FS.writeFile(file.path, data);
		} catch (err) {
			console.error("Failed to write " + file.path + ":", err);
			showPk3Fatal("Could not write game data to virtual filesystem.");
			try {
				Module.removeRunDependency(depName);
			} catch (e) {}
			return;
		}
		console.log("Loaded " + file.label + " (" + (data.length / 1048576).toFixed(0) + " MB)");
		window._pk3Progress[key].loaded = window._pk3Progress[key].total;
		window._pk3Progress[key].done = true;
		if (cacheApi && cacheUrl && buffer) {
			var res = new Response(buffer, {
				headers: { "Content-Type": "application/octet-stream", "Cache-Control": "public, max-age=31536000, immutable" }
			});
			cacheApi.put(cacheUrl, res);
		}
		Module.removeRunDependency(depName);
	}

	function startDownload(cacheApi) {
		downloadPK3(file, depName, cacheApi, 0);
	}

	if ("caches" in window) {
		caches.open(XONOTIC_PK3_CACHE_NAME).then(function(cache) {
			function tryCache(baseIdx) {
				if (baseIdx >= bases.length) {
					startDownload(cache);
					return;
				}
				var url = joinGameAssetUrl(bases[baseIdx], file.relpath);
				cache.match(url).then(function(response) {
					if (response) {
						console.log("Loaded " + file.label + " from cache (" + url + ").");
						response.arrayBuffer().then(function(buffer) {
							finishFromBuffer(buffer, cache, url);
						});
					} else {
						tryCache(baseIdx + 1);
					}
				});
			}
			tryCache(0);
		}).catch(function(err) {
			console.warn("Cache API unavailable, downloading directly:", err);
			startDownload(null);
		});
	} else {
		startDownload(null);
	}
}

function downloadPK3(file, depName, cache, baseIndex) {
	var bases = window._xonoticAssetBases && window._xonoticAssetBases.length
		? window._xonoticAssetBases
		: [ new URL("/game/", window.location.href).href ];
	var idx = typeof baseIndex === "number" ? baseIndex : 0;
	var key = file.relpath;

	if (idx >= bases.length) {
		var msg =
			"Could not download required game file: " +
			file.label +
			"\n\nServe pk3/d0pk files under /game/data/ on your site (see PlayXonotic nginx), " +
			"or open with ?gameBase=https://your-host/game/\n\n" +
			"For a fully offline build, copy pk3 into wasm/pk3-embed/ and rebuild (see README.txt there).\n\n" +
			"Tried bases: " +
			bases.join(", ");
		showPk3Fatal("Missing game data: " + file.label + " — see browser console.");
		alert(msg);
		try {
			Module.removeRunDependency(depName);
		} catch (e) {}
		return;
	}

	var url = joinGameAssetUrl(bases[idx], file.relpath);
	var xhr = new XMLHttpRequest();
	xhr.open("GET", url, true);
	xhr.responseType = "arraybuffer";

	xhr.onprogress = function(e) {
		if (e.lengthComputable) {
			window._pk3Progress[key].loaded = e.loaded;
			window._pk3Progress[key].total = e.total;
		} else {
			window._pk3Progress[key].loaded = e.loaded;
		}
	};

	xhr.onload = function() {
		if (xhr.status === 200 || xhr.status === 0) {
			var buffer = xhr.response;
			var data = new Uint8Array(buffer);
			try {
				FS.writeFile(file.path, data);
			} catch (err) {
				console.error("Failed to write " + file.path + ":", err);
				showPk3Fatal("Could not write game data.");
				try {
					Module.removeRunDependency(depName);
				} catch (e) {}
				return;
			}
			console.log("Downloaded " + file.label + " from " + url);
			window._pk3Progress[key].loaded = window._pk3Progress[key].total;
			window._pk3Progress[key].done = true;

			if (cache) {
				var res = new Response(buffer, {
					headers: { "Content-Type": "application/octet-stream", "Cache-Control": "public, max-age=31536000, immutable" }
				});
				cache.put(url, res);
			}

			data = null;
			buffer = null;

			Module.removeRunDependency(depName);
		} else {
			console.warn("Fetch failed " + url + " HTTP " + xhr.status + ", trying next base...");
			downloadPK3(file, depName, cache, idx + 1);
		}
	};

	xhr.onerror = function() {
		console.warn("Network error fetching " + url + ", trying next base...");
		downloadPK3(file, depName, cache, idx + 1);
	};

	xhr.send();
}

var _xonoticPk3LoaderStarted = false;

function startPk3StreamingIfNeeded() {
	if (_xonoticPk3LoaderStarted)
		return;
	_xonoticPk3LoaderStarted = true;
	for (var i = 0; i < pk3Files.length; i++)
		fetchPK3(pk3Files[i], "pk3_" + i);
}

/* Must run before Emscripten's runWithFS (first preRun item). When darkplaces-wasm.data
 * is used, runWithFS returns before pk3 bytes exist; we start HTTP/cache fetches only after
 * removeRunDependency("datafile_...") once MEMFS has the embedded pk3. */
if (!Module["preRun"])
	Module["preRun"] = [];
Module["preRun"].unshift(function () {
	try {
		if (typeof Module.removeRunDependency !== "function" || Module.removeRunDependency.__xonoticPk3Hook)
			return;
		var _origRmDep = Module.removeRunDependency;
		Module.removeRunDependency = function (dep) {
			_origRmDep.call(Module, dep);
			try {
				if (typeof dep === "string" && dep.indexOf("datafile_") === 0)
					startPk3StreamingIfNeeded();
			} catch (e) {
				console.error(e);
			}
		};
		Module.removeRunDependency.__xonoticPk3Hook = true;
	} catch (e) {
		console.warn("xonotic: could not hook datafile completion", e);
	}
});

// ---------------------------------------------------------------------------
// preRun: set up filesystem, then (streaming-only) start pk3 downloads
// ---------------------------------------------------------------------------
if (!Module['preRun']) Module['preRun'] = [];
Module['preRun'].push(function () {
	function stdin() { return 10 };
	FS.init(stdin, null, null);

	// Persistent user data
	FS.mount(IDBFS, {}, "/home/web_user/");
	try { FS.mkdir("/home/web_user/.xonotic"); } catch (e) { }
	try { FS.mkdir("/home/web_user/.xonotic/data"); } catch (e) { }
	FS.symlink("/home/web_user", "/save");

	// Sync persistent filesystem, then restore cloud save
	Module.addRunDependency('idbfs_sync');
	FS.syncfs(true, function (err) {
		if (err) console.error("FS.syncfs error:", err);
		console.log("Filesystem synced.");
		Module.removeRunDependency('idbfs_sync');

		// After local FS is synced, restore cloud save (overwrites local if newer)
		cloudSaveRestore('cloud_save_restore');
		// Start auto-save interval once engine begins
		startCloudAutoSave();
	});

	/* No packaged .data (no --preload-file bundle): start HTTP pk3 fetch in this preRun. */
	try {
		if (!Module.expectedDataFileDownloads)
			startPk3StreamingIfNeeded();
	} catch (e) {}
});
