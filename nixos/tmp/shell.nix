let 
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };
in
let
  python = pkgs.python311;
  pp =     pkgs.python311Packages;
in
pkgs.mkShell {
  name = "TensorFlow GPU";
  enableParallelBuilding = true;
  
  buildInputs = (
    [ 
      python
    ]
    ++ (
      with pp; [
        tensorflow
      ]
    )
  );
 shellHook = ''
   echo; python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
 '';


#    echo; echo "PYTHONPATH: "; echo $PYTHONPATH;
#    echo; echo "which python: "; echo $(which python);
#    echo; python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
#
#
#    export PYTHONPATH=$(which python);
#    echo "transform";
#
#    echo; echo "PYTHONPATH: "; echo $PYTHONPATH;
#    echo; echo "which python: "; echo $(which python);
#    echo; python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
}
