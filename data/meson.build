install_data('com.panos.desktop.anim.gschema.xml',
             install_dir : get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required : false, disabler : true)
test('Validate schema file',
     compile_schemas,
     args : ['--strict', '--dry-run', meson.current_source_dir()])
