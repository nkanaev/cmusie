# cmusie

control cmus playback on macos using the ui and/or media keys.

![preview](https://raw.githubusercontent.com/nkanaev/cmusie/master/assets/preview.jpg)

[download](https://github.com/nkanaev/cmusie/releases/latest)

# usage

1. Open the app, the tray icon should appear.
2. Click the tray icon, then press "link" on the popover (1st button on the bottom right).
3. If the app asks for permissions, follow the instructions.
4. Run the command below:

        ln -s `which cmus-remote` /usr/local/bin/cmus-remote
5. (Optionally) follow the guide [here](https://support.apple.com/en-gb/guide/mac-help/mh15189/mac) to automatically start the app when you log in.

# credits

* [fontawesome]: for button icons
* [mpv]: for low-level media keys control code.

[fontawesome]: http://fontawesome.com/
[mpv]: https://github.com/mpv-player/mpv
