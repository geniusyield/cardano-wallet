{
  pkgs = hackage:
    {
      packages = {
        "tf-random".revision = (((hackage."tf-random")."0.5").revisions).default;
        "csv".revision = (((hackage."csv")."0.1.2").revisions).default;
        "terminal-progress-bar".revision = (((hackage."terminal-progress-bar")."0.4.1").revisions).default;
        "ghc-boot-th".revision = (((hackage."ghc-boot-th")."8.10.7").revisions).default;
        "call-stack".revision = (((hackage."call-stack")."0.4.0").revisions).default;
        "ghc-prim".revision = (((hackage."ghc-prim")."0.6.1").revisions).default;
        "pretty".revision = (((hackage."pretty")."1.1.3.6").revisions).default;
        "integer-logarithms".revision = (((hackage."integer-logarithms")."1.0.3.1").revisions).default;
        "integer-logarithms".flags.check-bounds = false;
        "integer-logarithms".flags.integer-gmp = true;
        "HUnit".revision = (((hackage."HUnit")."1.6.2.0").revisions).default;
        "regex-tdfa".revision = (((hackage."regex-tdfa")."1.3.1.1").revisions).default;
        "regex-tdfa".flags.force-o2 = false;
        "text".revision = (((hackage."text")."1.2.4.1").revisions).default;
        "base".revision = (((hackage."base")."4.14.3.0").revisions).default;
        "time".revision = (((hackage."time")."1.9.3").revisions).default;
        "random".revision = (((hackage."random")."1.2.1").revisions).default;
        "dlist".revision = (((hackage."dlist")."1.0").revisions).default;
        "dlist".flags.werror = false;
        "megaparsec".revision = (((hackage."megaparsec")."9.0.1").revisions).default;
        "megaparsec".flags.dev = false;
        "array".revision = (((hackage."array")."0.5.4.0").revisions).default;
        "process".revision = (((hackage."process")."1.6.13.2").revisions).default;
        "parser-combinators".revision = (((hackage."parser-combinators")."1.3.0").revisions).default;
        "parser-combinators".flags.dev = false;
        "regex-base".revision = (((hackage."regex-base")."0.94.0.2").revisions).default;
        "hsc2hs".revision = (((hackage."hsc2hs")."0.68.8").revisions).default;
        "hsc2hs".flags.in-ghc-tree = false;
        "hspec-core".revision = (((hackage."hspec-core")."2.8.5").revisions).default;
        "base-orphans".revision = (((hackage."base-orphans")."0.8.6").revisions).default;
        "setenv".revision = (((hackage."setenv")."0.1.1.3").revisions).default;
        "hspec".revision = (((hackage."hspec")."2.8.5").revisions).default;
        "primitive".revision = (((hackage."primitive")."0.7.3.0").revisions).default;
        "directory".revision = (((hackage."directory")."1.3.6.0").revisions).default;
        "clock".revision = (((hackage."clock")."0.8.2").revisions).default;
        "clock".flags.llvm = false;
        "quickcheck-io".revision = (((hackage."quickcheck-io")."0.2.0").revisions).default;
        "optparse-applicative".revision = (((hackage."optparse-applicative")."0.16.1.0").revisions).default;
        "optparse-applicative".flags.process = true;
        "hspec-expectations".revision = (((hackage."hspec-expectations")."0.8.2").revisions).default;
        "mtl".revision = (((hackage."mtl")."2.2.2").revisions).default;
        "transformers".revision = (((hackage."transformers")."0.5.6.2").revisions).default;
        "rts".revision = (((hackage."rts")."1.0.1").revisions).default;
        "parsec".revision = (((hackage."parsec")."3.1.14.0").revisions).default;
        "hspec-discover".revision = (((hackage."hspec-discover")."2.8.5").revisions).default;
        "template-haskell".revision = (((hackage."template-haskell")."2.16.0.0").revisions).default;
        "bytestring".revision = (((hackage."bytestring")."0.10.12.0").revisions).default;
        "deepseq".revision = (((hackage."deepseq")."1.4.4.0").revisions).default;
        "splitmix".revision = (((hackage."splitmix")."0.1.0.4").revisions).default;
        "splitmix".flags.optimised-mixer = false;
        "unix".revision = (((hackage."unix")."2.7.2.2").revisions).default;
        "filemanip".revision = (((hackage."filemanip")."0.3.6.3").revisions).default;
        "filepath".revision = (((hackage."filepath")."1.4.2.1").revisions).default;
        "ansi-terminal".revision = (((hackage."ansi-terminal")."0.11.1").revisions).default;
        "ansi-terminal".flags.example = false;
        "terminal-size".revision = (((hackage."terminal-size")."0.3.2.1").revisions).default;
        "stm".revision = (((hackage."stm")."2.5.0.1").revisions).default;
        "integer-gmp".revision = (((hackage."integer-gmp")."1.0.3.0").revisions).default;
        "hashable".revision = (((hackage."hashable")."1.4.0.1").revisions).default;
        "hashable".flags.integer-gmp = true;
        "hashable".flags.containers = true;
        "hashable".flags.random-initial-seed = false;
        "transformers-compat".revision = (((hackage."transformers-compat")."0.7.1").revisions).default;
        "transformers-compat".flags.two = false;
        "transformers-compat".flags.mtl = true;
        "transformers-compat".flags.five-three = true;
        "transformers-compat".flags.three = false;
        "transformers-compat".flags.four = false;
        "transformers-compat".flags.five = false;
        "transformers-compat".flags.generic-deriving = true;
        "semigroups".revision = (((hackage."semigroups")."0.19.2").revisions).default;
        "semigroups".flags.bytestring = true;
        "semigroups".flags.deepseq = true;
        "semigroups".flags.template-haskell = true;
        "semigroups".flags.binary = true;
        "semigroups".flags.bytestring-builder = false;
        "semigroups".flags.tagged = true;
        "semigroups".flags.containers = true;
        "semigroups".flags.transformers = true;
        "semigroups".flags.unordered-containers = true;
        "semigroups".flags.text = true;
        "semigroups".flags.hashable = true;
        "ansi-wl-pprint".revision = (((hackage."ansi-wl-pprint")."0.6.9").revisions).default;
        "ansi-wl-pprint".flags.example = false;
        "scientific".revision = (((hackage."scientific")."0.3.7.0").revisions).default;
        "scientific".flags.bytestring-builder = false;
        "scientific".flags.integer-simple = false;
        "binary".revision = (((hackage."binary")."0.8.8.0").revisions).default;
        "QuickCheck".revision = (((hackage."QuickCheck")."2.14.2").revisions).default;
        "QuickCheck".flags.old-random = false;
        "QuickCheck".flags.templatehaskell = true;
        "containers".revision = (((hackage."containers")."0.6.5.1").revisions).default;
        "natural-sort".revision = (((hackage."natural-sort")."0.1.2").revisions).default;
        "unix-compat".revision = (((hackage."unix-compat")."0.5.3").revisions).default;
        "unix-compat".flags.old-time = false;
        "case-insensitive".revision = (((hackage."case-insensitive")."1.2.1.0").revisions).default;
        "colour".revision = (((hackage."colour")."2.3.6").revisions).default;
        };
      compiler = {
        version = "8.10.7";
        nix-name = "ghc8107";
        packages = {
          "ghc-boot-th" = "8.10.7";
          "ghc-prim" = "0.6.1";
          "pretty" = "1.1.3.6";
          "text" = "1.2.4.1";
          "base" = "4.14.3.0";
          "time" = "1.9.3";
          "array" = "0.5.4.0";
          "process" = "1.6.13.2";
          "directory" = "1.3.6.0";
          "mtl" = "2.2.2";
          "transformers" = "0.5.6.2";
          "rts" = "1.0.1";
          "parsec" = "3.1.14.0";
          "template-haskell" = "2.16.0.0";
          "bytestring" = "0.10.12.0";
          "deepseq" = "1.4.4.0";
          "unix" = "2.7.2.2";
          "filepath" = "1.4.2.1";
          "stm" = "2.5.0.1";
          "integer-gmp" = "1.0.3.0";
          "binary" = "0.8.8.0";
          "containers" = "0.6.5.1";
          };
        };
      };
  extras = hackage:
    { packages = { lentil = ./.plan.nix/lentil.nix; }; };
  modules = [
    ({ lib, ... }:
      {
        packages = {
          "lentil" = { flags = { "developer" = lib.mkOverride 900 false; }; };
          };
        })
    ({ lib, ... }:
      {
        packages = {
          "terminal-size".components.library.planned = lib.mkOverride 900 true;
          "base-orphans".components.library.planned = lib.mkOverride 900 true;
          "setenv".components.library.planned = lib.mkOverride 900 true;
          "hspec-core".components.library.planned = lib.mkOverride 900 true;
          "ansi-terminal".components.library.planned = lib.mkOverride 900 true;
          "megaparsec".components.library.planned = lib.mkOverride 900 true;
          "lentil".components.exes."lentil".planned = lib.mkOverride 900 true;
          "filepath".components.library.planned = lib.mkOverride 900 true;
          "hspec".components.library.planned = lib.mkOverride 900 true;
          "pretty".components.library.planned = lib.mkOverride 900 true;
          "process".components.library.planned = lib.mkOverride 900 true;
          "hspec-discover".components.library.planned = lib.mkOverride 900 true;
          "tf-random".components.library.planned = lib.mkOverride 900 true;
          "bytestring".components.library.planned = lib.mkOverride 900 true;
          "clock".components.library.planned = lib.mkOverride 900 true;
          "template-haskell".components.library.planned = lib.mkOverride 900 true;
          "stm".components.library.planned = lib.mkOverride 900 true;
          "quickcheck-io".components.library.planned = lib.mkOverride 900 true;
          "call-stack".components.library.planned = lib.mkOverride 900 true;
          "dlist".components.library.planned = lib.mkOverride 900 true;
          "ghc-prim".components.library.planned = lib.mkOverride 900 true;
          "HUnit".components.library.planned = lib.mkOverride 900 true;
          "lentil".components.tests."test".planned = lib.mkOverride 900 true;
          "filemanip".components.library.planned = lib.mkOverride 900 true;
          "array".components.library.planned = lib.mkOverride 900 true;
          "scientific".components.library.planned = lib.mkOverride 900 true;
          "binary".components.library.planned = lib.mkOverride 900 true;
          "csv".components.library.planned = lib.mkOverride 900 true;
          "QuickCheck".components.library.planned = lib.mkOverride 900 true;
          "ghc-boot-th".components.library.planned = lib.mkOverride 900 true;
          "ansi-wl-pprint".components.library.planned = lib.mkOverride 900 true;
          "hspec-discover".components.exes."hspec-discover".planned = lib.mkOverride 900 true;
          "splitmix".components.library.planned = lib.mkOverride 900 true;
          "mtl".components.library.planned = lib.mkOverride 900 true;
          "rts".components.library.planned = lib.mkOverride 900 true;
          "unix".components.library.planned = lib.mkOverride 900 true;
          "hsc2hs".components.exes."hsc2hs".planned = lib.mkOverride 900 true;
          "parser-combinators".components.library.planned = lib.mkOverride 900 true;
          "regex-base".components.library.planned = lib.mkOverride 900 true;
          "transformers".components.library.planned = lib.mkOverride 900 true;
          "parsec".components.library.planned = lib.mkOverride 900 true;
          "deepseq".components.library.planned = lib.mkOverride 900 true;
          "directory".components.library.planned = lib.mkOverride 900 true;
          "primitive".components.library.planned = lib.mkOverride 900 true;
          "regex-tdfa".components.library.planned = lib.mkOverride 900 true;
          "random".components.library.planned = lib.mkOverride 900 true;
          "text".components.library.planned = lib.mkOverride 900 true;
          "terminal-progress-bar".components.library.planned = lib.mkOverride 900 true;
          "base".components.library.planned = lib.mkOverride 900 true;
          "time".components.library.planned = lib.mkOverride 900 true;
          "integer-logarithms".components.library.planned = lib.mkOverride 900 true;
          "transformers-compat".components.library.planned = lib.mkOverride 900 true;
          "integer-gmp".components.library.planned = lib.mkOverride 900 true;
          "natural-sort".components.library.planned = lib.mkOverride 900 true;
          "case-insensitive".components.library.planned = lib.mkOverride 900 true;
          "colour".components.library.planned = lib.mkOverride 900 true;
          "containers".components.library.planned = lib.mkOverride 900 true;
          "hspec-expectations".components.library.planned = lib.mkOverride 900 true;
          "optparse-applicative".components.library.planned = lib.mkOverride 900 true;
          "unix-compat".components.library.planned = lib.mkOverride 900 true;
          "hashable".components.library.planned = lib.mkOverride 900 true;
          "semigroups".components.library.planned = lib.mkOverride 900 true;
          };
        })
    ];
  }