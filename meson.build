project('anim', ['c', 'vala'],
        version : '0.1.0',
        meson_version : '>= 1.0.0',
        default_options : ['warning_level=2', 'werror=false', ],
)

i18n = import('i18n')
gnome = import('gnome')
valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

xext_dep = cc.find_library('Xext', required : true)
xfixes = cc.find_library('Xfixes', required : true)

vala_flags = ['--define', 'HAS_MUTTER43', '--define', 'HAS_MUTTER44', '--define', 'HAS_MUTTER45', '--define', 'HAS_MUTTER46', '--define', 'HAS_MUTTER47', '--define', 'HAS_MUTTER48']
add_project_arguments(vala_flags, language : 'vala')

vapi_dir = meson.project_source_root() / 'vapi'

add_project_arguments([
                          '--target-glib=2.44',
                          '--hide-internal',
                          '--enable-deprecated',
                          '--vapidir=' + vapi_dir,
                          '--pkg', 'xfixes-4.0',
                          '--pkg', 'libmutter-16',
                      ],
                      language : 'vala',
)


srcdir = meson.project_source_root() / 'src'

config_h = configuration_data()
config_h.set_quoted('PACKAGE_VERSION', meson.project_version ())
config_h.set_quoted('GETTEXT_PACKAGE', 'anim')
config_h.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
configure_file(output : 'config.h', configuration : config_h)

config_dep = valac.find_library ('config', dirs : srcdir)
config_inc = include_directories('.')

add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name () + '"', language : 'c')

subdir('src')

gnome.post_install(
    glib_compile_schemas : true,
    gtk_update_icon_cache : true,
    update_desktop_database : true,
)