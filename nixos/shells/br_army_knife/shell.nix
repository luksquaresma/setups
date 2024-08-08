let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = false;
    };
  };
in
pkgs.mkShell {
  name = "BAKTestEnv";
  venvDir = "./.venv";
  
  buildInputs = with pkgs; [
    python3Packages.pip
    python3Packages.build
    python3Packages.twine
    python3Packages.setuptools
  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -r requirements.txt
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';
}
