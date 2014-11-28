function lambda_prompt_filter()
    time = string.gsub(os.date("%I:%M"), "^0", "")
    clink.prompt.value = string.gsub(clink.prompt.value, "{time}", time)
end

clink.prompt.register_filter(lambda_prompt_filter, 40)
