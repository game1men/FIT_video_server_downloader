
url=$1
username=""
password=""

#pokud je potreba cookie k jakemukoli serveru zadanemu v url, tak ho ziska pokud ne tak ziska zakladni cookies
if [ "$url" == "" ]
then
    #ziska cookie
    curl -s -c c.txt 'https://cas.fit.vutbr.cz/' \
    -H 'Referer: https://cas.fit.vutbr.cz/logout.cgi' \
    --compressed > /dev/null

    #prihlasi se pomoci ziskane cookie
    curl -s -L -b c.txt -c c.txt 'https://cas.fit.vutbr.cz/cosign.cgi' \
    -H 'Origin: https://cas.fit.vutbr.cz' \
    -H 'Referer: https://cas.fit.vutbr.cz/' \
    --data-raw "login=$username&password=$password&doLogin=Log+In&required=&useKX509=0&ref=&service=" \
    --compressed > /dev/null

    #ziska cookie k prihlaseni na video1 protoze ten je potreba vzdycky
    curl -s -L -b c.txt -c c.txt "https://cas.fit.vutbr.cz/?cosign-FIT-VIDEO4&https://video1.fit.vutbr.cz/av/record-download.php" \
    --compressed > /dev/null
else
    videoserver=$(echo $url | grep -o 'video[0-9]')
    curl -s -L -b c.txt -c c.txt "https://cas.fit.vutbr.cz/?cosign-FIT-VIDEO4&https://$videoserver.fit.vutbr.cz/av/record-download.php" \
    --compressed > /dev/null
fi