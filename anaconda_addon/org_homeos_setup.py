#!/usr/bin/env python3
"""
homeOS Setup Addon for Anaconda
Provides homeOS-specific installation configuration
"""

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("AnacondaWidgets", "3.3")

from gi.repository import Gtk
from pyanaconda.ui.gui.spokes import NormalSpoke
from pyanaconda.ui.categories import SoftwareAndUpdatesCategory
from pyanaconda.ui.gui.utils import setup_gtk_direction

__all__ = ["HomeOSSpoke"]

class HomeOSSpoke(NormalSpoke):
    """
    homeOS Configuration Spoke
    """
    builderObjects = ["homeosWindow"]
    mainWidgetName = "homeosWindow"
    uiFile = "homeos_setup.glade"
    
    category = SoftwareAndUpdatesCategory
    icon = "applications-system-symbolic"
    title = "homeOS Setup"

    def __init__(self, data, storage, payload, instclass):
        super().__init__(data, storage, payload, instclass)
        self._enable_updates = True
        self._enable_flatpaks = True
        self._setup_containers = True

    def initialize(self):
        super().initialize()
        setup_gtk_direction()

    def refresh(self):
        self._updates_switch.set_active(self._enable_updates)
        self._flatpaks_switch.set_active(self._enable_flatpaks)
        self._containers_switch.set_active(self._setup_containers)

    def apply(self):
        # Store configuration for post-install
        with open("/tmp/homeos-config", "w") as f:
            f.write(f"ENABLE_UPDATES={self._enable_updates}\n")
            f.write(f"ENABLE_FLATPAKS={self._enable_flatpaks}\n")
            f.write(f"SETUP_CONTAINERS={self._setup_containers}\n")

    @property
    def ready(self):
        return True

    @property
    def completed(self):
        return True

    @property
    def mandatory(self):
        return False

    @property
    def status(self):
        return "homeOS features configured"