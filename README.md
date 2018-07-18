# Web archives

A web archives reader offering the ability to browse offline millions of
articles from large community projects such as [Wikipedia] or [Wikisource].

## Goals / Reasons

* __Availability__ : offline, anytime, anywhere
* __Confidentiality__ : no need to trust network's protocols or server's policy
* __Shareability__ : disseminate knowledge

## Disclaimer

This software, despite its defects, bugs and instability, can be useful for
anyone who needs to browse important websites such as Wikipedia or Wikisource
without any Internet connection.

No guarantee regarding the update of internal databases until the release of a
stable version.

As long as it has not been improved, it is recommended to use it wisely.
Also, it only allows reading [ZIM] files for the moment.

## Screenshot

![Application home page](/data/appdata/screenshots/home.png?raw=true)

## Features

- [x] List recently opened web archives
- [x] List available local web archives
- [x] List of web archives available to download
- [x] Print a page
- [x] Night mode (Basic support)
- [x] Zoom controls
- [x] Search in page
- [x] History
- [x] Bookmarks
- [x] Search a page
- [x] Keyboard shortcuts
- [x] Multi-windows
- [x] Multi-tabs
- [x] Random page
- [x] Sandboxed pages (Pages are isolated from the web)
- [x] Ask for confirmation when opening an external link
- [x] Handle the opening of zim files from external applications (Nautilus...)
- [ ] Fullscreen mode
- [ ] Table of contents
- [ ] Responsive (Mobile ready)
- [ ] Global search (Search through all archives available on device)
- [ ] Search provider (Depends on previous feature)
- [ ] Inter web archives linking (Links from A pointing to B, can be directly
  opened in the corresponding archive)

## Enhancements (Unconfirmed)

- [ ] Immersive mode (See what is done on Android)
- [ ] External links handling (Open Wikipedia link from GNOME Maps for example)
- [ ] Hint mode (Open links quickly using keyboard)
- [ ] Nearby pages (Pages referencing nearby points of interest)
- [ ] Link preview popup (Preview the targeted page on mouseover or tap)
- [ ] Speech synthesis
- [ ] Stream a local archive to nearby app instances (Useful in a classroom)
- [ ] Show a list of archives where the subject of the page can also be found
- [ ] Option to block javascript
- [ ] Options to control save strategy for items such as searches or history
- [ ] Save images, video, audio on right click
- [ ] Gallery of the media present on a page (Useful to browse images)

## Installation

WebArchives was developed and tested under [GNU/Linux], with [GNOME] in sight.
However, it can be used under other desktop environments.

No method is provided to install this application on other platforms, such as
__Windows__ or __macOS__. This is a desktop application so it's not compatible
with mobile platforms such as __Android__ or __iOS__.

### WebArchives in Flatpak format

[Flatpak] installation is required : [Getting Flatpak].

Then add the [Flathub] repository and install WebArchives from a [terminal] :

    flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.github.birros.WebArchives

If this is your first Flatpak, restarting your session is necessary to make the
application appear in your launcher. It can also be executed from a terminal :

    flatpak run com.github.birros.WebArchives

Some __problems__ may occur when running the application, especially if your
desktop environment does not use [GTK+], such as __[Kde]__.

The installation of __two additional services__ is then required on the system
side to solve these problems, requiring the execution of one of these commands
depending on your distribution :

__Debian & Ubuntu__ :

    apt install tracker gvfs-backends

__Fedora__ :

    dnf install tracker gvfs

### Other installation methods

The implementation of a common installation method for existing distributions
is in preparation, with __Debian__ and __Ubuntu__ as priorities.

## Alternatives

This application is directly inspired by the [Kiwix] application. In this way
WebArchives as well as Kiwix can read the Web archives in [ZIM format]. Kiwix is
available for __Windows__, __GNU/Linux__, __iOS__ and __Android__.

## For contributions and technical documentation

See : [HACKING.md].

## Useful links

- [Flatpakref of WebArchives (external application)]
- [Kiwix website]
- [List of applications hosted on Flathub]

<!-- External links and references -->

[Wikipedia]: https://en.wikipedia.org/wiki/Wikipedia
[Wikisource]: https://en.wikipedia.org/wiki/Wikisource
[ZIM]: https://en.wikipedia.org/wiki/ZIM_(file_format)
[GNU/Linux]: https://en.wikipedia.org/wiki/Linux
[GNOME]: https://en.wikipedia.org/wiki/GNOME
[Flatpak]: https://en.wikipedia.org/wiki/Flatpak
[Getting Flatpak]: https://flatpak.org/getting.html
[Flathub]: https://flathub.org/
[terminal]: https://en.wikipedia.org/wiki/Terminal_emulator
[GTK+]: https://en.wikipedia.org/wiki/GTK+
[KDE]: https://en.wikipedia.org/wiki/KDE
[Kiwix]: https://en.wikipedia.org/wiki/Kiwix
[ZIM format]: https://en.wikipedia.org/wiki/ZIM_(file_format)
[HACKING.md]: HACKING.md
[Flatpakref of WebArchives (external application)]: https://flathub.org/repo/appstream/com.github.birros.WebArchives.flatpakref
[Kiwix website]: https://www.kiwix.org/
[List of applications hosted on Flathub]: https://flathub.org/apps.html
