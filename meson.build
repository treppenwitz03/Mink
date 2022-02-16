project(
    'com.github.zenitsudev.mink',
    'vala', 'c',
    version: '0.1'
)

granite_dep = dependency('granite-7')
gtk_dep = dependency('gtk4')
posix_dep = meson.get_compiler('vala').find_library('posix')
adwaita_dep = dependency('libadwaita-1')

dependencies = [
    granite_dep,
    gtk_dep,
    posix_dep,
    adwaita_dep
]

# subdir('po')
subdir('src')
subdir('data')

meson.add_install_script('meson/post_install.py')
