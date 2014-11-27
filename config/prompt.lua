function lambda_prompt_filter()
    clink.prompt.value = string.gsub(clink.prompt.value, "{time}", string.gsub(os.date("%I:%M"), "^0", ""))
end

clink.prompt.register_filter(lambda_prompt_filter, 40)
