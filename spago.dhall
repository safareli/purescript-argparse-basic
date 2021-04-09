{ name = "argparse-basic"
, dependencies =
  [ "arrays"
  , "console"
  , "debug"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "free"
  , "lists"
  , "maybe"
  , "node-process"
  , "psci-support"
  , "record"
  , "strings"
  , "transformers"
  , "bifunctors"
  , "control"
  , "integers"
  , "newtype"
  , "numbers"
  , "prelude"
  , "tuples"
  , "unfoldable"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
