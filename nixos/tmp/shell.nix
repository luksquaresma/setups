let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;  # If you need CUDA
    };
  };
in
pkgs.mkShell {
  name = "TensorFlow-Shell";
  venvDir = "./.venv";
  
  buildInputs = with pkgs; [
    python3Packages.tensorflow[and-cuda]
  ];
}
