## scad workflow

A package has been provided that will watch the rust files for changes and call the generate command: `nix run .#watch`.

Now, open `default.scad` in an openscad instance: `openscad default.scad`.

When changes are made to the rust source files, the watch process will update the file and openscad will automatically update its preview.

