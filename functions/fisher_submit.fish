function fisher_submit -d "Submit a plugin to the index" -a name info tags url
    switch "$name"
        case -h --help
            printf "Usage: fisher submit [name desc tags url] [--help]\n\n"
            printf "    -h --help      Show usage help\n"
            return
    end

    function __submit_run -a msg command
        if not spin "$command" -f "\r @ $msg\r\n" --error=/dev/null
            printf " × $msg\n"
            return 1
        end
        printf " ✓ $msg\n"
    end

    function __submit_cleanup -a path
        if test ! -z "$path" -a -d "$path"
            command rm -rf $path
        end
        functions -e __submit_cleanup __submit_run
    end



    set -l stderr /dev/stderr

    set -l gh_org fisherman
    set -l gh_repos https://api.github.com/repos
    set -l gh_forks $gh_repos/$gh_org/fisher-index/forks
    set -l gh_pulls $gh_repos/$gh_org/fisher-index/pulls





    if test -z "$name"
        if test "$PWD" = ~
            printf "%s\n" "submit: I need the name of a plugin to submit." > $stderr
            __submit_cleanup
            return 1
        end

        set name (pwd | __fisher_name)
    end




    if test -z "$info"
        set info "$name plugin"
    end

    if test -z "$tags"
        set tags "$name"
    end



    set -l gh_user (git config --get github.user)

    if test -z "$gh_user"
        set gh_user "$GITHUB_USERNAME"
    end

    if test -z "$gh_user"
        get -p "Enter your GitHub username:" | read gh_user
    end

    if test -z "$gh_user"
        printf "%s\n" "submit: I need your GitHub user name to continue." > $stderr
        __submit_cleanup
        return 1
    end


    if test -z "$url"
        set url "https://github.com/$gh_user/$name"
        # printf "%s\n" "submit: I need the URL of the plugin to submit." > $stderr
        # __submit_cleanup
        # return 1
    end



    set gh_pass "$GITHUB_ACCESS_TOKEN"

    if test -z "$gh_pass"
        set gh_pass (git config --get github.password)
    end

    if test -z "$gh_pass"
        get -sp "Enter password or access token for '$gh_user':" | read gh_pass
    end

    if test -z "$gh_pass"
        printf "%s\n" "submit: I need your GitHub password or access token to continue." > $stderr
        __submit_cleanup
        return 1
    end


    if not __submit_run "Forking the index with your GitHub account" "
        curl -sX POST -u \"$gh_user:$gh_pass\" $gh_forks > /dev/null
        "
        printf "%s\n" "submit: I couldn't fork the index with your GitHub account." > $stderr
        __submit_cleanup
        return 1
    end

    set -l path (mktemp -dt index.XXX)

    if test ! -d "$path"
        printf "%s\n" "submit: I couldn't create temporary directory for this operation." > $stderr
        __submit_cleanup "$path"
        return 1
    end

    if not __submit_run "Cloning your copy of the index" "
        while not git clone https://github.com/$gh_user/fisher-index $path --quiet
            printf '\rPlease wait a little more...\n' > $stderr
        end
    "
        printf "%s\n" "submit: I couldn't clone your copy of the index." > $stderr
        __submit_cleanup "$path"
        return 1
    end

    pushd $path
    printf "\n%s\n%s\n%s\n%s\n%s\n" "$name" "$url" "$info" "$tags" "$gh_user" >> index
    set -l submit_path (dirname (status -f))
    awk -v FS='\n' -v RS='' -v OFS=';' -f $submit_path/qs.awk index > _index

    command mv -f _index index


    if not __submit_run "Adding $name to the index" "
        pushd $path
        git add --all
        git commit -m 'Add $name.' --quiet
        git remote remove origin ^ /dev/null
        git remote add origin https://github.com/$gh_user/fisher-index
        git remote add upstream https://github.com/$gh_org/fisher-index
        git push origin master --quiet
    "
        printf "\n%s\n" "submit: I couldn't add $name to the index." > $stderr
        __submit_cleanup "$path"
        return 1
    end

    popd

    set -l body "Add $name"

    if not __submit_run "Creating a pull request for $name" "
        curl -X POST -u '$gh_user:$gh_pass' $gh_pulls -H 'Content-Type: application/json' -d '{\"title\":\"$body\",\"body\":\"$body\",\"head\":\"$gh_user:master\",\"base\":\"master\"}'
        curl -sX DELETE -u '$gh_user:$gh_pass' https://api.github.com/repos/$gh_user/fisher-index >/dev/null
    " | awk '
        /"href":/ {
            k++
            gsub("^ *\".*\": \"|\"", "")
            if (k > 1) {
                system("open "$0)
                exit
            }
        }
    '
        printf "%s\n" "submit: I couldn't create a pull request for $name." > $stderr
        __submit_cleanup "$path"
        return 1
    end

    __submit_cleanup "$path"
    printf " ✓\n"
end
