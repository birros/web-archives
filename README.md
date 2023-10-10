# Web archives

A web archives reader offering the ability to browse offline millions of
articles from large community projects such as [Wikipedia] or [Wikisource].

## Goals / Reasons

* **Availability** : offline, anytime, anywhere
* **Confidentiality** : no need to trust network's protocols or server's policy
* **Shareability** : disseminate knowledge

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
- [x] Night mode ([Darkreader])
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
**Windows** or **macOS**. This is a desktop application so it's not compatible
with mobile platforms such as **Android** or **iOS**.

### From Flathub

```shell
$ flatpak install com.github.birros.WebArchives
```

### From sources

```shell
$ git clone https://github.com/birros/web-archives.git \
    && cd web-archives
$ flatpak install -y \
    org.gnome.Platform//44 \
    org.gnome.Sdk//44 \
    org.flatpak.Builder
$ flatpak run --command=flatpak-builder-lint org.flatpak.Builder \
    --exceptions \
    manifest build-aux/flatpak/com.github.birros.WebArchives.yml
$ flatpak-builder \
    --ccache \
    --force-clean \
    --repo=repo \
    builddir build-aux/flatpak/com.github.birros.WebArchives.yml
$ flatpak remote-add --no-gpg-verify webarchives-repo repo
$ flatpak install -y webarchives-repo com.github.birros.WebArchives
```

### Tracker

Some **problems** may occur when running the application, especially if your
desktop environment does not use [GTK+], such as **[Kde]**.

The installation of **tracker service** is then required on the system
side to solve these problems, requiring the execution of one of these commands
depending on your distribution :

**Debian & Ubuntu**:

```shell
$ apt install tracker
```

**Fedora**:

```shell
$ dnf install tracker
```

### Other installation methods

The implementation of a common installation method for existing distributions
is in preparation, with **Debian** and **Ubuntu** as priorities.

## Alternatives

This application is directly inspired by the [Kiwix] application. In this way
WebArchives as well as Kiwix can read the Web archives in [ZIM format]. Kiwix is
available for **Windows**, **GNU/Linux**, **iOS** and **Android**.

## Useful links

- [WebArchives on Flathub]
- [Kiwix on Flathub]
- [Kiwix website]

<!-- External links and references -->

[Wikipedia]: https://en.wikipedia.org/wiki/Wikipedia
[Wikisource]: https://en.wikipedia.org/wiki/Wikisource
[ZIM]: https://en.wikipedia.org/wiki/ZIM_(file_format)
[Darkreader]: https://github.com/darkreader/darkreader
[GNU/Linux]: https://en.wikipedia.org/wiki/Linux
[GNOME]: https://en.wikipedia.org/wiki/GNOME
[Flathub]: https://flathub.org/
[terminal]: https://en.wikipedia.org/wiki/Terminal_emulator
[GTK+]: https://en.wikipedia.org/wiki/GTK+
[KDE]: https://en.wikipedia.org/wiki/KDE
[Kiwix]: https://en.wikipedia.org/wiki/Kiwix
[ZIM format]: https://en.wikipedia.org/wiki/ZIM_(file_format)
[HACKING.md]: HACKING.md
[WebArchives on Flathub]: https://flathub.org/apps/details/com.github.birros.WebArchives
[Kiwix on Flathub]: https://flathub.org/apps/details/org.kiwix.desktop
[Kiwix website]: https://www.kiwix.org/
