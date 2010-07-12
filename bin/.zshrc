
# This goes into your e.g. .zshrc file

alias workmode="figlet 'You really want to get stuff done? Then DO IT!!!'; su -c 'cp -v /etc/hosts.block /etc/hosts' "
alias playmode="figlet 'Do NOT waste your TIME!!!'; su -c 'cp -v /etc/hosts.original /etc/hosts' "


# This script will check that /etc/hosts blocks certain sites during e.g. 10:30 - 20:00.
# This should help to increase productivity. It is executed everytime you open a console.
ruby ~/bin/checkworktimehosts.rb

