i18n.merge_file(
    input: 'com.github.birros.WebArchives.desktop.in',
    output: 'com.github.birros.WebArchives.desktop',
    install: true,
    install_dir: join_paths(datadir, 'applications'),
    po_dir: '../../po',
    type: 'desktop'
)

iconsdir = join_paths(get_option('datadir'), 'icons/hicolor')
foreach size: ['scalable']
	install_subdir('icons/hicolor/' + size, install_dir: iconsdir)
endforeach

install_data('com.github.birros.WebArchives-mime.xml',
    install_dir: join_paths(datadir, 'mime/packages')
)
