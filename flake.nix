{
  description = "Builds the Hugs98 Interpreter";

  inputs.nixpkgs.url = "nixpkgs/release-22.05";

  nixConfig = {
    bash-prompt-prefix = "hugs >";
  };

  outputs = { self, nixpkgs }:     
    let 
      system = "x86_64-darwin";
      inherit (nixpkgs) lib;
      inherit (nixpkgs.legacyPackages.${system}) mkShell stdenv;
      inherit (nixpkgs.legacyPackages.${system}.darwin) Libsystem;

      hugsPkg = stdenv.mkDerivation {
        pname = "hugs98";
        version = "2006-09";

        patches = [ ./sources.patch ];

        src = ./pristine/hugs98-plus-Sep2006.tar.gz;

        nativeBuildInputs = [ ];

        configureFlags = [
        ];

        # Set hugsdir so interpreter always finds default
        # packages.
        preConfigure = ''
          export hugsdir=$out/hugsdir;
        '';

        meta = with lib; {
          homepage = "https://www.haskell.org/hugs";
          description = "Haskell interpreter";
          license = licenses.bsd3;
          platforms = platforms.all;
        };

      };
    in    
    {
      packages.x86_64-darwin.default = hugsPkg;
      devShell.x86_64-darwin = mkShell {
        inherit (hugsPkg) preConfigure ;
        packages = [];
        inputsFrom = [hugsPkg];
      };
    };
}
