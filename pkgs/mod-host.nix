{ lib
, stdenv
, fetchFromGitHub
, jack2
, lilv
, fftw
, fftwFloat
, pkg-config
, python3
, readline
}:

stdenv.mkDerivation {
  pname = "mod-host";
  version = "unstable-2024-07-13";

  src = fetchFromGitHub {
    owner = "mod-audio";
    repo = "mod-host";
    rev = "master";
    # Можно заменить на конкретный commit или tag для воспроизводимости
    sha256 = "sha256-C7HaPEJhAJcAiekv9o4R3utbXQ6WnGnxVzrNR4ojMyo=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config python3 ];
  buildInputs = [ jack2 lilv fftw fftwFloat readline ];

  buildPhase = ''
    echo "PWD: $(pwd)"
    ls -l
    if [ -d utils ]; then
      ls -l utils
    else
      echo "utils directory not found!"
    fi
    chmod +x utils/txt2cvar.py || true
    sed -i 's|@utils/txt2cvar.py|@python3 utils/txt2cvar.py|g' Makefile
    # Патчим Makefile: все .so-файлы устанавливаем только в $out/lib/jack/
    sed -i \
      -e 's|$(DESTDIR)$(shell pkg-config --variable=libdir jack)/jack/|$(DESTDIR)$(PREFIX)/lib/jack/|g' \
      -e 's|install -m 644 mod-monitor.so.*|install -m 644 mod-monitor.so $(DESTDIR)$(PREFIX)/lib/jack/|g' \
      -e 's|install -m 644 fake-input.so.*|install -m 644 fake-input.so $(DESTDIR)$(PREFIX)/lib/jack/|g' \
      -e 's|install -m 644 $(PROG).so.*|install -m 644 $(PROG).so $(DESTDIR)$(PREFIX)/lib/jack/|g' \
      Makefile
    make PREFIX=$out
  '';

  installPhase = ''
    make PREFIX=$out MANDIR=$out/share/man/man1 install
  '';

  meta = with lib; {
    description = "LV2 host for JACK, controllable via socket or command line";
    homepage = "https://github.com/mod-audio/mod-host";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ alekseysidorov ];
    platforms = platforms.linux;
  };
}
