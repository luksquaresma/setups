let
  pkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = false;
    };
  };
in
pkgs.mkShell {
  name = "nemli";
  venvDir = "./.venv";
  enableParallelBuilding = true;
  
  buildInputs = with pkgs; [
    pdm
    python311Full
  ];

  shellHook = ''
    nohup code . >/dev/null 2>&1
    export NEMLI_DISCORD_TOKEN=xxx
    export NEMLI_OPENAI_API_KEY=yyy
    source .venv/bin/activate
  '';
}
