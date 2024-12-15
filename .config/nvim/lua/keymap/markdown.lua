local map = require("core.keymap_script")
local function markdown_keymap()
    map.i({
        ["《"] = "《》<Esc>i",
        ["》"] = "> ",
        ["（"] = "（）<Esc>i",
        ["“"] = "“”<Esc>i",
        ["”"] = "“”<Esc>i",
        [",b"] = "****<Esc>F*ha",
        [",s"] = "~~~~<Esc>F~ha",
        [",h"] = "====<Esc>F=ha",
        [",i"] = "**<Esc>F*a",
        [",d"] = "``<++><Esc>F`a",
        [",c"] = "```<Enter><Enter>```<Esc>kA",
        [",m"] = "- [ ] ",
        [",p"] = "![]()<Esc>F[a",
        [",a"] = "[]()<Esc>F[a",
        [",l"] = "--- ",
        [",t"] = "[toc]",
        [",1"] = "#<Space>",
        [",2"] = "##<Space>",
        [",3"] = "###<Space>",
        [",4"] = "####<Space>",
        [",5"] = "#####<Space>",
    }, { buffer = true })
    map.n({
        -- Markview
        ["<C-m>"] = ":Markview splitToggle<CR>",
    }, { buffer = true })
end
return markdown_keymap()
