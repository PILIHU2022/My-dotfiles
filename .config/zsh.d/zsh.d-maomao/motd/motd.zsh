local this="${0:A:h}"

local function slow_scan_line_print_title(){
    for s (${(f)"$(<${this}/title.txt)"}) {
        print "$s"
        sleep "0.01s"
    }
}

local function slow_scan_print_hitokoto() {
    local s="
$(. ${this}/hitokoto.zsh)
"
#我猜猜为啥换行:(
    for i ({1..${#s}}) {
        print -n $s[$i]
        sleep "0.01s"
    }
}

clear
print -n "[?25l"
slow_scan_line_print_title | lolcat -F
fastfetch --pipe 0
slow_scan_print_hitokoto | lolcat -F
print -n "[?25h"
