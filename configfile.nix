{
  buildLinux,
  nativeBuildInputs,
  buildInputs,
  rust-linux,
  extraConfig ? "",
}:

(buildLinux {
  src = rust-linux;
  version = rust-linux.version;
  defconfig = "allnoconfig";
  kernelPatches = [];
  extraMakeFlags = [ "LLVM=1" ];
}).configfile.overrideAttrs (old: {
  inherit buildInputs;
  nativeBuildInputs = old.nativeBuildInputs ++ nativeBuildInputs;
  kernelConfig = ''
    64BIT y
    MODULES y
    RUST y
  '' + extraConfig;
})