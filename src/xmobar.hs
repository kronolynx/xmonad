{-# LANGUAGE PostfixOperators #-}

import           System.Environment        (getEnv)
import           System.IO.Unsafe          (unsafeDupablePerformIO)
import qualified Theme.Theme           as TH
import           XMonad.Hooks.StatusBar.PP (wrap, xmobarAction, xmobarColor,
                                            xmobarFont)
import Xmobar
    ( xmobar,
      defaultConfig,
      Command(Com),
      CommandReader(CommandReader),
      Date(Date),
      Monitors(Memory, Cpu),
      XMonadLog(UnsafeXMonadLog),
      Runnable(..),
      XPosition(Static, xpos, ypos, width, height),
      Border(FullB),
      Config(font, additionalFonts, textOffset, textOffsets, bgColor,
             fgColor, borderColor, border, position, alpha, lowerOnStart,
             hideOnStart, persistent, overrideRedirect, iconOffset, commands,
             sepChar, alignSep, template) )

-- | Configures how things should be displayed on the bar
config :: Config
config =
  defaultConfig
    { font =
        concatMap
          fontWrap
          [
            TH.myFont
          , "Noto Sans:size=10:style=Bold"
          , "Noto Sans CJK SC:size=10:style=Bold"
          , "Noto Sans CJK JP:size=10:style=Bold"
          , "Noto Sans CJK KR:size=10:style=Bold"
          ]
    , additionalFonts =
        [
          "xft:Font Awesome 5 Free Solid:size=10"
        , "xft:Font Awesome 5 Brands:size=11"
        , "xft:file\\-icons:size=11"
        , "xft:JetBrainsMono Nerd Font:size=14"
        , "xft:JetBrainsMono Nerd Font:size=10"
        ]
    , textOffset = 20
    , textOffsets = [20, 21, 20, 21, 20]
    , bgColor = TH.background
    , fgColor = TH.foreground
    , borderColor = TH.darkBlack
    , border = FullB
    , position = Static{xpos = 0, ypos = 0, width = 1920, height = 30}
    , alpha = 255
    , lowerOnStart = True
    , hideOnStart = False
    , persistent = True
    , overrideRedirect = False
    -- , iconRoot = homeDir <> "/.config/xmonad/icons"
    , iconOffset = -1
    , commands = myCommands
    , sepChar = "%"
    , alignSep = "}{"
    , template =
        wrap " " " " (brightMagentaWrap $ xmobarFont 4 "\xe61f")
          <> inWrapper "%UnsafeXMonadLog%"
          <> "} {" -- wrap "}" "{"  (inWrapper' (white "\xfb8a"))
          <> concatMap
            inWrapper
            [ xmobarFont 5 "%wttr%"
            , cpuAction "%cpu%"
            , memoryAction "%memory%"
            , dateAction "%date%"
            , "%tray%"
            ]
    }
 where
  fontWrap :: String -> String
  fontWrap = wrap "" ","

  inWrapper :: String -> String
  inWrapper =
    wrap
      (xmobarColor TH.darkBlack  "" (xmobarFont 5 "\xe0b6"))
      (xmobarColor TH.darkBlack  "" (xmobarFont 5 "\xe0b4") <> " ")

  cpuAction, memoryAction, dateAction :: ShowS
  cpuAction x = xmobarAction "pgrep -x htop || alacritty -e htop -s PERCENT_CPU" "1" x
  memoryAction x = xmobarAction "pgrep -x htop || alacritty -e htop -s PERCENT_MEM" "1" x
  dateAction x = xmobarAction "~/.config/xmonad/scripts/calendar.sh" "1" x

-- | Commands to run xmobar modules on start
myCommands :: [Runnable]
myCommands =
  [
    Run UnsafeXMonadLog
  , Run $ Cpu
    [ "-t"
    , cyanWrap (xmobarFont 1 "\xf108" <> " <total>%")
    , "-L"
    , "50"
    , "-H"
    , "85"
    , "--low"
    , TH.brightBlue <> "," <> backgroundWrap
    , "--normal"
    , TH.darkGreen <> "," <> backgroundWrap
    , "--high"
    , TH.darkRed <> "," <> backgroundWrap
    ]
    (2 `seconds`)
  , Run $ Memory
    [ "-t"
    , magentaWrap (xmobarFont 1 "\xf538" <> " <usedratio>%")
    , "-L"
    , "50"
    , "-H"
    , "85"
    , "--low"
    , TH.brightBlue <> "," <> backgroundWrap
    , "--normal"
    , TH.darkGreen <> "," <> backgroundWrap
    , "--high"
    , TH.darkRed  <> "," <> backgroundWrap
    ]
    (3 `seconds`)
  , Run $ Date (blueWrap $ xmobarFont 1 "\xf017" <> " %l:%M %p") "date" (30 `seconds`)
  , Run $ CommandReader ("exec " <> homeDir <> "/.config/xmonad/scripts/weather.sh bar") "wttr"
  , Run $ Com (homeDir <> "/.config/xmonad/scripts/tray-padding-icon.sh") ["stalonetray"] "tray" 5
  ]
  where
    -- Convenience functions
    seconds :: Int -> Int
    seconds = (* 10)
    -- minutes = (60 *). seconds

-- | Get home directory
homeDir :: String
homeDir = unsafeDupablePerformIO (getEnv "HOME")

-- Colors
backgroundWrap :: String
backgroundWrap = TH.darkBlack <> ":5"

redWrap :: String -> String
redWrap = xmobarColor TH.darkRed  backgroundWrap
blueWrap :: String -> String
blueWrap = xmobarColor TH.brightBlue backgroundWrap
-- green = xmobarColor greenNormal backgroundWrap
cyanWrap :: String -> String
cyanWrap = xmobarColor TH.darkCyan backgroundWrap
-- yellow = xmobarColor yellowNormal backgroundWrap
magentaWrap :: String -> String
magentaWrap = xmobarColor TH.brightMagenta backgroundWrap
-- gray = xmobarColor blackLight backgroundWrap
whiteWrap :: String -> String
whiteWrap = xmobarColor TH.darkWhite  backgroundWrap

brightMagentaWrap :: String -> String
brightMagentaWrap = xmobarColor TH.brightMagenta  ""

main :: IO ()
main = xmobar config
