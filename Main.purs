module Main where

import Prelude

import ArgParse.Basic (ArgError, ArgParser)
import ArgParse.Basic as A
import Data.Either (Either, either)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Console (log)

data GitCommand
  = Version
  | Build
  | Tag
  | Commit {message :: String, body :: String, amend:: Boolean}
  | Stash StashSubCommand


derive instance genericGitCommand :: Generic GitCommand _
instance showGitCommand :: Show GitCommand where show = genericShow

data StashSubCommand
  = StashDefault {message :: String}
  | StashPop

derive instance genericStashSubCommand :: Generic StashSubCommand _
instance showStashSubCommand :: Show StashSubCommand where show = genericShow

parseStashSubCommand :: A.ArgParser StashSubCommand
parseStashSubCommand = A.flagHelp *> (A.choose "stash" 
  [ A.command ["push"] "push to stash" do
      StashDefault <$> A.fromRecord { message : A.argument ["--message","-m"] "Stash message" } 
    , A.command ["pop"] "Pop from stash" (pure StashPop)
  ]) # (A.default (StashDefault {message: ""}))


gitCommand :: ArgParser GitCommand
gitCommand = 
  A.flagInfo [ "--version", "-v" ] "show version" "0.0.1" *>
  A.flagHelp *>
  (A.choose "<command>" 
    [ A.command ["stash"] "stash changes" do
        Stash <$> parseStashSubCommand,
      A.command ["commit"] "commit changes" do
        Commit <$> (A.fromRecord {
            amend: A.flag ["-a", "--amend"] "a amend" # A.boolean,
            body: A.argument ["-b", "--body"] "a body",
            message: A.argument ["-m", "--message"] "a message"
          })
    ])

git :: Array String -> Either ArgError GitCommand
git i = A.parseArgs "git" "This is my git CLI example." gitCommand (i <> [])

debug :: Array String -> Effect Unit
debug = git >>> either (A.printArgError >>> log) (show >>> log)


main :: Effect Unit
main = do
  debug []
  {-
  git
      Expected <command>.

      This is my git CLI example.

      --help,-h       Show this help message.
      --version,-v    show version
      
      commit          commit changes
      stash           stash changes
  -}
  log "_____"
  debug ["commit", "-b=body", "-m=asd", "--amend"]
  -- (Commit { amend: true, body: "body", message: "asd" })
  log "_____"
  debug ["stash"]
  -- (Stash (StashDefault { message: "" }))
  log "_____"
  debug ["stash", "pop"]
  -- (Stash StashPop)
  log "_____"
  debug ["stash", "--help"]
  {-
  git stash
      stash changes

      --help,-h    Show this help message.
      
      pop          Pop from stash
      push         push to stash
  -}
  log "_____"
  debug ["commit", "--help"]
  {-
  git commit
      Unexpected argument:
          --help

      commit changes

      -a,--amend      a amend
      -b,--body       a body
      -m,--message    a message
  -}
  log "_____"
  debug ["stash", "push", "-m=bla"]
  -- (Stash (StashDefault { message: "bla" }))