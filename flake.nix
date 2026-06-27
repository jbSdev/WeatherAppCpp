{

    description = "C++ flake for Crow, CURL, and nlohmann/json";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "cpp-crow-project";
                    packages = with pkgs; [
                        gcc
                        clang-tools
                        cmake
                        gnumake
                        pkg-config
                        gdb

                        crow
                        curl
                        nlohmann_json
                    ];

                    shellHook = ''
                        export CXXFLAGS="-std=c++11 $CXXFLAGS"
                        echo "C++ Crow project shell - $(gcc --version | head -1)"
                    '';
                };
            }
        );

}
