let 
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };
in
let
  python =    pkgs.python311;
  pp = pkgs.python311Packages;
in
pkgs.mkShell {
  name = "TensorFlow GPU";
  enableParallelBuilding = true;
  
  buildInputs = (
    [ python ]
    ++ (
      with pp; [
        tensorflow
      ]
    )
  );

  postShellHook = ''
    export PYTHONPATH=$(which python)
  '';

}
