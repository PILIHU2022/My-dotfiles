_fd() {
    local i cur prev opts cmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd=""
    opts=""

    for i in ${COMP_WORDS[@]}
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="fd"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        fd)
            opts="-H -I -u -s -i -g -F -a -l -L -p -0 -d -E -t -e -S -o -x -X -c -j -1 -q -h -V --hidden --no-hidden --no-ignore --ignore --no-ignore-vcs --ignore-vcs --no-require-git --require-git --no-ignore-parent --no-global-ignore-file --unrestricted --case-sensitive --ignore-case --glob --regex --fixed-strings --and --absolute-path --relative-path --list-details --follow --no-follow --full-path --print0 --max-depth --min-depth --exact-depth --exclude --prune --type --extension --size --changed-within --changed-before --owner --exec --exec-batch --batch-size --ignore-file --color --threads --max-buffer-time --max-results --quiet --show-errors --base-directory --path-separator --search-path --strip-cwd-prefix --one-file-system --gen-completions --help --version [pattern] [path]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --and)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-depth)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -d)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --min-depth)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exact-depth)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --type)
                    COMPREPLY=($(compgen -W "file directory symlink executable empty socket pipe" -- "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -W "file directory symlink executable empty socket pipe" -- "${cur}"))
                    return 0
                    ;;
                --extension)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -e)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --changed-within)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --changed-before)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --owner)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -o)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exec)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -x)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exec-batch)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -X)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --batch-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ignore-file)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always never" -- "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -W "auto always never" -- "${cur}"))
                    return 0
                    ;;
                --threads)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-buffer-time)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-results)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --base-directory)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --path-separator)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --search-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --gen-completions)
                    COMPREPLY=($(compgen -W "bash elvish fish powershell zsh" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

complete -F _fd -o bashdefault -o default fd
