{ callPackage }:

let mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
in {
  stable = mkFlutter {
    pname = "flutter";
    channel = "stable";
    version = "1.12.13+hotfix.5";
    sha256Hash = "006qcrc64w7yaqzhfm1c5kbivj44zv18pkcw39ga6gb2jllck4np";
  };
  beta = mkFlutter {
    pname = "flutter-beta";
    channel = "beta";
    version = "1.12.13+hotfix.6";
    sha256Hash = "0y29dfqpq3yrz0lkw4by7s0mzplc8mlz0k8bs8zrc72d4c85a4ga";
  };
  dev = mkFlutter {
    pname = "flutter-dev";
    channel = "dev";
    version = "1.13.5";
    sha256Hash = "11dl8js7cnddl39gicjx937a0vzmrmfd7ja0ir20hks19xwvigm5";
  };
}
