# time
function real_time() {
    local color="%{$FG[$((RANDOM%255+1))]%}";                   
    local time="[$(date +%H:%M:%S)]";
    local color_reset="%{$reset_color%}";
    echo "${color}${time}${color_reset}";
}

# directory
function directory() {
    local color="%{$fg_no_bold[cyan]%}";
    local directory="${PWD/#$HOME/~}";
    local color_reset="%{$reset_color%}";
    echo "${color}[${directory}]${color_reset}";
}

# git
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_no_bold[cyan]%}[🏑 git %{$FG[208]%}";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} ";
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_no_bold[cyan]%}] 💾";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_no_bold[cyan]%}]";

function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}

function git_status() {
    echo "${GIT_STATUS}"
}

# command
function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    COMMAND_RESULT=$1;
    export COMMAND_RESULT=$COMMAND_RESULT
    last_command=$(history | tail -1)
    lc="${last_command//[[:digit:]]/}"
    if $COMMAND_RESULT;
    then
        if [[ "$lc" =~ "   ls*" ]]; then
            arrow="%{$FG[202]%} ⚫%{$FG[149]%}⚫%{$FG[$((RANDOM%255+1))]%}λ 📂";
        else
            arrow="%{$FG[202]%} ⚫%{$FG[149]%}⚫%{$FG[$((RANDOM%255+1))]%}λ 📁";
        fi
    else
        arrow="%{$fg_bold[red]%} ⚫⚫λ";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo "${COMMAND_STATUS}"
}

preexec() {
    COMMAND_TIME_BEGIN="$(current_time_millis)";
}

current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        time_millis="$(date +%s.%3N)";
    fi
    echo $time_millis;
}

precmd() {
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi
    # update_git_status
    update_git_status;
    # update_command_status
    update_command_status $last_cmd_result;
}

# set option
setopt PROMPT_SUBST; 
# timer
TMOUT=1;
TRAPALRM() {
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}
clear;
PROMPT='%F{#FFBF00}🐧%f$(real_time) $(directory) $(git_status)$(command_status)';
RPROMPT="%(?.%{$fg[green]%}✔%f.%{$fg[red]%}✘%f)"
