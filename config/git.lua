---
 -- Display the amount of dirt
 -- @return {false|number of changes}
---
function get_dirt()
    local statuses = ""
    for line in io.popen("git status --porcelain"):lines() do
        local m = line:match("[MADRCU?!][?]?%s+.*")
        if m then statuses = statuses .. " " .. m end
    end
    return statuses
end

---
 -- Find out current branch
 -- @return {false|git branch name}
---
function get_git_branch()
    for line in io.popen("git branch 2>nul"):lines() do
        local m = line:match("%* (.+)$")
        if m then
            return m
        end
    end

    return false
end

---
 -- Get the status of working dir
 -- @return {bool}
---
function get_git_status()
    return os.execute("git diff-files --quiet --ignore-submodules")
end

function git_prompt_filter()

    -- Colors for git status
    -- Todo: Add more colors. Green?
    local colors = {
        clean = "\x1b[1;37;40m",
        dirty = "\x1b[31;1m",
    }

    local branch = get_git_branch()

    if branch then
        -- Has branch => therefore it is a git folder, now figure out status
        if get_git_status() then
            color = colors.clean
        else
            color = colors.dirty
        end

        clink.prompt.value = string.gsub(clink.prompt.value, "{git}", color.."("..branch..")")

        -- print(get_dirt())

        return true
    else
        -- No git present or not in git folder
        clink.prompt.value = string.gsub(clink.prompt.value, "{git}", "")

        return false
    end
end

clink.prompt.register_filter(git_prompt_filter, 50)
-- print("Hello!")
