{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
	pkgs.imagemagick
	#pkgs.openscad
	pkgs.python3
	pkgs.python3Packages.colorama
	pkgs.python3Packages.markdown
	pkgs.codespell
  ];

shellHook = ''
	alias make_all.py=~/.local/share/OpenSCAD/libraries/NopSCADlib/scripts/make_all.py	
'';


}
