{
  description = "Builds the Hugs98 Interpreter";

  inputs.nixpkgs.url = "nixpkgs/release-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  nixConfig = {
    bash-prompt-prefix = "hugs >";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [ flake-utils.lib.system.x86_64-darwin ];
    in
      flake-utils.lib.eachSystem systems (system: 
        let 
          inherit (nixpkgs.legacyPackages.${system}) mkShell stdenv gcc makeWrapper;

          hugsPkg = stdenv.mkDerivation {
            pname = "hugs98";
            version = "2006-09";

            patches = [ ./patches/sources.patch ];

            src = ./pristine/hugs98-plus-Sep2006.tar.gz;

            nativeBuildInputs = [ gcc makeWrapper ];

            # Set hugsdir so interpreter always finds default
            # packages.
            preConfigure = ''
              export hugsdir=$out/hugsdir;
            '';

            postFixup = ''
              wrapProgram $out/bin/cpphs-hugs --set PATH $out/bin
              wrapProgram $out/bin/hsc2hs-hugs --set PATH $out/bin:${gcc}/bin
            '';

            meta = {
              homepage = "https://www.haskell.org/hugs";
              description = "Haskell interpreter";
            };
          };
        in    
          {
            packages.default = hugsPkg;
            apps = rec {
              default = runhugs;
              hugs = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/hugs";
              };
              runhugs = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/runhugs";
              };
              ffihugs = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/ffihugs";
              };
              cpphs-hugs = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/cpphs-hugs";
              };
              hsc2hs-hugs = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/hsc2hs-hugs";
              };
            };
            devShell = mkShell {
              inherit (hugsPkg) preConfigure ;
              packages = [];
              inputsFrom = [hugsPkg];
            };
          }
        );
}
