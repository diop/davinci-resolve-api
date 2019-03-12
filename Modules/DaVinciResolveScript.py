import sys
import imp
import os

script_module = None
try:
    import fusionscript as script_module
except ImportError:
    # Look for installer based environment variables:
    import os
    lib_path=os.getenv("RESOLVE_SCRIPT_LIB")
    if lib_path:
        try:
            script_module = imp.load_dynamic("fusionscript", lib_path)
        except ImportError:
            pass
    if not script_module:
        # Look for default install locations:
        ext=".so"
        if sys.platform.startswith("darwin"):
            path = "/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Libraries/Fusion/"
        elif sys.platform.startswith("win") or sys.platform.startswith("cygwin"):
            ext = ".dll"
            path = "C:\\Program Files\\Blackmagic Design\\DaVinci Resolve\\"
        elif sys.platform.startswith("linux"):
            path = "/opt/resolve/libs/Fusion/"

        try:
            script_module = imp.load_dynamic("fusionscript", path + "fusionscript" + ext)
        except ImportError:
            pass

if script_module:
    sys.modules[__name__] = script_module
else:
    raise ImportError("Could not locate module dependencies")
