anim_sources = [
    'main.vala',
    'sys_ui/menu_bar.vala',
    'sys_ui/PauseMenu.vala',
    'sys_ui/rounded.vala'
]

anim_deps = [
    config_dep,
    dependency('glib-2.0'),
    dependency('atk'),
    dependency('mutter-mtk-16'),
    dependency('mutter-cogl-16'),
    dependency('mutter-clutter-16'),
    dependency('libmutter-16'),
    dependency('X11'),
    xext_dep,
    xfixes,
    dependency('gnome-desktop-3.0'),
    dependency('graphene-gobject-1.0'),
]

executable('anim', anim_sources,
           dependencies : anim_deps,
           include_directories : config_inc,
           install : true,
)
