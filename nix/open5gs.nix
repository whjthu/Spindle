{ llvmPackages
, fetchFromGitHub
, meson
, ninja
, pkg-config
, bison
, flex
, talloc
, libtins
, nghttp2
, curl
, libyaml
, libgcrypt
, libmicrohttpd
, libbson
, mongoc
, libidn
, openssl
, gnutls
, lksctp-tools
, coreutils
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "open5gs";
  version = "2.4.10";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hRlZxz9qPUfJjLA2+1GYnYUd7gJ/UEtMci2CNFnn7oM=";
  };

  patches = [
    ./open5gs.patch
  ];

  freeDiameter = fetchFromGitHub {
    owner = pname;
    repo = "freeDiameter";
    rev = "r1.5.0";
    hash = "sha256-dqdBy/kFZW9EvwX4zdwpb3ZGYcSjfH9FqvSHDaasdR4=";
  };

  postPatch = ''
    ln -s $freeDiameter subprojects/freeDiameter
  '';

  hardeningDisable = [
    "all"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-compound-token-split-by-macro"
    "-Wno-format"
  ];

  mesonFlags = [
    "-Dlocalstatedir=/var"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    bison
    flex
  ];

  buildInputs = [
    talloc
    libtins
    nghttp2
    curl
    libyaml
    libgcrypt
    libmicrohttpd
    libbson
    mongoc
    libidn
    openssl
    gnutls
    lksctp-tools
  ];

  postInstall = ''
    for file in configs/systemd/*.service; do
      substituteInPlace $file --replace /bin/kill ${coreutils}/bin/kill
      install -Dm644 $file $out/lib/systemd/system/$(basename $file)
    done
  '';
}
