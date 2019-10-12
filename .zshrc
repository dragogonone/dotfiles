# brewとかのため
PATH=/usr/local/bin:$PATH

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

### COLORS
eval "$(/usr/local/opt/coreutils/libexec/gnubin/dircolors ~/.dircolors-solarized/dircolors.ansi-light)"
alias ls='gls --color=auto'
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

### 補完 ###
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
# 大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補をハイライト
zstyle ':completion:*:default' menu select=1

### aliases ###
## 基本
alias ll='ls -la'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias mv="mv -iv"
alias cp="cp -iv"
alias be='bundle exec'
alias chrome="open /Applications/Google\ Chrome.app"
alias agg='ag -g'
alias agq='ag -Q'
alias codeset="code ~/Library/Application\ Support/Code/User/settings.json"
alias z='cd-bookmark'

## git系
alias gad='git add'
alias gcm='git commit'
alias gcmm='git commit -m'
alias gst='git status'
alias gstc='git status | grep "modified:" | wc -l'
alias gpl='git pull origin'
alias gplc='git pull origin `git rev-parse --abbrev-ref HEAD`'
alias gbr='git branch'
alias gco='git checkout'
alias gbrco='git checkout -b'
alias glg='git log'
alias gsh='git stash'
alias gfh='git fetch -p'

### history ###
# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY

### man color ###
export MANPAGER='less -R'
man() {
	env \
		LESS_TERMCAP_mb="$(printf "\e[1;36m")" \
		LESS_TERMCAP_md="$(printf "\e[1;36m")" \
		LESS_TERMCAP_me="$(printf "\e[0m")" \
		LESS_TERMCAP_se="$(printf "\e[0m")" \
		LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
		LESS_TERMCAP_ue="$(printf "\e[0m")" \
		LESS_TERMCAP_us="$(printf "\e[1;32m")" \
		man "$@"
}

### less ###
export LESS="-mMR"

### exa ###
if type "exa" > /dev/null 2>&1; then
  alias ls='exa'
fi

### sshrc ###
if type "sshrc" > /dev/null 2>&1; then
  alias ssh='sshrc'
fi

### rbenv ###
if [ -d "${HOME}"/.rbenv ]; then
  eval "$(rbenv init -)"
fi

### pyenv ###
if [ -d "${HOME}"/.pyenv ]; then
  export PYENV_ROOT=$HOME/.pyenv
  export PATH=$PYENV_ROOT/bin:$PATH
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

### GO ###
# export GOROOT='/usr/local/opt/go/libexec'
# export GOPATH=$HOME
# export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
eval "$(goenv init -)"

# glob展開しない
setopt nonomatch

# cd毎回うたない
setopt auto_cd

### zplug ###
source ~/.zplug/init.zsh

# A next-generation cd command with an interactive filter
zplug "b4b4r07/enhancd", use:init.sh
# ENHANCD_HOOK_AFTER_CD=ls

# zsh theme
zplug "zsh-users/zsh-syntax-highlighting"

zplug "zsh-users/zsh-completions"

zplug "mollifier/cd-bookmark"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -r -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose >/dev/null

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# ブランチ名を色付きで表示させるメソッド
function prompt-git-current-branch {
  local branch_name st branch_status

  if ! git ls-files >& /dev/null; then
    echo "%F{white}%d %# "
    return
  fi
  branch_name=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  st=$(git status 2> /dev/null)
  if echo "$st" | grep -q "^nothing to"; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}"
  elif echo "$st" | grep -q "^Untracked files"; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif echo "$st" | grep -q "^Changes not staged for commit"; then
    # git addされていないファイルがある状態
    branch_status="%F{red}+"
  elif echo "$st" | grep -q "^Changes to be committed"; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}!"
  elif echo "$st" | grep -q "^rebase in progress"; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}"
  fi

  local stash_count
  stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$stash_count" -gt 0 ]; then
    # ブランチ名を色付きで表示する
    echo "${branch_status}[$branch_name]{$stash_count} %F{white}%d %# "
  else
    echo "${branch_status}[$branch_name] %F{white}%d %# "
  fi
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# プロンプトの左側(PROMPT)にメソッドの結果を表示させる
# shellcheck disable=SC2034 disable=SC2016
PROMPT='$(prompt-git-current-branch)'
# shellcheck disable=SC2034
RPROMPT=''

# ローカルPCでしか使わない設定を別ファイルに定義
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
