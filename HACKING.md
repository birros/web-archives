# Contributions and technical documentation

## Developer section

### Code architecture overview

__Diclaimer__ : this overview represents the status of the code at a specific
time and may not correlate with the current code status, so remember to update
this section as a result of major changes in the code architecture to make it
easier for newcomers to be involved.

The application is divided into two main binaries, the `web-archives` executable
which concerns the graphical part, and the `restrict-by-prefix` WebKit
WebExtension which is responsible for blocking all requests from a page of an
archive to the rest of the network.

For the moment the `server` responsible for delivering the content of an archive
is incorporated directly into the `web-archives` binary, in the future it will
certainly be placed in a separate binary in order to guarantee more stability
and security.

The use of a `server` rather than a `custom URI scheme` is motivated by the need
to be able to consult videos incorporated in the archives, which this last
solution does not allow, and the ability to process requests asynchronously.

The `web-archives` binary code is organized into several folders to ensure
better maintainability, here is the summary :
- __ui__ : windows, tabs and widgets
- __models__ : stores, models, items
- __utils__ : ephemeral classes and methods
- __states__ : context, states and logics
- __persistence__ : databases classes
- __services__ : server, tracker and remote
- __resources__ : data used by the ui

The main goal is to reduce the amount of work done by the ui code. So app's
startup looks like this :
1. Context : initialize states, logics, models, and services
2. Persistence : populate saved models and listen for changes
3. Start services
4. Launch a new window by passing it the context object

Overview diagram :

    Persistence <=> Context <=> Widgets


Each Widgets pass to its children a copy of the context inherited from its
parent. The context is the main object of the app, where the main part of
orchestration is done. The Context object can be forked or merged by Widgets
depending essentially on two rules :
1. __Fork__ : when a new child is created, like a new window or a new tab, a
copy of the context is passed to the child, but the states and logics concerning
the child are newly created.
2. __Merge__ : when reparenting a child, example when moving a tab from a window
to another one, the context of the child are kept, apart the states
corresponding to the new parent, which are copied to the context.

The Context is charged to handle events and changes from states using Logic
classes.

### Design (UI and UX)

- Inspired by Android and GNOME guidelines
- Reduce the number of clicks to perform action
- Reduce the number of distractions

### Coding style

- Try to keep a maximum of 80 chars by line
- Use anonymous and lambdas functions as little as possible
- Try to keep the same style across all files

---

## Graphics section

Maybe a better app icon. Don't hesitate to submit one.

---

## Language section

- Mistakes
- Translations

---

## Install from sources (Using flatpak)

First requires both `flatpak` and `flatpak-builder` to be installed.

Add flathub repo and install required runtimes :

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.gnome.Platform//3.26 org.gnome.Sdk//3.26

Then build it from sources :

    git clone https://github.com/birros/web-archives
    flatpak-builder --repo=repo web-archives-builddir web-archives/flatpak/com.github.birros.WebArchives.json
    flatpak build-update-repo repo

And finally install it locally :

    flatpak remote-add --no-gpg-verify web-archives-repo repo
    flatpak install web-archives-repo com.github.birros.WebArchives

You can run it directly using the app launcher or using this command :

    flatpak run com.github.birros.WebArchives

---

## Todo

- __CRITICAL__ : Handle the absence of system services such as Tracker or GVFS's
http backend :
  1. use D-Bus to test whether the service is available or not
  2. on the application's homepage, use a banner to indicate the absence of
  services
  3. display instructions in a modal window, depending on the system used, to
  install them
- Remove dependency on libkiwix
- Propose ZIM format recognition for GNU/Linux distributions (mimetype)
- Refactoring the settings : maximize, window size, night mode
- Write help manual
- Use thread and async
- Separate the ZIM file format code from the rest of the code, as a plugin
- Favicon caching management
- Reduce state dependencies between views
- Add a custom ContextMenu to WebView to manage the opening of a link in a new
tab or window
- On the home screen, specify when a more recent version of an archive is
available (example : by adding a blue dot)
- Also indicate when an archive could not be opened (example : by adding a red
dot)
- Progress bar for the WebView
- Manage download from the pages
- Use ORM for model and sqlite management

---

## Educational resources and inspirations

- https://wiki.gnome.org/Projects/Vala/Tutorial
- https://valadoc.org/
- https://gitlab.gnome.org/GNOME
- https://github.com/phastmike/vala-design-patterns-for-humans
- https://github.com/rschroll/webkitdom
- http://wiki.kiwix.org/wiki/Help
- http://www.openzim.org/wiki/Special:AllPages
- http://www.openzim.org/wiki/Javascript_API
- http://mirrorbrain.org/
