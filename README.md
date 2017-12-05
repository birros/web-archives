# Web archives

A web archives reader offering the ability to browse offline millions of
articles from large community projects such as [Wikipedia] or [Wikisource].

## Goals / Reasons

* **Availability:** offline, anytime, anywhere.
* **Confidentiality:** no need to trust network's protocols or server's policy.
* **Shareability:** disseminate knowledge.

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

- [X] List recently opened web archives.
- [X] List available local web archives.
- [X] List of web archives available to download.
- [X] Print a page.
- [X] Night mode (Basic support).
- [X] Zoom controls.
- [X] Search in page.
- [X] History.
- [X] Bookmarks.
- [X] Search a page.
- [X] Keyboard shortcuts.
- [X] Multi-windows.
- [X] Multi-tabs.
- [X] Random page.
- [X] Sandboxed pages (Pages are isolated from the web).
- [X] Ask for confirmation when opening an external link.
- [ ] Fullscreen mode.
- [ ] Table of contents.
- [ ] Responsive (Mobile ready).
- [ ] Global search (Search through all archives available on device).
- [ ] Search provider (Depends on previous feature).
- [ ] Inter web archives linking (Links from A pointing to B, can be directly
      opened in the corresponding archive).

## Enhancements (Unconfirmed)

- [ ] Immersive mode (See what is done on Android).
- [ ] External links handling (Open Wikipedia link from GNOME Maps for example).
- [ ] Hint mode (Open links quickly using keyboard).
- [ ] Nearby pages (Pages referencing nearby points of interest).
- [ ] Link preview popup (Preview the targeted page on mouseover or tap).
- [ ] Speech synthesis.
- [ ] Stream a local archive to nearby app instances (Useful in a classroom).
- [ ] Show a list of archives where the subject of the page can also be found.
- [ ] Option to block javascript.
- [ ] Options to control save strategy for items such as searches or history.
- [ ] Save images, video, audio on right click.
- [ ] Gallery of the media present on a page (Useful to browse images).

## Targeted platform

Priority given to GNU/Linux systems, especially the GNOME desktop environment.

But may be carried on other platforms in the future.

## Installation

If you are lucky, to install this application with [Flatpak], you just have
click on this link: [WebArchives].

Otherwise, you have to run this command line:
```
flatpak install https://flathub.org/repo/appstream/com.github.birros.WebArchives.flatpakref
```

For installation from sources, see [HACKING.md].

## Alternatives

This software is directly inspired by [Kiwix] applications.

It also relies on several libraries and content developed or packaged by them.

The applications they have developed are also free software, don't hesitate to
use them.

## For contributions and technical documentation

See: [HACKING.md].

<!-- Links references -->

[Wikipedia]: https://en.wikipedia.org/wiki/Wikipedia
[Wikisource]: https://en.wikipedia.org/wiki/Wikisource
[ZIM]: https://en.wikipedia.org/wiki/ZIM_(file_format)
[Flatpak]: https://flatpak.org/
[WebArchives]: https://flathub.org/repo/appstream/com.github.birros.WebArchives.flatpakref
[Kiwix]: http://www.kiwix.org/
[HACKING.md]: HACKING.md
