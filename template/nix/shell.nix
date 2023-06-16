# Your development shell is defined here.
# A development shell is available for each compiler defined in iogx-config.nix.
# You can add packages, scripts, envvars, and a shell hook.

{
  # Desystemized merged inputs.
  # All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the 
  # inputs defined in your flake. You will also find the `self` attribute here.
  # These inputs have been desystemized against the current system.
  inputs

  # Non-desystemized merged inputs.
  # All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the 
  # inputs defined in your flake. You will also find the `self` argument here. 
  # These inputs have not been desystemized, they are the original `inputs` from
  # iogx and your `flake.nix`.
, inputs'

  # Desystemized legacy nix packages configured against `haskell.nix`.
  # NEVER use the `nixpkgs` coming from `inputs` or `systemized-inputs`!
, pkgs

  # A reference to the `haskell.nix` project on top of which this shell will be 
  # built. This can be used for example to bring some haskell executables into 
  # the shell:
  # packages = [
  #   project.hsPkgs.cardano-cli.components.exes.cardano-cli
  #   project.hsPkgs.cardano-node.components.exes.cardano-node
  # ];
  # Be careful not to reference the project's own haskell packages.
, project
}:

{
  # Add any extra packages that you want in your shell here.
  packages = [
    # pkgs.hello 
    # pkgs.curl 
    # pkgs.sqlite3 
  ];

  # Add any script that you want in your shell here.
  # `scripts` is an attrset where each attribute name is the script name, and 
  # the attribute value is an attrset `{ exec, description, enabled, group }`.
  # `description` is optional will appear next to the script name.
  # `exec` is bash code to be executed when the script is run.
  # `group` is optional used to tag scripts together when printed.
  # `enabled` is optional, defaults to true if not set, and can be used to 
  # include scripts conditionally, for example:
  #   { enabled = pkgs.stdenv.system != "x86_64-darwin"; }
  scripts = {
    foobar = {
      exec = ''
        # Bash code to be executed whenever the script `foobar` is run.
        echo "Delete me from your shell-module.nix!"
      '';
      description = ''
        You might want to delete the foobar script.
      '';
      group = "group-name";
      enabled = true;
    };
  };

  # Add your environment variables here.
  # For each key-value pair the bash line:
  # `export NAME="VALUE"` 
  # will be appended to `enterShell`. 
  env = {
    NAME = VALUE;
  };

  enterShell = ''
    # Bash code to be executed when you enter the shell.
  '';
}
