
function prompt_char() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    echo "%{%F{cyan}%}±%{%f%k%b%} "
  else
    echo '%{%F{cyan}%}o%{%f%k%b%}'
  fi
}

# This theme works with both the "dark" and "light" variants of the
# Solarized color schema.  Set the SOLARIZED_THEME variable to one of
# these two values to choose.  If you don't specify, we'll assume you're
# using the "dark" variant.

case ${SOLARIZED_THEME:-dark} in
    light) bkg=white;;
    *)     bkg=black;;
esac

ZSH_THEME_GIT_PROMPT_PREFIX="%{%b%F{green}%}|"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%b%F{green}%}|"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{red}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{%b%F{green}%}✓"


PROMPT='%{%f%k%b%}
%{%B%F{cyan}%}%D{%Y-%m-%d} | %D{%L:%M:%S} | %{%F{magenta}%}%m %{%B%F{white}%}in %{%b%F{green}%}%~
$(prompt_char)%{%K{${bkg}}%}%{%b%F{green}%}$(git_prompt_info)%E%{%f%k%b%}%{%K{${bkg}}%} %b%F{green}→%{%f%k%b%} '

#RPROMPT='!%{%b%F{yellow}%}%!%'
