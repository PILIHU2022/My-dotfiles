-- For `git.yazi`
th.git = th.git or {}
th.git.added_sign = "A"
th.git.ignored_sign = "I"
th.git.updated_sign = "U"
th.git.untracked_sign = "?"
th.git.modified_sign = "M"
th.git.deleted_sign = "D"

require("git"):setup()
