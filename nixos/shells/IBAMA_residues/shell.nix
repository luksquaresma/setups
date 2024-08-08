let 
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = false;
    };
  };
in
let
  python =    pkgs.python311;
  pp = pkgs.python311Packages;
in
pkgs.mkShell {
  name = "ibama_residues";
  venvDir = "./.venv";
  enableParallelBuilding = true;
  
  buildInputs = (
    [ python ]
    ++ (
      with pp; [
        boto3
        fastparquet
        jupyter
        notebook
        numpy
        pandas
        requests
        tqdm
      ]
    )
  );

  shellHook = ''
    nohup code . >/dev/null 2>&1
  '';

  postShellHook = ''
    export PYTHONPATH=$(which python)
  '';
    # source .venv/bin/activate
    #   ++ 
}
