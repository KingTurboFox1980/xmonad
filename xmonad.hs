import System.IO
import System.Exit
import XMonad
import Graphics.X11.ExtraTypes.XF86

import XMonad.Actions.SpawnOn
import XMonad.Actions.CycleWS
import XMonad.Actions.OnScreen

import XMonad.Config.Desktop
import XMonad.Config.Azerty

import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog, doLower)
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.EwmhDesktops (fullscreenEventHook)
import XMonad.ManageHook

import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.ShowWName
import XMonad.Layout.ResizableTile
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.CircleEx
import XMonad.Layout.Spiral(spiral)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.IndependentScreens
import XMonad.Layout.CenteredMaster(centerMaster)
import XMonad.Layout.Fullscreen (fullscreenEventHook, fullscreenManageHook, fullscreenSupport, fullscreenFull)
import XMonad.Layout.ShowWName
import XMonad.Layout.NoBorders (noBorders, smartBorders)

import XMonad.Util.EZConfig (additionalKeys, additionalMouseBindings)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)

import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified Data.ByteString as B
import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8

import Control.Monad (liftM2)


------------------------------------------------------------------------
-- Autostart--
------------------------------------------------------------------------

myStartupHook = do
    spawnOnce "$HOME/.xmonad/scripts/autostart.sh &"
    setWMName "LG3D"


------------------------------------------------------------------------
-- Colors--
------------------------------------------------------------------------

-- Dracula colors --
normBord = "#100c08"
focdBord = "#BD93F9" 
fore     = "#BD93F9"
back     = "#282A36"
winType  = "#BD93F9"

--mod4Mask= super key
--mod1Mask= alt key
--controlMask= ctrl key
--shiftMask= shift key


---------------------------------------------------------------------------------
-- Theme for showWName which prints current workspace when you change workspaces.
---------------------------------------------------------------------------------

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font = "xft:Space Age:size=75"
    , swn_fade    = 0.5
    , swn_bgcolor = "#1c1f24"
    , swn_color   = "#9580FF"
    }

myModMask = mod4Mask
encodeCChar = map fromIntegral . B.unpack
myFocusFollowsMouse = True
myBorderWidth = 2


------------------------------------------------------------------------
--Workspaces--
------------------------------------------------------------------------

--myWorkspaces    = ["\61612","\61899","\61947","\61635","\61502","\61501","\61705","\61564","\62150","\61872"]
--myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
--myWorkspaces    = ["<1>", "<2>", "<3>", "<4>", "<5>", "<6>", "<7>", "<8>", "<9>"]
--myWorkspaces    = ["|1|", "|2|", "|3|", "|4|", "|5|", "|6|", "|7|", "|8|", "|9|"]
--myWorkspaces    = ["I","II","III","IV","V","VI","VII","VIII","IX","X"]
myWorkspaces    = ["HOME","VM","MEDIA","TERM","CODE","TORRENT","WEB","E-MAIL","FILES"]

myBaseConfig = desktopConfig


------------------------------------------------------------------------
-- window manipulations --
------------------------------------------------------------------------
-- A helper function for shifting and switching to a workspace
doShiftAndGo :: String -> ManageHook
doShiftAndGo ws = doF (W.greedyView ws) <+> doShift ws

myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [isFullscreen --> doFullFloat
    , manageDocks]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "HOME" | x <- my1Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "VM" | x <- my2Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "MEDIA" | x <- my3Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "TERM" | x <- my4Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "CODE" | x <- my5Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "TORRENT" | x <- my6Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "WEB" | x <- my7Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "E-MAIL" | x <- my8Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "FILES" | x <- my9Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "" | x <- my10Shifts]
    , [className =? "trayer" --> doIgnore]
    , [className =? "Polybar" --> doLower]
    ]
    where
    doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["Arandr", "Arcolinux-calamares-tool.py", "Archlinux-tweak-tool.py", "Arcolinux-welcome-app.py", "Galculator", "feh", "mpv", "Xfce4-terminal"]
    myTFloats = ["Downloads", "Save As...", "vlc"]
    myRFloats = []
    myIgnores = ["desktop_window"]
    my1Shifts = []
    my2Shifts = ["Virt-manager"]
    my3Shifts = ["vlc", "freetube", "red-app", "mpv", "tartube","Cider", "apple-music-for-linux"]
    my4Shifts = ["kitty", "alacritty"]
    my5Shifts = ["code-oss", "kate", "geany"]
    my6Shifts = ["qBittorrent"]
    my7Shifts = ["Chromium", "Vivaldi-stable", "Firefox", "Microsoft-edge", "floorp", "zen", "Navigator"]
    my8Shifts = ["Org.gnome.Evolution"]
    my9Shifts = ["Thunar", "rclone-browser"]
    my10Shifts = ["discord"]


------------------------------------------------------------------------
--layouts--
------------------------------------------------------------------------

myLayout = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $
            avoidStruts $
            mkToggle (NBFULL ?? NOBORDERS ?? EOT) $
            tiled ||| 
            Mirror tiled ||| 
            spiral (6/7) ||| 
            ThreeColMid 1 (3/100) (1/2) ||| 
            Full ||| 
            Tall 1 (3/100) (1/2) ||| 
            Mirror (Tall 1 (3/100) (1/2)) |||
            noBorders (fullscreenFull Full)

tiled = Tall nmaster delta tiled_ratio

nmaster = 1 -- number of windows in the master pane
delta = 3/100 -- percentage of screen to increment by when resizing panes
tiled_ratio = 1/2 -- initial ratio of master pane to rest

myHandleEventHook = ewmhFullscreen

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, 1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, 2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, 3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))

    ]


------------------------------------------------------------------------
-- Key Bindings Configuration
------------------------------------------------------------------------

-- ROG Numpad Keys Mapping
-- xK_KP_Insert: Numeric keypad 0
-- xK_KP_End: Numeric keypad 1
-- xK_KP_2: Numeric keypad 2
-- xK_KP_Next: Numeric keypad 3
-- xK_KP_4: Numeric keypad 4
-- xK_KP_Begin: Numeric keypad 5
-- xK_KP_6: Numeric keypad 6
-- xK_KP_Home: Numeric keypad 7
-- xK_KP_8: Numeric keypad 8
-- xK_KP_Prior: Numeric keypad 9
-- xK_KP_Delete: Numeric keypad decimal point
-- xK_KP_Enter: Numeric keypad Enter
-- xK_KP_Divide: "/" key
-- xK_KP_Multiply: "*" key
-- xK_KP_Subtract: "-" key
-- xK_KP_Add: "+" key

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------

  -- SUPER + FUNCTION KEYS

  [ ((modMask, xK_e), spawn $ "atom" )
  , ((modMask .|. shiftMask, xK_f), sendMessage $ Toggle NBFULL)
  , ((modMask, xK_f), sendMessage (Toggle NBFULL) >> spawn "polybar-msg cmd toggle")
--  , ((modMask, xK_f), sendMessage (Toggle NBFULL) >> spawn "polybar-msg cmd toggle && (killall xmobar || xmobar &)")
  , ((modMask, xK_m), spawn $ "lollypop" )
  , ((modMask, xK_q), kill )
  , ((modMask, xK_r), spawn $ "rofi-theme-selector" )
  , ((modMask, xK_v), spawn $ "pavucontrol" )
  , ((0, xK_F10), spawn "polybar-msg cmd toggle" )
  , ((modMask, xK_x), spawn $ "archlinux-logout" )
  , ((modMask, xK_Escape), spawn $ "xkill" )
 -- , ((modMask, xK_Return), spawn $ "alacritty" )
  , ((modMask, xK_F1), spawn $ "vivaldi-stable" )
  , ((modMask, xK_F2), spawn $ "atom" )
  , ((modMask, xK_F3), spawn $ "inkscape" )
  , ((modMask, xK_F4), spawn $ "gimp" )
  , ((modMask, xK_F5), spawn $ "meld" )
  , ((modMask, xK_F6), spawn $ "vlc --video-on-top" )
  , ((modMask, xK_F7), spawn $ "virt-manager" )
  , ((modMask, xK_F8), spawn $ "thunar" )
  , ((modMask, xK_F9), spawn $ "lollypop" )
--  , ((modMask, xK_F10), spawn $ "spotify" )
  , ((modMask, xK_F11), spawn $ "rofi -theme-str 'window {width: 100%;height: 100%;}' -show drun" )
  , ((modMask, xK_z), spawn $ "rofi -show drun" )
  , ((modMask, xK_KP_Enter), spawn $ "galculator" )

--Custom--

  , ((modMask, xK_o), spawn $ "p3x-onenote" )
  , ((modMask, xK_c), spawn $ "code" ) 
--  , ((modMask, xK_a), spawn $ "apple-music-for-linux" )
  , ((modMask, xK_a), spawn $ "sh.cider.Cider" )
  , ((modMask, xK_e), spawn $ "evolution" )
  , ((modMask, xK_w), spawn $ "vivaldi-stable" )
  , ((modMask .|. shiftMask , xK_w ), spawn $ "microsoft-edge-stable" )
--  , ((modMask, xK_F10),  spawn $ "exec /home/j3ll0/.config/polybar/launch.sh" )
  , ((modMask, xK_x), spawn $ "archlinux-logout" )
  , ((modMask, xK_Escape), spawn $ "missioncenter" )
  , ((modMask .|. controlMask, xK_Escape), spawn $ "neohtop" )
  , ((mod4Mask .|. mod1Mask , xK_Escape), spawn $ "exec xfce4-terminal -e 'htop task manager' -e btop" )
  , ((modMask .|. shiftMask , xK_Return), spawn $ "kitty" )
  , ((0, xF86XK_Launch1), spawn $ "exec /home/j3ll0/.config/scripts/dwmfolders.sh" )
  , ((0, xK_KP_Subtract), spawn $ "exec /home/j3ll0/.config/scripts/rog_key_scripts.sh" )
--  , ((0, xK_KP_Divide), spawn $ "exec /home/j3ll0/.config/polybar/launch.sh" )
  , ((0, xK_KP_Divide), spawn $ "exec arcolinux-restart-polybar" )
  , ((0, xK_KP_Add), spawn $ "exec /home/j3ll0/.config/scripts/maintenance.sh" )
  , ((modMask, xK_KP_Add), spawn $ "exec xfce4-terminal --geometry=120x25 -e /home/j3ll0/update.sh" )
  , ((modMask, xK_t), spawn $ "thunar" )
  , ((0, xK_KP_Multiply), spawn $ "exec /home/j3ll0/.config/polybar/scripts/keyhintxmonad.sh")
  , ((modMask, xK_KP_Multiply), spawn $ "exec /home/j3ll0/.config/polybar/scripts/keyhintarco.sh")
  , ((shiftMask, xK_KP_Multiply), spawn $ "exec /home/j3ll0/.config/polybar/scripts/keyhintvim.sh")
  , ((0, xK_F9), spawn $ "exec /home/j3ll0/.config/scripts/redshift.sh" )
  , ((0, xK_F6), spawn $ "exec /home/j3ll0/.config/scripts/screenoff.sh" )
  , ((modMask, xK_s), spawn $ "exec /home/j3ll0/.config/scripts/dmenu-websearch.sh" )
--  , ((0 , xF86XK_AudioMicMute ), spawn $ "exec /home/j3ll0/.config/scripts/wallpaper.sh")
  , ((0 , xF86XK_AudioMicMute ), spawn $ "variety -n & wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt & pywalfox update) &")
  , ((mod4Mask .|. mod1Mask , xK_Up ), spawn $ "asusctl aura -n")
  , ((mod4Mask .|. mod1Mask , xK_Down ), spawn $ "asusctl aura -p") 


  -- Shrink the master area.
  , ((shiftMask .|. controlMask, xK_Left), sendMessage Shrink)

  -- Expand the master area.
  , ((shiftMask .|. controlMask, xK_Right), sendMessage Expand)

  -- Push window back into tiling.
  , ((0, xK_KP_Delete), withFocused $ windows . W.sink)

  -- Swap the focused window with the next window.
  , ((shiftMask .|. controlMask, xK_Down), windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((shiftMask .|. controlMask, xK_Up), windows W.swapUp  )


  -- FUNCTION KEYS
  , ((modMask, xK_Return), spawn $ "xfce4-terminal --drop-down" )

  -- SUPER + SHIFT KEYS

--  , ((modMask .|. shiftMask , xK_Return ), spawn $ "thunar")
  , ((modMask .|. shiftMask , xK_d ), spawn $ "dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn 'NotoMonoRegular:bold:pixelsize=14'")
  , ((modMask, xK_d ), spawn $ "/home/j3ll0/.xmonad/launcher/launcher.sh")
  , ((modMask .|. shiftMask , xK_r ), spawn $ "xmonad --recompile && xmonad --restart")
  , ((modMask .|. shiftMask , xK_q ), kill)
  , ((modMask .|. shiftMask , xK_x ), spawn $ "arcolinux-powermenu")
  -- , ((modMask .|. shiftMask , xK_x ), io (exitWith ExitSuccess))

  -- CONTROL + ALT KEYS

  , ((controlMask .|. mod1Mask , xK_Next ), spawn $ "conky-rotate -n")
  , ((controlMask .|. mod1Mask , xK_Prior ), spawn $ "conky-rotate -p")
  , ((controlMask .|. mod1Mask , xK_a ), spawn $ "xfce4-appfinder")
  , ((controlMask .|. mod1Mask , xK_b ), spawn $ "thunar")
  , ((controlMask .|. mod1Mask , xK_c ), spawn $ "catfish")
  , ((controlMask .|. mod1Mask , xK_e ), spawn $ "archlinux-tweak-tool")
  , ((controlMask .|. mod1Mask , xK_f ), spawn $ "firefox")
  , ((controlMask .|. mod1Mask , xK_g ), spawn $ "chromium -no-default-browser-check")
  , ((controlMask .|. mod1Mask , xK_i ), spawn $ "nitrogen")
  , ((controlMask .|. mod1Mask , xK_k ), spawn $ "archlinux-logout")
  , ((controlMask .|. mod1Mask , xK_l ), spawn $ "archlinux-logout")
  , ((controlMask .|. mod1Mask , xK_m ), spawn $ "xfce4-settings-manager")
  , ((controlMask .|. mod1Mask , xK_o ), spawn $ "$HOME/.xmonad/scripts/picom-toggle.sh")
  , ((controlMask .|. mod1Mask , xK_p ), spawn $ "pamac-manager")
  , ((controlMask .|. mod1Mask , xK_r ), spawn $ "rofi-theme-selector")
  , ((controlMask .|. mod1Mask , xK_s ), spawn $ "spotify")
  , ((controlMask .|. mod1Mask , xK_t ), spawn $ "alacritty")
  , ((controlMask .|. mod1Mask , xK_u ), spawn $ "pavucontrol")
  , ((controlMask .|. mod1Mask , xK_v ), spawn $ "vivaldi-stable")
  , ((controlMask .|. mod1Mask , xK_w ), spawn $ "arcolinux-welcome-app")
  , ((controlMask .|. mod1Mask , xK_Return ), spawn $ "alacritty")

  -- ALT + ... KEYS

  , ((mod1Mask, xK_f), spawn $ "variety -f" )
  , ((mod1Mask, xK_n), spawn $ "variety -n" )
  , ((mod1Mask, xK_p), spawn $ "variety -p" )
  , ((mod1Mask, xK_r), spawn $ "xmonad --restart" )
  , ((mod1Mask, xK_t), spawn $ "variety -t" )
  , ((mod1Mask, xK_Up), spawn $ "variety --pause" )
  , ((mod1Mask, xK_Down), spawn $ "variety --resume" )
  , ((mod1Mask, xK_Left), spawn $ "variety -p" )
  , ((mod1Mask, xK_Right), spawn $ "variety -n" )
  , ((mod1Mask, xK_F2), spawn $ "xfce4-appfinder --collapsed" )
  , ((mod1Mask, xK_F3), spawn $ "xfce4-appfinder" )

  --VARIETY KEYS WITH PYWAL

  , ((mod1Mask .|. shiftMask , xK_f ), spawn $ "variety -f && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
  , ((mod1Mask, xK_n ), spawn $ "variety -n && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt && pywalfox update)&")
  , ((mod1Mask, xK_p ), spawn $ "variety -p && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt && pywalfox update)&")
  , ((mod1Mask .|. shiftMask , xK_t ), spawn $ "variety -t && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
  , ((mod1Mask .|. shiftMask , xK_u ), spawn $ "wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")

  --CONTROL + SHIFT KEYS

  , ((controlMask .|. shiftMask , xK_Escape ), spawn $ "xfce4-taskmanager")

  --SCREENSHOTS

  , ((0, xK_Print), spawn $ "scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")
  , ((controlMask, xK_Print), spawn $ "xfce4-screenshooter" )
  , ((controlMask .|. shiftMask , xK_Print ), spawn $ "gnome-screenshot -i")
  , ((controlMask .|. modMask , xK_Print ), spawn $ "flameshot gui")

  --MULTIMEDIA KEYS

  -- Mute volume
  , ((0, xF86XK_AudioMute), spawn $ "amixer -q set Master toggle")

  -- Decrease volume
  , ((0, xF86XK_AudioLowerVolume), spawn $ "amixer -q set Master 5%-")

  -- Increase volume
  , ((0, xF86XK_AudioRaiseVolume), spawn $ "amixer -q set Master 5%+")

  -- Increase brightness
  , ((0, xF86XK_MonBrightnessUp),  spawn $ "xbacklight -inc 5")

  -- Decrease brightness
  , ((0, xF86XK_MonBrightnessDown), spawn $ "xbacklight -dec 5")

  -- Alternative to increase brightness

  -- Increase brightness
  -- , ((0, xF86XK_MonBrightnessUp),  spawn $ "brightnessctl s 5%+")

  -- Decrease brightness
  -- , ((0, xF86XK_MonBrightnessDown), spawn $ "brightnessctl s 5%-")

--  , ((0, xF86XK_AudioPlay), spawn $ "mpc toggle")
--  , ((0, xF86XK_AudioNext), spawn $ "mpc next")
--  , ((0, xF86XK_AudioPrev), spawn $ "mpc prev")
--  , ((0, xF86XK_AudioStop), spawn $ "mpc stop")

  , ((0, xF86XK_AudioPlay), spawn $ "playerctl play-pause")
  , ((0, xF86XK_AudioNext), spawn $ "playerctl next")
  , ((0, xF86XK_AudioPrev), spawn $ "playerctl previous")
  , ((0, xF86XK_AudioStop), spawn $ "playerctl stop")

  --  XMONAD LAYOUT KEYS

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space), sendMessage NextLayout)

  --Focus selected desktop
  , ((mod1Mask, xK_Tab), nextWS)

  --Focus selected desktop
  , ((modMask, xK_Tab), nextWS)

  --Focus selected desktop
  , ((controlMask .|. mod1Mask , xK_Left ), prevWS)

  --Focus selected desktop
  , ((controlMask .|. mod1Mask , xK_Right ), nextWS)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Move focus to the next window.
  , ((modMask, xK_j), windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k), windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask .|. shiftMask, xK_m), windows W.focusMaster  )

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown  )

  -- Swap the focused window with the next window.
  , ((controlMask .|. modMask, xK_Down), windows W.swapDown  )

  -- Swap the focused window with the previous window.
  --, ((modMask .|. shiftMask, xK_k), windows W.swapUp    )

  -- Swap the focused window with the previous window.
  --, ((controlMask .|. modMask, xK_Up), windows W.swapUp  )

  -- Shrink the master area.
  --, ((controlMask .|. shiftMask , xK_h), sendMessage Shrink)

  -- Expand the master area.
  --, ((controlMask .|. shiftMask , xK_l), sendMessage Expand)

  -- Push window back into tiling.
  --, ((controlMask .|. shiftMask , xK_t), withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((controlMask .|. modMask, xK_Left), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((controlMask .|. modMask, xK_Right), sendMessage (IncMasterN (-1)))

  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)

  --Keyboard layouts
  --qwerty users use this line
   | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7,xK_8,xK_9,xK_0]

  --French Azerty users use this line
  -- | (i, k) <- zip (XMonad.workspaces conf) [xK_ampersand, xK_eacute, xK_quotedbl, xK_apostrophe, xK_parenleft, xK_minus, xK_egrave, xK_underscore, xK_ccedilla , xK_agrave]

  --Belgian Azerty users use this line
  --   | (i, k) <- zip (XMonad.workspaces conf) [xK_ampersand, xK_eacute, xK_quotedbl, xK_apostrophe, xK_parenleft, xK_section, xK_egrave, xK_exclam, xK_ccedilla, xK_agrave]

      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)
      , (\i -> W.greedyView i . W.shift i, shiftMask)]]

  ++
  -- ctrl-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. controlMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --    | (key, sc) <- zip [xK_w, xK_e] [0..]
  --    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_Right, xK_Left] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

main :: IO ()
main = do

    dbus <- D.connectSession
    -- Request access to the DBus name
    D.requestName dbus (D.busName_ "org.xmonad.Log")
        [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

    xmonad . ewmh $
        -- Keyboard layouts
        -- qwerty users use this line
        myBaseConfig
        -- French Azerty users use this line
        -- myBaseConfig { keys = azertyKeys <+> keys azertyConfig }
        -- Belgian Azerty users use this line
        -- myBaseConfig { keys = belgianKeys <+> keys belgianConfig }
        { startupHook = myStartupHook
        , layoutHook = showWName' myShowWNameTheme $
                       gaps [(U, 10), (D, 10), (R, 5), (L, 5)] $
                       smartBorders $
                       avoidStruts $
                       (myLayout ||| layoutHook myBaseConfig)
        , manageHook = manageSpawn <+> myManageHook <+> manageHook myBaseConfig
        , modMask = myModMask
        , borderWidth = myBorderWidth
        , handleEventHook = handleEventHook myBaseConfig
        , focusFollowsMouse = myFocusFollowsMouse
        , workspaces = myWorkspaces
        , focusedBorderColor = focdBord
        , normalBorderColor = normBord
        , keys = myKeys
        , mouseBindings = myMouseBindings
        }
