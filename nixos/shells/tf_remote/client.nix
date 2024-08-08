let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = false;
    };
  };
in
pkgs.mkShell {
  name = "tf_remote_client";
  venvDir = "./.venv";
  enableParallelBuilding = true;

buildInputs = with pkgs; [
    pdm
    python3Full
  ];
}
