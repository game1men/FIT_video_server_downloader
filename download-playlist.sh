 # !/bin/bash
 # - je potreba vyplnit prihlasovaci udaje v login.sh
 # - stahne kompletni predmet
 # - je potreba stahovat do slozky ve ktere nejsou zadne soubory *.mp4* jelikoz je program pouziva k
 #   zjisteni progresu TODO: udelat to lip
 # - spusteni ./download-playlist "url predmetu na video serveru" "cesta kam ulozit soubory"
path=$2
url=$1


./login.sh

videoserver=$(echo $url | grep -o 'video[0-9]') #  asi zbytečny TODO: zjisti

./login.sh "$url" #  asi zbytečny TODO: zjisti

 #  ziska prihlasovaci cookies a stahne stranku, pro vyparsovani videi TODO: misto souboru to uloz to stringu
cookieName=$(grep $videoserver c.txt | awk 'END {print $6}')
cookie=$(grep $videoserver c.txt | awk 'END {print $7}')
wget -O "temp/records.html" -L $url \
--header 'Referer: https://video1.fit.vutbr.cz/' \
--header "Cookie: _ga=GA1.2.118848597.1643907515; $cookieName=$cookie" \  # TODO: zjisti jestli je GA cookie potreba


 # vyparsuje ze stranky url adresy
arr=($(grep 'records.php' 'temp/records.html'  --text | grep -Po '(?<=href=")[^"]*'))

x=0
fileCount=$(($(ls 2> /dev/null -1q $path*.mp4* | wc -l)))  # zjisti pocet souboru ve slozce

  # projizdi nacteny url adresy
for i in "${arr[@]}"
do
     # preskovi jiz nacteny videa
    if [ $fileCount -ge $x ]
    then
       ((x++))
        continue
    fi


     #  ziska prihlasovaci cookies a stahne stranku, pro vyparsovani videi(tentokrat pro vyber kvality) TODO: misto souboru to uloz to stringu
    videoserver=$(echo $url | grep -o 'video[0-9]')
    cookieName=$(grep $videoserver c.txt | awk 'END {print $6}')
    cookie=$(grep $videoserver c.txt | awk 'END {print $7}')

    var="https://video1.fit.vutbr.cz/av/$i"

    wget -q -O "temp/records.html" -L $var \
    --header 'Referer: https://video1.fit.vutbr.cz/' \
    --header "Cookie: _ga=GA1.2.118848597.1643907515; $cookieName=$cookie" \




     # vyparsuje ze stranky url adresy
    arr2=($(grep 'record-download' 'temp/records.html'  --text | grep -Po '(?<=href=")[^"]*'))

     # vybere druhou nejlepsi kvalitu
    if [ ${#arr2[@]} -gt 1 ]
    then
        var=${arr2[2]}

    else
        var=${arr2[1]}
    fi

     # prihlasi se na spravny video server
    ./login.sh "$var";
    videoserver=$(echo $var  | grep -o 'video[0-9]')
    cookieName=$(grep $videoserver c.txt | awk 'END {print $6}')
    cookie=$(grep $videoserver c.txt | awk 'END {print $7}')

     # stahne video
    wget -P "$path"  --content-disposition -L "$var" \
    --header 'Referer: https://video1.fit.vutbr.cz/' \
    --header "Cookie: _ga=GA1.2.118848597.1643907515; $cookieName=$cookie" \

done
