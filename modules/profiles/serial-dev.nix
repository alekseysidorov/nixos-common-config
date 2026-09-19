# Tools for debugging devices over serial ports.
#
# This profile focuses on interactive serial consoles, USB-UART discovery,
# transport plumbing, and signal-level debugging. Device-specific flashing and
# SDK tooling belongs to the corresponding project environment.

{ ... }:

{
  flake.modules.homeManager.serialDev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Primary serial console.
        #
        # tio handles the usual embedded debugging workflow well: reconnecting
        # after device resets, timestamps, logging, hex output, line control,
        # RS-485, scripting, and device discovery.
        tio
        # Serial/PTY/network plumbing.
        #
        # Useful for creating virtual serial ports, bridging a TTY to TCP,
        # inserting pipes between processes, and reproducing serial setups
        # without real hardware.
        socat
        # USB device discovery.
        #
        # Particularly useful for identifying USB-UART adapters by VID/PID,
        # inspecting USB topology, and figuring out which device just appeared.
        usbutils
        # Signal-level protocol analysis.
        #
        # Useful when the problem is below the terminal layer: capture UART
        # electrically with a logic analyzer and decode framing, parity, baud
        # rate, and raw traffic.
        sigrok-cli
      ];
    };
}
