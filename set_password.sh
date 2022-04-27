cd 
awk 'i++ == 4 {print $3}'  /etc/mysql/debian.cnf > alpha.sh
export val1=$(cat alpha.sh)
