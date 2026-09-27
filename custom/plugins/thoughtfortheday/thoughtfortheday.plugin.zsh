function thoughtfortheday() {
  # Display the thought for the day
  TFTD_DISPLAY_DATE=$(date '+%A, %b %d')
  TFTD_DATE=$(date +%Y-%m-%d)
  TFTD_URL='https://www.hazeldenbettyford.org/content/hbff/us/en/thought-for-the-day/jcr:content/root/container/container/thoughtdaysection.'$TFTD_DATE'.json'
  printf "   ${TFTD_DISPLAY_DATE}"
  curl -s -S $TFTD_URL \
    | jq '.data[] | select(.id | contains("twenty-four-hours-a-day")) | {title,date,day,actualDate,reading}' \
    | jq .reading | tr -d '""' \
    | sed 's/\\n//g' \
    | lynx -dump -stdin

}

alias tftd='echo -e "\033[1;32m$(thoughtfortheday)"'

if (( $+commands[thoughtfortheday] )); then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C thoughtfortheday thoughtfortheday
fi
