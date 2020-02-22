{ channel, pname, version, sha256Hash }:

{ bash, buildFHSUserEnv, cacert, coreutils, git, makeWrapper, runCommand, stdenv
, fetchurl }:

let
  drvName = "flutter-${channel}-${version}";
  flutter = stdenv.mkDerivation {
    name = "${drvName}-unwrapped";

    src = fetchurl {
      url =
        "https://storage.googleapis.com/flutter_infra/releases/${channel}/linux/flutter_linux_v${version}-${channel}.tar.xz";
      sha256 = sha256Hash;
    };

    buildInputs = [ makeWrapper git ];

    patches = [ ./disable-auto-update.patch ];

    postPatch = ''
      patchShebangs --build ./bin/
      find ./bin/ -executable -type f -exec patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) {} \;
    '';

    buildPhase = ''
      HOME="$PWD"

      FLUTTER_ROOT=$(pwd)
      FLUTTER_TOOLS_DIR="$FLUTTER_ROOT/packages/flutter_tools"
      SNAPSHOT_PATH="$FLUTTER_ROOT/bin/cache/flutter_tools.snapshot"
      STAMP_PATH="$FLUTTER_ROOT/bin/cache/flutter_tools.stamp"
      SCRIPT_PATH="$FLUTTER_TOOLS_DIR/bin/flutter_tools.dart"
      DART_SDK_PATH="$FLUTTER_ROOT/bin/cache/dart-sdk"

      DART="$DART_SDK_PATH/bin/dart"
      PUB="$DART_SDK_PATH/bin/pub"

      (cd $FLUTTER_TOOLS_DIR && $PUB upgrade --offline)

      local revision="$(cd "$FLUTTER_ROOT"; git rev-parse HEAD)"
      "$DART" --snapshot="$SNAPSHOT_PATH" --packages="$FLUTTER_TOOLS_DIR/.packages" "$SCRIPT_PATH"
      echo "$revision" > "$STAMP_PATH"

      mkdir -p $PWD/.cache
      ./bin/flutter --version # required to avoid launch error
      rm -rf $PWD/.cache
      rm .flutter
      rm .flutter_tool_state

      echo "${version}" >> version
      rm -rf ./.pub-cache
    '';

    installPhase = ''
      mkdir -p $out
      cp -r . $out

      wrapProgram $out/bin/flutter --set-default PUB_CACHE '$HOME/.cache/pub' \
                                   --add-flags "--no-version-check"
    '';
  };

  # Wrap flutter inside an fhs user env to allow execution of binary,
  # like adb from $ANDROID_HOME or java from android-studio.
  fhsEnv = buildFHSUserEnv {
    name = "${drvName}-fhs-env";
    multiPkgs = pkgs:
      [
        # Flutter only use these certificates
        (runCommand "fedoracert" { } ''
          mkdir -p $out/etc/pki/tls/
          ln -s ${cacert}/etc/ssl/certs $out/etc/pki/tls/certs
        '')
      ];
  };

in runCommand drvName {
  startScript = ''
    #!${bash}/bin/bash
    ${fhsEnv}/bin/${drvName}-fhs-env ${flutter}/bin/flutter "$@"
  '';
  preferLocalBuild = true;
  allowSubstitutes = false;
  passthru = { unwrapped = flutter; };
  meta = with stdenv.lib; {
    description =
      "Flutter is Google's SDK for building mobile, web and desktop with Dart.";
    longDescription = ''
      Flutter is Google’s UI toolkit for building beautiful,
      natively compiled applications for mobile, web, and desktop from a single codebase.
    '';
    homepage = "https://flutter.dev";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ babariviere ];
  };
} ''
  mkdir -p $out/bin

  echo -n "$startScript" > $out/bin/${pname}
  chmod +x $out/bin/${pname}
''
