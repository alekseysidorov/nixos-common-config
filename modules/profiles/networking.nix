{ ... }:

{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Core Linux networking state and routing.
        iproute2
        iputils

        # Link and interface diagnostics.
        ethtool

        # Packet capture and inspection.
        tcpdump

        # Path, reachability and latency diagnostics.
        mtr
        nmap

        # Throughput testing.
        iperf3

        # DNS diagnostics.
        dnsutils

        # Stateful firewall / NAT inspection.
        nftables
        conntrack-tools

        # General-purpose socket plumbing.
        socat
      ];
    };
}
