#!/usr/bin/env fish
# new-clang-project.fish — scaffold a CMake C/C++ project
#
# Usage:
#   new-clang-project <project-name> [--c] [--dir <path>]
#
# Examples:
#   new-clang-project hello-cmake
#   new-clang-project my-c-tool --c
#   new-clang-project scratch --dir ~/projects
#
# Install once:
#   mkdir -p ~/.config/fish/functions
#   cp new-clang-project.fish ~/.config/fish/functions/new-clang-project.fish
# Fish auto-loads functions from that dir — no PATH/reload needed, just:
#   new-clang-project my-project

# --- templates ---------------------------------------------------------

function __ncp_template_main_cpp
    printf '%s\n' \
        '#include <iostream>' \
        '' \
        'int main() {' \
        '    std::cout << "Hello, world!\n";' \
        '    return 0;' \
        '}'
end

function __ncp_template_main_c
    printf '%s\n' \
        '#include <stdio.h>' \
        '' \
        'int main(void) {' \
        '    printf("Hello, world!\n");' \
        '    return 0;' \
        '}'
end

function __ncp_template_cmakelists -a name lang
    set -l cmake_lang CXX
    set -l src_file src/main.cpp
    set -l std_lines 'set(CMAKE_CXX_STANDARD 20)' 'set(CMAKE_CXX_STANDARD_REQUIRED ON)'

    if test $lang = c
        set cmake_lang C
        set src_file src/main.c
        set std_lines 'set(CMAKE_C_STANDARD 17)' 'set(CMAKE_C_STANDARD_REQUIRED ON)'
    end

    printf '%s\n' \
        'cmake_minimum_required(VERSION 3.20)' \
        "project($name LANGUAGES $cmake_lang)" \
        '' \
        $std_lines \
        'set(CMAKE_EXPORT_COMPILE_COMMANDS ON)' \
        '' \
        "add_executable($name $src_file)"
end

function __ncp_template_gitignore
    printf '%s\n' 'build/' 'compile_commands.json' '.cache/'
end

# --- main ----------------------------------------------------------------

function new-clang-project
    argparse 'c/c' 'dir=' -- $argv
    or return 1

    set -l project_name $argv[1]
    if test -z "$project_name"
        echo "Usage: new-clang-project <project-name> [--c] [--dir <path>]" >&2
        return 1
    end

    set -l lang cpp
    set -q _flag_c; and set lang c

    set -l base_dir .
    set -q _flag_dir; and set base_dir $_flag_dir

    set -l project_dir (string trim -r -c / $base_dir)/$project_name

    if test -e $project_dir
        echo "Error: '$project_dir' already exists." >&2
        return 1
    end

    set -l cmake_name (string replace -ar '[^a-zA-Z0-9_-]' '_' $project_name)

    mkdir -p $project_dir/src

    if test $lang = c
        __ncp_template_main_c > $project_dir/src/main.c
    else
        __ncp_template_main_cpp > $project_dir/src/main.cpp
    end

    __ncp_template_cmakelists $cmake_name $lang > $project_dir/CMakeLists.txt
    __ncp_template_gitignore > $project_dir/.gitignore

    git -C $project_dir init -q 2>/dev/null

    echo "Created $lang project at: $project_dir"
    echo
    echo "Next steps:"
    echo "  cd $project_dir"
    echo "  nvim ."
    echo "  # inside nvim: <leader>cg to generate, <leader>cb to build, <leader>cr to run"
end
