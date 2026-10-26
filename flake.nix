{
  description = "Linux driver for the Elgato Game Capture HD60 S";

  # No inputs: the module builds against the kernel and nixpkgs of the
  # system that imports it.
  outputs =
    { self }:
    {
      nixosModules.default =
        { config, lib, ... }:
        {
          boot.extraModulePackages = [
            (config.boot.kernelPackages.callPackage (
              {
                stdenv,
                kernel,
                kernelModuleMakeFlags,
              }:
              stdenv.mkDerivation {
                pname = "hd60s";
                version = "0-unstable-${self.shortRev or self.dirtyShortRev or "unknown"}";

                src = self;

                nativeBuildInputs = kernel.moduleBuildDependencies;
                makeFlags = kernelModuleMakeFlags ++ [
                  "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
                ];

                # The Makefile's own install target runs `depmod -a` on the
                # host; NixOS runs depmod itself over all extraModulePackages.
                installPhase = ''
                  runHook preInstall
                  make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
                    M=$PWD INSTALL_MOD_PATH=$out modules_install
                  runHook postInstall
                '';

                meta = {
                  description = "V4L2/ALSA driver for the Elgato Game Capture HD60 S";
                  homepage = "https://github.com/Trikzon/hd60s-linux-driver";
                  license = lib.licenses.gpl2Only;
                  platforms = lib.platforms.linux;
                };
              }
            ) { })
          ];
        };
    };
}
