{ callPackage }:

let mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
in mkFlutter {
  pname = "flutter";
  channel = "stable";
  version = "1.12.13+hotfix.5";
  sha256Hash = "006qcrc64w7yaqzhfm1c5kbivj44zv18pkcw39ga6gb2jllck4np";
}
