{
  lib,
  stdenv,
  buildInputs,
  nativeBuildInputs,
  rust-linux,
  configfile,
}: {
  name ? "rust-for-linux",
  modulePath ? ".",
  extraConfig ? "",
  src ? null,
  ...
}@args: let
  omitted = lib.filterAttrs (name: _: !builtins.elem name [ "name" "extraConfig" ]) args;
  prepare = stdenv.mkDerivation {
    inherit buildInputs nativeBuildInputs;
    name = "modules-parepare";
    src = rust-linux;
    fixupPhase = ":";
    buildPhase = ''
      patchShebangs ./scripts/check-local-export
      cp ${configfile} .config
      make -j16 LLVM=1
    '';
    installPhase = ''
      mkdir -p $out
      cp -r ./. $out
    '';
  };
in stdenv.mkDerivation ({
  inherit buildInputs nativeBuildInputs name;
  src = prepare;
  fixupPhase = ":";
  buildPhase = ''
    mkdir -p ${modulePath}
    cp ${configfile.override { inherit extraConfig; }} .config
    ${if src == null then "" else ''
      cp -rf ${src}/. ${modulePath}
    ''}
    make -j16 LLVM=1 modules_prepare
    ${if modulePath == "." then ''
      make -j16 LLVM=1 modules
    '' else ''
      make -j16 LLVM=1 M=${modulePath}
    ''}
  '';
} // omitted)