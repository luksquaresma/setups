let
  # path for the utils script
  bash_utils_path = "./../utils.sh";
  
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = false;
    };
  };
in
pkgs.mkShell {
  name = "tf_remote";
  enableParallelBuilding = true;

  buildInputs = with pkgs; [
    docker
    docker-compose
    pdm
    python3Full
    rustc
    sqlite
  ];

  # # Run this command, only after creating the virtual environment
  # postVenvCreation = ''
  #   unset SOURCE_DATE_EPOCH
  #   pip install -r requirements.txt
  # '';

  # # Now we can execute any commands within the virtual environment.
  # # This is optional and can be left out to run pip manually.
  # postShellHook = ''
  #   # allow pip to install wheels
  #   unset SOURCE_DATE_EPOCH
  # '';
  
  shellHook = ''
    {
      {
        echo
        echo "========================="
        echo "...Starting enviroment..."
        echo "========================="
      } && {
        eval $(bash ${bash_utils_path} -r)
      } && {
        {
          eval $(bash ${bash_utils_path} -e)
        } || {
          eval $(bash ${bash_utils_path} -f ${bash_utils_path})
        }
      } && {
        eval $(bash ${bash_utils_path} -u)
      } && {
        bash <(bash ${bash_utils_path} -s)
      } && {
        echo "======================"
        echo "OK - Enviroment built!"; echo; echo;
      }
    } || {
      echo
      echo "=================================="
      echo "ABORT - Failed to bild enviroment!"
      echo "ABORT - Exiting now!"; echo; echo;
      exit
    }
  '';	
  # bash ./db/reset_db.sh
  # docker run hello-world 
}
