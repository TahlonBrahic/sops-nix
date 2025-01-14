{
  pkgs ? import <nixpkgs> {},
  vendorHash ? "sha256-rrfO2cExCf1hxsECWkHz92bLyp5rxYgOLNLJ6lpJkLo=",
}: let
  sops-install-secrets = pkgs.callPackage ./pkgs/sops-install-secrets {
    inherit vendorHash;
  };
in
  rec {
    inherit sops-install-secrets;
    sops-init-gpg-key = pkgs.callPackage ./pkgs/sops-init-gpg-key {};
    default = sops-init-gpg-key;

    sops-import-keys-hook = pkgs.callPackage ./pkgs/sops-import-keys-hook {};

    sops = pkgs.callPackage ./pkgs/sops {};

    age-fido2-hmac = pkgs.callPackage ./pkgs/age-fido2-hmac {};
    sops-fido2-hmac = pkgs.callPackage ./pkgs/sops-fido2-hmac {inherit sops;};

    # backwards compatibility
    inherit (pkgs) ssh-to-pgp;

    # used in the CI only
    sops-pgp-hook-test = pkgs.callPackage ./pkgs/sops-pgp-hook-test.nix {
      inherit vendorHash;
    };
    unit-tests = pkgs.callPackage ./pkgs/unit-tests.nix {};
  }
  // (pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
    lint = pkgs.callPackage ./pkgs/lint.nix {
      inherit sops-install-secrets;
    };

    cross-build = pkgs.callPackage ./pkgs/cross-build.nix {
      inherit sops-install-secrets;
    };
  })
