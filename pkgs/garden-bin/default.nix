{
  stdenv,
  fetchurl,
  lib,
  nix-update-script,

}:

stdenv.mkDerivation rec {
  name = "garden-bin";
  version = "0.14.7";
  src = fetchurl {
    url = "https://github.com/garden-io/garden/releases/download/${version}/garden-${version}-linux-amd64.tar.gz";
    sha256 = "113cach2srja2x6gqxv8jcn57jxsdzwwjmhzn0nhcavl95m715p5";
  };
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  installPhase = ''
    mkdir -p $out/bin
    cp linux-amd64/garden $out/bin/
    chmod +x $out/bin/garden
  '';

  meta = with lib; {
    description = "Garden Automation for Kubernetes development and testing.";
    homepage = "https://github.com/garden-io/garden";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}
