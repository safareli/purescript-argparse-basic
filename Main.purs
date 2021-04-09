module Main where

import Prelude

import ArgParse.Basic (ArgError, ArgParser)
import ArgParse.Basic as A
import Data.Either (Either, either)
import Debug (spy)
import Effect (Effect)
import Effect.Console (log)

data GitCommand
  = Version
  | Build
  | Tag
  | Commit {message :: String, body :: String, amend:: Boolean}
  | Stash StashSubCommand

data StashSubCommand
  = StashDefault {message :: String}
  | StashPop


parseStashSubCommand :: A.ArgParser StashSubCommand
parseStashSubCommand = A.flagHelp *> (A.choose "stash" 
  [ A.command ["push"] "push to stash" do
      StashDefault <$> A.fromRecord { message : A.argument ["--message","-m"] "Stash message" } 
    -- , A.command ["pop"] "Pop from stash" (pure StashPop)
  ]) # (A.default (StashDefault {message: ""}))


git :: ArgParser GitCommand
git = 
  A.flagInfo [ "--version", "-v" ] "show version" "0.0.1" *>
  A.flagHelp *>
  (A.choose "git" 
    [ A.command ["stash"] "stash changes" do
        Stash <$> parseStashSubCommand,
      A.command ["commit"] "commit changes" do
        Commit <$> (A.fromRecord {
            amend: A.flag ["-a", "--amend"] "a amend" # A.boolean,
            body: A.argument ["-b", "--body"] "a body",
            message: A.argument ["-m", "--message"] "a message"
          })
    ])

y :: Array String -> Either ArgError GitCommand
y i = A.parseArgs "git" "This is my git CLI example." git (i <> [])

k :: Array String -> String
k = y >>> either A.printArgError (\x -> let _x = spy "res" x in "")


main :: Effect Unit
main = do
  log (k [""]) -- help msg as expected
  log "_____"
  log (k ["commit -b=body -m=asd --amend"]) --expected to parse but fails
  log "_____"
  log (k ["stash --help"]) -- expected to see help for subcommand but not shown
  log "_____"
  log (k ["stash push -m=bla"]) -- expected to parse but fails