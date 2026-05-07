{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "vk-turn-proxy";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "cacggghp";
    repo = "vk-turn-proxy";
    rev = "v1.8.3";
    sha256 = "0h03765l4cjzm5l4q180h4zn9q794cijib1fzcv3yqdb45gfwj0f";
  };

  # Hash of Go modules (prefetched from the Go proxy)
  vendorHash = "sha256-yguwRa6KUDU5U8yCuM0zdhI89sCQyciV9VSXI5JFqZs=";

  goPackagePath = "github.com/cacggghp/vk-turn-proxy";

  # Build both client and server binaries, and name them vk-turn-proxy-server/client.
  installPhase = ''
    mkdir -p $out/bin
    export GOBIN=$out/bin
    # Build server and client with new names
    go build -trimpath -ldflags '-s -w' -o $out/bin/vk-turn-proxy-server ./server
    go build -trimpath -ldflags '-s -w' -o $out/bin/vk-turn-proxy-client ./client
  '';

  meta = with lib; {
    description = "VK Turn Proxy — tunnels WireGuard/Hysteria traffic via VK TURN servers";
    homepage = "https://github.com/cacggghp/vk-turn-proxy";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
