function make-love --description "Scaffold a minimal LOVE2D lua project in the current directory"
    set -l luarc_file .luarc.json
    set -l main_file main.lua

    if test -e $luarc_file
        echo "make-love: $luarc_file already exists, skipping"
    else
        printf '%s\n' \
            '{' \
            '  "runtime.version": "LuaJIT",' \
            '  "diagnostics.globals": ["love"],' \
            '  "workspace.library": ["~/.local/share/lua-language-server/addons/love2d/library"],' \
            '  "workspace.checkThirdParty": false' \
            '}' > $luarc_file
        echo "make-love: created $luarc_file"
    end

    if test -e $main_file
        echo "make-love: $main_file already exists, skipping"
    else
        printf '%s\n' \
            '---@diagnostic disable: duplicate-set-field' \
            'function love.load() end' \
            'function love.update(dt) end' \
            'function love.draw() end' \
            '---@diagnostic enable: duplicate-set-field' > $main_file
        echo "make-love: created $main_file"
    end
end
