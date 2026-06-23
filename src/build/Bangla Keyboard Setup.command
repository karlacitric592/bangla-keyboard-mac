#!/bin/bash
# Bangla Keyboard — smart Setup (Install / Reinstall / Uninstall)
# Double-click to run. Detects whether the keyboard is already installed and
# offers the right action. by BiswasHost — https://www.biswashost.com

DIR="$(cd "$(dirname "$0")" && pwd)"
PKG="$DIR/Bangla Keyboard.pkg"
KL="/Library/Keyboard Layouts"
LAYOUT="$KL/Bangla Unicode.keylayout"
TITLE="Bangla Keyboard Setup"

FONTS=(AdorshoLipi_20-07-2007.ttf AponaLohit.ttf Bangla.ttf BenSen.ttf \
BenSenHandwriting.ttf Lohit_14-04-2007.ttf Mukti_1.99_PR.ttf Siyamrupali.ttf \
SolaimanLipi.ttf akaashnormal.ttf kalpurush.ttf mitra.ttf muktinarrow.ttf sagarnormal.ttf)

dialog() { # $1=text  $2=buttons(as AppleScript list)  $3=default
  osascript -e "button returned of (display dialog \"$1\" buttons $2 default button \"$3\" with title \"$TITLE\" with icon note)" 2>/dev/null
}
info()  { osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"$TITLE\" with icon note" >/dev/null 2>&1; }

run_install() {
  if [ ! -f "$PKG" ]; then info "Installer package not found next to this script."; exit 1; fi
  # Path is passed as an osascript argument and shell-quoted by AppleScript
  # (quoted form of), so a path containing quotes/spaces can never inject.
  if osascript - "$PKG" >/dev/null 2>&1 <<'OSA'
on run argv
	do shell script "/usr/sbin/installer -pkg " & quoted form of (item 1 of argv) & " -target /" with administrator privileges
end run
OSA
  then
    info "Installed. Now: 1) LOG OUT and back in (or restart). 2) System Settings - Keyboard - Text Input - Edit - plus - Bangla - add the layouts. (macOS caches keyboard layouts, so the log-out is required.)"
  else
    info "Install was cancelled or failed."
  fi
}

run_uninstall() {
  # Build the full file list, pass each as an argv, quote each in AppleScript.
  local files=( "$KL/Bangla Unicode.keylayout" "$KL/Bangla Unicode.icns" \
                "$KL/Bangla Classic.keylayout" "$KL/Bangla Classic.icns" )
  local f; for f in "${FONTS[@]}"; do files+=( "/Library/Fonts/$f" ); done
  if osascript - "${files[@]}" >/dev/null 2>&1 <<'OSA'
on run argv
	set cmd to "/bin/rm -f"
	repeat with p in argv
		set cmd to cmd & " " & quoted form of (p as text)
	end repeat
	do shell script cmd with administrator privileges
end run
OSA
  then
    info "Uninstalled. The layout files and the bundled fonts were removed. If the layouts still show in the menu, remove them in System Settings - Keyboard - Text Input - Edit, then log out/in."
  else
    info "Uninstall was cancelled or failed."
  fi
}

if [ -f "$LAYOUT" ]; then
  choice=$(dialog "Bangla Keyboard is already installed.\n\nWhat would you like to do?" '{"Cancel","Uninstall","Reinstall"}' "Reinstall")
  case "$choice" in
    Reinstall) run_install ;;
    Uninstall) run_uninstall ;;
    *) exit 0 ;;
  esac
else
  choice=$(dialog "Bangla Keyboard is not installed.\n\nInstall it now?" '{"Cancel","Install"}' "Install")
  case "$choice" in
    Install) run_install ;;
    *) exit 0 ;;
  esac
fi
