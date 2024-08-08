let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;  # If you need CUDA
    };
  };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python311Packages.jupyter
    python311Packages.notebook
    python311Packages.nbformat
    python311Packages.pandas
    python311Packages.plotly
    python311Packages.scikit-learn
    python311Packages.tabulate
    python311Packages.matplotlib
    python3Packages.tensorflow
  ];
}

