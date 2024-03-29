let

  ghcVersion = "ghc865";

  fetchGithubTarball = owner: repo: rev: args:
    import (builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    }) args;

  pkgs = fetchGithubTarball "NixOS" "nixpkgs" "002b853782e939c50da3fa7d424b08346f39eb6f" { inherit config; };
  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  all-hies = fetchGithubTarball "Infinisil" "all-hies" "9540f6aaeb9520abfc30729dc003836b790441a0" {};
  easy-ps = fetchGithubTarball "justinwoo" "easy-purescript-nix" "054caeb3cd4292920e21a4de92a9decbac8e8953" {};
  
  extra-deps = (super: {

  });

  localPackages = {
    backend = ./backend;
    migration = ./migration;
  };

  config = {
    allowUnfree = true;
    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskell.packages."${ghcVersion}".override {
        overrides = self: super: (extra-deps super) // builtins.mapAttrs (name: path: super.callCabal2nix name (gitignore path) {}) localPackages;
      };
    };
  };  

  shell = pkgs.haskellPackages.shellFor {
    packages = p: builtins.attrValues (builtins.mapAttrs (name: path: builtins.getAttr name pkgs.haskellPackages) localPackages);
    buildInputs = with pkgs; with haskellPackages; with easy-ps; [

      (writeScriptBin "watch" ''
        yarn --cwd "$(pwd)/frontend" run concurrently 'spago bundle-app -w' 'node browsersync.js' 'cd $(pwd)/../backend && ghcid --command="cabal v1-repl" --test=:main -W'
      '')

      #frontend
      nodejs_latest
      purs
      spago
      
      # backend
      all-hies.versions.${ghcVersion}
      cabal-install
      haskell.compiler.${ghcVersion}
      ghcid

      # misc.
      yarn
    ];
  };
in
{
  nixpkgs = pkgs;
  shell = shell;
}
