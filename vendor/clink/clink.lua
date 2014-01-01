--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
clink.matches = {}
clink.generators = {}

clink.arg = {}
clink.arg.generators = {}
clink.arg.node_flags_key = "\x01"

clink.prompt = {}
clink.prompt.filters = {}

--------------------------------------------------------------------------------
function clink.compute_lcd(text, list)
    local list_n = #list
    if list_n < 2 then
        return
    end

    -- Find min and max limits
    local max = 100000
    for i = 1, #list, 1 do
        local j = #(list[i])
        if max > j then
            max = j
        end
    end

    -- For each character in the search range...
    local mid = #text
    local lcd = ""
    for i = 1, max, 1 do
        local same = true
        local l = list[1]:sub(i, i)
        local m = l:lower()

        -- Compare character at the index with each other character in the
        -- other matches.
        for j = 2, list_n, 1 do
            local n = list[j]:sub(i, i):lower()
            if m ~= n then
                same = false
                break
            end
        end

        -- If all characters match then use first match's character.
        if same then
            lcd = lcd..l 
        else
            -- Otherwise use what the user's typed or if we're past that then
            -- bail out.
            if i <= mid then
                lcd = lcd..text:sub(i, i)
            else
                break
            end
        end
    end

    return lcd
end

--------------------------------------------------------------------------------
function clink.is_single_match(matches)
    if #matches <= 1 then
        return true
    end

    local first = matches[1]:lower()
    for i = 2, #matches, 1 do
        if first ~= matches[i]:lower() then
            return false
        end
    end

    return true
end

--------------------------------------------------------------------------------
function clink.generate_matches(text, first, last)
    clink.matches = {}
    clink.match_display_filter = nil

    for _, generator in ipairs(clink.generators) do
        if generator.f(text, first, last) == true then
            if #clink.matches > 1 then
                -- Catch instances where there's many entries of a single match
                if clink.is_single_match(clink.matches) then
                    clink.matches = { clink.matches[1] }
                    return true;
                end

                -- First entry in the match list should be the user's input,
                -- modified here to be the lowest common denominator.
                local lcd = clink.compute_lcd(text, clink.matches)
                table.insert(clink.matches, 1, lcd)
            end

            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
function clink.add_match(match)
    table.insert(clink.matches, match)
end

--------------------------------------------------------------------------------
function clink.register_match_generator(func, priority)
    if priority == nil then
        priority = 999
    end

    table.insert(clink.generators, {f=func, p=priority})
    table.sort(clink.generators, function(a, b) return a["p"] < b["p"] end)
end

--------------------------------------------------------------------------------
function clink.is_match(needle, candidate)
    if clink.lower(candidate:sub(1, #needle)) == clink.lower(needle) then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
function clink.match_count()
    return #clink.matches
end

--------------------------------------------------------------------------------
function clink.set_match(i, value)
    clink.matches[i] = value
end

--------------------------------------------------------------------------------
function clink.get_match(i)
    return clink.matches[i]
end

--------------------------------------------------------------------------------
function clink.split(str, sep)
    local i = 1
    local ret = {}
    for _, j in function() return str:find(sep, i, true) end do
        table.insert(ret, str:sub(i, j - 1))
        i = j + 1
    end
    table.insert(ret, str:sub(i, j))

    return ret
end

--------------------------------------------------------------------------------
function clink.quote_split(str, ql, qr)
    if not qr then
        qr = ql
    end

    -- First parse in "pre[ql]quote_string[qr]" chunks
    local insert = table.insert
    local i = 1
    local needle = "%b"..ql..qr
    local parts = {}
    for l, r, quote in function() return str:find(needle, i) end do
        -- "pre"
        if l > 1 then
            insert(parts, str:sub(i, l - 1))
        end

        -- "quote_string"
        insert(parts, str:sub(l + 1, r - 1))
        i = r + 1
    end

    -- Second parse what remains as "pre[ql]being_quoted"
    local l = str:find(ql, i, true)
    if l then
        -- "pre"
        if l > 1 then
            insert(parts, str:sub(i, l - 1))
        end

        -- "being_quoted"
        insert(parts, str:sub(l + 1))
    elseif i < #str then
        -- Finally add whatever remains...
        insert(parts, str:sub(i))
    end

    return parts
end

--------------------------------------------------------------------------------
function clink.arg.register_tree(cmd, generator)
    clink.arg.generators[cmd:lower()] = generator
end

--------------------------------------------------------------------------------
function clink.arg.tree_node(flags, content)
    local node = {}
    for key, arg in pairs(content) do
        node[key] = arg
    end

    node[clink.arg.node_flags_key] = flags
    return node
end

--------------------------------------------------------------------------------
function clink.arg.node_transpose(a, b)
    local c = {}
    for _, i in ipairs(a) do
        c[i] = b
    end

    return c
end

--------------------------------------------------------------------------------
function clink.arg.node_merge(a, b)
    c = {}
    d = {a, b}
    for _, i in ipairs(d) do
        if type(i) ~= "table" then
            i = {i}
        end

        for j, k in pairs(i) do
            if type(j) == "number" then
                table.insert(c, k)
            else
                c[j] = k
            end
        end
    end

    return c
end

--------------------------------------------------------------------------------
function clink.prompt.register_filter(filter, priority)
    if priority == nil then
        priority = 999
    end

    table.insert(clink.prompt.filters, {f=filter, p=priority})
    table.sort(clink.prompt.filters, function(a, b) return a["p"] < b["p"] end)
end

--------------------------------------------------------------------------------
function clink.filter_prompt(prompt)
    local function add_ansi_codes(p)
        local c = tonumber(clink.get_setting_int("prompt_colour"))
        if c < 0 then
            return p
        end

        c = c % 16

        --[[
            <4              >=4             %2
            0 0  0 Black    4 1 -3 Blue     0
            1 4  3 Red      5 5  0 Magenta  1
            2 2  0 Green    6 3 -3 Cyan     0
            3 6  3 Yellow   7 7  0 Gray     1
        --]]

        -- Convert from cmd.exe colour indices to ANSI ones.
        local colour_id = c % 8
        if (colour_id % 2) == 1 then
            if colour_id < 4 then
                c = c + 3
            end
        elseif colour_id >= 4 then
            c = c - 3
        end

        -- Clamp
        if c > 15 then
            c = 15
        end

        -- Build ANSI code
        local code = "\x1b[0;"
        if c > 7 then
            c = c - 8
            code = code.."1;"
        end
        code = code..(c + 30).."m"

        return code..p.."\x1b[0m"
    end

    clink.prompt.value = prompt

    for _, filter in ipairs(clink.prompt.filters) do
        if filter.f() == true then
            return add_ansi_codes(clink.prompt.value)
        end
    end

    return add_ansi_codes(clink.prompt.value)
end

-- vim: expandtab

--------------------------------------------------------------------------------
-- arguments.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local function traverse(generator, parts, text, first, last)
    -- Each part of the command line leading up to 'text' is considered as
    -- a level of the 'generator' tree.
    local part = parts[parts.n]
    local last_part = (parts.n >= #parts)
    parts.n = parts.n + 1

    -- Non-table types are leafs of the tree.
    local t = type(generator)
    if t == "function" then
        return generator(text, first, last)
    elseif t == "boolean" then
        return generator
    elseif t == "string" then
        if last_part then
            clink.add_match(generator)
        end
        return last_part
    elseif t ~= "table" then
        return false
    end

    -- Key/value pair is a node of the tree.
    local next_gen = generator[part]
    if next_gen then
        -- If this is the last part and we should be completing it then it's a
        -- valid match.
        if last_part and part:sub(-1) ~= " " then
            clink.add_match(part)
            return true
        end

        return traverse(next_gen, parts, text, first, last)
    end

    -- Check generator[1] for behaviour flags.
    -- * = If generator is a leave in the tree, repeat it for ever.
    -- + = User must have typed at least one character for matches to be added.
    local repeat_node = false
    local allow_empty_text = true
    local node_flags = generator[clink.arg.node_flags_key]
    if node_flags then
        repeat_node = (node_flags:find("*") ~= nil)
        allow_empty_text = (node_flags:find("+") == nil)
    end

    -- See if we should early-out if we've no text to search with.
    if not allow_empty_text and text == "" then
        return false
    end

    local full_match = false
    local matches = {}
    for key, value in pairs(generator) do
        -- So we're in a node but don't have enough info yet to traverse
        -- further down the tree. Attempt to pull out keys or array entries
        -- and add them as matches.
        local candidate = key
        if type(key) == "number" then
            candidate = value
        end

        if candidate ~= clink.arg.node_flags_key then
            if type(candidate) == "string" then
                if clink.is_match(part, candidate) then
                    full_match = full_match or (#part == #candidate)
                    table.insert(matches, candidate)
                end
            end
        end
    end

    -- One full match, we're not at the end, and we should repeat. Down we go...
    if not last_part then
        if full_match and repeat_node then
            return traverse(generator, parts, text, first, last)
        end
    else
        -- Transfer matches to clink.
        for _, i in ipairs(matches) do
            clink.add_match(i)
        end
    end
    
    return clink.match_count() > 0
end

--------------------------------------------------------------------------------
function clink.argument_match_generator(text, first, last)
    -- Extract the command name (naively)
    local leading = rl_line_buffer:sub(1, first - 1):lower()
    local cmd_start, cmd_end, cmd, ext = leading:find("^%s*([%w%-_]+)(%.*[%l]*)%s+")
    if not cmd_start then
        return false
    end

    -- Check to make sure the extension extracted is in pathext.
    if ext and ext ~= "" then
        if not clink.get_env("pathext"):lower():match(ext.."[;$]", 1, true) then
            return false
        end
    end

    -- Find a registered generator.
    local generator = clink.arg.generators[cmd]
    if generator == nil then
        return false
    end

    -- Split the command line into parts.
    local str = rl_line_buffer:sub(cmd_end, last - 1)
    local parts = {}
    for _, sub_str in ipairs(clink.quote_split(str, "\"")) do
        for _, r, part in function () return sub_str:find("^%s*([^%s]+)") end do
            table.insert(parts, part)
            sub_str = sub_str:sub(r+1)
        end
    end

    -- If 'text' is empty then add it as a part as it would have been skipped
    -- by the split loop above
    if text == "" then
        table.insert(parts, text)
    end

    parts.n = 1
    return traverse(generator, parts, text, first, last)
end

--------------------------------------------------------------------------------
clink.register_match_generator(clink.argument_match_generator, 25)

-- vim: expandtab

--------------------------------------------------------------------------------
-- dir.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
function dir_match_generator(text, first, last)
    -- Strip off any path components that may be on text.
    local prefix = ""
    local i = text:find("[\\/:][^\\/:]*$")
    if i then
        prefix = text:sub(1, i)
    end

    local mask = text.."*"

    -- Find matches.
    for _, dir in ipairs(clink.find_dirs(mask, true)) do
        local file = prefix..dir
        if clink.is_match(text, file) then
            clink.add_match(prefix..dir)
        end
    end

    -- If there was no matches but text is a dir then use it as the single match.
    -- Otherwise tell readline that matches are files and it will do magic.
    if clink.match_count() == 0 then
        if clink.is_dir(text) then
            clink.add_match(text)
        end
    else
        clink.matches_are_files()
    end

    return true
end

--------------------------------------------------------------------------------
clink.arg.register_tree("cd", dir_match_generator)
clink.arg.register_tree("chdir", dir_match_generator)
clink.arg.register_tree("pushd", dir_match_generator)
clink.arg.register_tree("rd", dir_match_generator)
clink.arg.register_tree("rmdir", dir_match_generator)
clink.arg.register_tree("md", dir_match_generator)
clink.arg.register_tree("mkdir", dir_match_generator)

-- vim: expandtab

--------------------------------------------------------------------------------
-- env.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local special_env_vars = {
    "cd", "date", "time", "random", "errorlevel",
    "cmdextversion", "cmdcmdline", "highestnumanodenumber"
}

--------------------------------------------------------------------------------
local function env_vars_display_filter(matches)
    local to_display = {}
    for _, m in ipairs(matches) do
        local _, _, out = m:find("(%%[^%%]+%%)$")
        table.insert(to_display, out)
    end

    return to_display
end

--------------------------------------------------------------------------------
local function env_vars_find_matches(candidates, prefix, part)
    local part_len = #part
    for _, name in ipairs(candidates) do
        if clink.lower(name:sub(1, part_len)) == part then
            clink.add_match(prefix..'%'..name:lower()..'%')
        end
    end
end

--------------------------------------------------------------------------------
local function env_vars_match_generator(text, first, last)
    local all = rl_line_buffer:sub(1, last)

    -- Skip pairs of %s
    local i = 1
    for _, r in function () return all:find("%b%%", i) end do
        i = r + 2
    end

    -- Find a solitary %
    local i = all:find("%%", i)
    if not i then
        return false
    end

    if i < first then
        return false
    end

    local part = clink.lower(all:sub(i + 1))
    local part_len = #part

    i = i - first
    local prefix = text:sub(1, i)

    env_vars_find_matches(clink.get_env_var_names(), prefix, part)
    env_vars_find_matches(special_env_vars, prefix, part)

    if clink.match_count() >= 1 then
        clink.match_display_filter = env_vars_display_filter
        clink.suppress_char_append()
        return true
    end

    return false
end

--------------------------------------------------------------------------------
clink.register_match_generator(env_vars_match_generator, 10)

-- vim: expandtab

--------------------------------------------------------------------------------
-- exec.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local match_style = 0
local dos_commands = {
    "assoc", "break", "call", "cd", "chcp", "chdir", "cls", "color", "copy",
    "date", "del", "dir", "diskcomp", "diskcopy", "echo", "endlocal", "erase",
    "exit", "for", "format", "ftype", "goto", "graftabl", "if", "md", "mkdir",
    "mklink", "more", "move", "path", "pause", "popd", "prompt", "pushd", "rd",
    "rem", "ren", "rename", "rmdir", "set", "setlocal", "shift", "start",
    "time", "title", "tree", "type", "ver", "verify", "vol"
}

--------------------------------------------------------------------------------
local function dos_cmd_match_generator(text, first, last)
    for _, cmd in ipairs(dos_commands) do
        if clink.is_match(text, cmd) then
            clink.add_match(cmd)
        end
    end
end

--------------------------------------------------------------------------------
local function dos_and_dir_match_generators(text, first, last)
    dos_cmd_match_generator(text, first, last)
    dir_match_generator(text, first, last)
end

--------------------------------------------------------------------------------
local function build_passes(text)
    local passes = {}

    -- If there's no path separator in text then consider the environment's path
    -- as a first pass for matches.
    if not text:find("[\\/:]") then
        local paths = clink.split(clink.get_env("PATH"), ";")

        -- We're expecting absolute paths and as ';' is a valid path character
        -- there maybe unneccessary splits. Here we resolve them.
        local paths_merged = { paths[1] }
        for i = 2, #paths, 1 do
            if not paths[i]:find("^[a-zA-Z]:") then
                local t = paths_merged[#paths_merged];
                paths_merged[#paths_merged] = t..paths[i]
            else
                table.insert(paths_merged, paths[i])
            end
        end

        -- Append slashes.
        for i = 1, #paths_merged, 1 do
            table.insert(paths, paths_merged[i].."\\")
        end

        -- Depending on match style add empty path so 'text' is used.
        if match_style > 0 then
            table.insert(paths, "")
        end

        -- Should directories be considered too?
        local extra_func = dos_cmd_match_generator
        if match_style > 1 then
            extra_func = dos_and_dir_match_generators
        end

        table.insert(passes, { paths=paths, func=extra_func })
    end

    -- The fallback solution is to use 'text' to find matches, and also add
    -- directories.
    table.insert(passes, { paths={""}, func=dir_match_generator })

    return passes
end

--------------------------------------------------------------------------------
local function exec_match_generator(text, first, last)
    -- We're only interested in exec completion if this is the first word of the
    -- line, or the first word after a command separator.
    local leading = rl_line_buffer:sub(1, first - 1)
    local is_first = leading:find("^%s*\"*$")
    local is_separated = leading:find("[|&]%s*\"*$")
    if not is_first and not is_separated then
        return false
    end

    -- Strip off possible trailing extension.
    local needle = text
    local ext_a, ext_b = needle:find("%.[a-zA-Z]*$")
    if ext_a then
        needle = needle:sub(1, ext_a - 1)
    end

    -- Strip off any path components that may be on text
    local prefix = ""
    local i = text:find("[\\/:][^\\/:]*$")
    if i then
        prefix = text:sub(1, i)
    end

    match_style = clink.get_setting_int("exec_match_style")
    local passes = build_passes(text)

    -- Combine extensions, text, and paths to find matches - this is done in two
    -- passes, the second pass possibly being "local" if the system-wide search
    -- didn't find any results.
    local n = #passes
    local exts = clink.split(clink.get_env("PATHEXT"), ";")
    for p = 1, n do
        local pass = passes[p]
        for _, ext in ipairs(exts) do
            for _, path in ipairs(pass.paths) do
                local mask = path..needle.."*"..ext
                for _, file in ipairs(clink.find_files(mask, true)) do
                    file = prefix..file
                    if clink.is_match(text, file) then
                        clink.add_match(file)
                    end
                end
            end
        end
        
        if pass.func then
            pass.func(text, first, last)
        end

        -- Was there matches? Then there's no need to make any further passes.
        if clink.match_count() > 0 then
            break
        end
    end

    return true
end

--------------------------------------------------------------------------------
clink.register_match_generator(exec_match_generator, 50)

-- vim: expandtab

--------------------------------------------------------------------------------
-- git.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local git_argument_tree = {
    -- Porcelain and ancillary commands from git's man page.
    "add", "am", "archive", "bisect", "branch", "bundle", "checkout",
    "cherry-pick", "citool", "clean", "clone", "commit", "describe", "diff",
    "fetch", "format-patch", "gc", "grep", "gui", "init", "log", "merge", "mv",
    "notes", "pull", "push", "rebase", "reset", "revert", "rm", "shortlog",
    "show", "stash", "status", "submodule", "tag", "config", "fast-export",
    "fast-import", "filter-branch", "lost-found", "mergetool", "pack-refs",
    "prune", "reflog", "relink", "remote", "repack", "replace", "repo-config",
    "annotate", "blame", "cherry", "count-objects", "difftool", "fsck",
    "get-tar-commit-id", "help", "instaweb", "merge-tree", "rerere",
    "rev-parse", "show-branch", "verify-tag", "whatchanged"
}

clink.arg.register_tree("git", git_argument_tree)

-- vim: expandtab

--------------------------------------------------------------------------------
-- hg.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local hg_tree = {
    "add", "addremove", "annotate", "archive", "backout", "bisect", "bookmarks",
    "branch", "branches", "bundle", "cat", "clone", "commit", "copy", "diff",
    "export", "forget", "grep", "heads", "help", "identify", "import",
    "incoming", "init", "locate", "log", "manifest", "merge", "outgoing",
    "parents", "paths", "pull", "push", "recover", "remove", "rename", "resolve",
    "revert", "rollback", "root", "serve", "showconfig", "status", "summary",
    "tag", "tags", "tip", "unbundle", "update", "verify", "version", "graft",
    "phases"
}

clink.arg.register_tree("hg", hg_tree)

-- vim: expandtab

--------------------------------------------------------------------------------
-- p4.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local p4_tree = {
    "add", "annotate", "attribute", "branch", "branches", "browse", "change",
    "changes", "changelist", "changelists", "client", "clients", "copy",
    "counter", "counters", "cstat", "delete", "depot", "depots", "describe",
    "diff", "diff2", "dirs", "edit", "filelog", "files", "fix", "fixes",
    "flush", "fstat", "grep", "group", "groups", "have", "help", "info",
    "integrate", "integrated", "interchanges", "istat", "job", "jobs", "label",
    "labels", "labelsync", "legal", "list", "lock", "logger", "login",
    "logout", "merge", "move", "opened", "passwd", "populate", "print",
    "protect", "protects", "reconcile", "rename", "reopen", "resolve",
    "resolved", "revert", "review", "reviews", "set", "shelve", "status",
    "sizes", "stream", "streams", "submit", "sync", "tag", "tickets", "unlock",
    "unshelve", "update", "user", "users", "where", "workspace", "workspaces"
}

clink.arg.register_tree("p4", p4_tree)

-- vim: expandtab

--------------------------------------------------------------------------------
-- self.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local self_tree = clink.arg.tree_node("*", {
    "--help",
    inject = clink.arg.tree_node("*+", {
        "--scripts", "--help", "--quiet", "--althook"
    }),
    autorun = clink.arg.tree_node("*+", {
        "--install", "--uninstall", "--show", "--value"
    }),
})

clink.arg.register_tree("clink", self_tree)

-- vim: expandtab

--------------------------------------------------------------------------------
-- set.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local function set_match_generator(text, first, last)
    -- Skip this generator if first is in the rvalue.
    local leading = rl_line_buffer:sub(1, first - 1)
    if leading:find("=") then
        return false;
    end

    -- Enumerate environment variables and check for potential matches.
    for _, name in ipairs(clink.get_env_var_names()) do
        if clink.is_match(text, name) then
            clink.add_match(name:lower())
        end
    end

    -- If there was only one match, add a '=' on the end.
    if clink.match_count() == 1 then
        --clink.set_match(1, clink.get_match(1).."=")
        clink.suppress_char_append()
    end

    return true
end

--------------------------------------------------------------------------------
clink.arg.register_tree("set", set_match_generator)

-- vim: expandtab

--------------------------------------------------------------------------------
-- svn.lua
--

--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
local svn_tree = {
    "add", "blame", "praise", "annotate", "ann", "cat", "changelist", "cl",
    "checkout", "co", "cleanup", "commit", "ci", "copy", "cp", "delete", "del",
    "remove", "rm", "diff", "di", "export", "help", "h", "import", "info",
    "list", "ls", "lock", "log", "merge", "mergeinfo", "mkdir", "move", "mv",
    "rename", "ren", "propdel", "pdel", "pd", "propedit", "pedit", "pe",
    "propget", "pget", "pg", "proplist", "plist", "pl", "propset", "pset", "ps",
    "resolve", "resolved", "revert", "status", "stat", "st", "switch", "sw",
    "unlock", "update", "up"
}

clink.arg.register_tree("svn", svn_tree)

-- vim: expandtab
