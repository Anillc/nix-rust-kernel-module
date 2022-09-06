{
  lib,
  stdenv,
  buildInputs,
  nativeBuildInputs,
  rust-linux,
  configfile,
}: {
  name ? "rust-for-linux",
  extraConfig ? "",
  src ? null,
  ...
}@args: let
  omitted = lib.filterAttrs (name: _: !builtins.elem name [ "name" "extraConfig" ]) args;
in stdenv.mkDerivation {
  inherit buildInputs nativeBuildInputs name;
  src = rust-linux;
  buildPhase = ''
    patchShebangs ./scripts/check-local-export
    cp ${configfile.override { inherit extraConfig; }} .config
    ${if src == null then "" else ''
      cp -rf ${src}/. .
    ''}
    make LLVM=1 -j16
  '';
  installPhase = ''
    mkdir -p $out
    export INSTALL_MOD_PATH=$out
    make LLVM=1 modules_install
    rm -rf $out/lib/modules/${rust-linux.version}/{build,source}
  '';
} // omitted