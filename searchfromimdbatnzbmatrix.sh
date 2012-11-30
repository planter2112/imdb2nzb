#!/bin/bash

#### PUT The Following Data in config.txt
#IMDBUSERID="xxxxxxx"
#USER="xxxxxxx"
#MATRIXAPI="xxxxxxx"
#SUAPI="xxxxxxx"
###########################################
. config.txt

WATCHLIST="http://rss.imdb.com/user/$IMDBUSERID/watchlist"
NZBSEARCHURL="http://api.nzbmatrix.com/v1.1/search.php"
SUSEARCHURL="http://nzb.su/api/"
MINSIZE=200
MAXSIZE=100000
MAXAGE="1500"
MOVIE_CATEGORY="42"
TV_CATEGORY="6"
#MOVIE_CATEGORY="movies-all"
#TV_CATEGORY="tv-all"
LANGUAGE="german"
USERAGENT="Safari"
#curl -s --user-agent "Safari" 

### Categories
#5 TV SD (Image) 
#6 TV SD
#41 TV HD (x264)
#57 TV HD (Image)
#1 Movies SD (Image)
#2 Movies SD
#54 Movies HD (Remux)
#42 Movies HD (x264)
#50 Movies HD (Image)

#OLD -  we now use the IMDB ID -
#TV_ENTRIES=`curl -s --user-agent $USERAGENT $WATCHLIST | grep "<title" | egrep -v WATCHLIST | grep "TV Series" | sed 's|<title>||g' | sed 's|</title>||g' |  sed 's|^ *||g' | sed 's|\ (.*)$||g' | perl -MHTML::Entities -ne 'print decode_entities($_)' | perl -MURI::Escape -lne 'print uri_escape($_)'`
#MOVIE_ENTRIES=`curl -s --user-agent $USERAGENT $WATCHLIST | grep "<title" | egrep -v WATCHLIST | egrep -v "TV Series" | sed 's|<title>||g' | sed 's|</title>||g' | sed 's|^ *||g' | sed 's|\ (.*)$||g' | perl -MHTML::Entities -ne 'print decode_entities($_)' | perl -MURI::Escape -lne 'print uri_escape($_)'`

ENTRIES=`curl -s --user-agent $USERAGENT $WATCHLIST | grep '<link>http://www.imdb.com/title/.*/</link>' | sed 's|<link>http://www.imdb.com/title/tt\(.*\)/</link>|\1|' | awk '{ print $1 }'`

### Search in Lokal Directories here :
## TODO
#######################################

for ENTRY in $ENTRIES 
do
       # Search for Local Files should be implemented here : 
       ############# Search for Local Files ###############
       ####################################################
       # Search for Online Data :
       ##########################
       echo "Searching for $ENTRY:"
       URL="$NZBSEARCHURL?search=tt$ENTRY&searchin=weblink&larger=$MINSIZE&smaller=$MAXSIZE&age=$MAXAGE&username=$USER&apikey=$MATRIXAPI"
       #curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbmatrix_$ENTRY.found
       declare -a NAMES=(`cat /tmp/nzbmatrix_$ENTRY.found | grep ^NZBNAME | sed 's|^NZBNAME:\(.*\)$|\1|' | sed 's|;$||g' | tr " " "."`)
       declare -a LINKS=(`cat /tmp/nzbmatrix_$ENTRY.found | grep ^LINK | sed 's|^LINK:\(.*\)$|\1|' | sed 's|;$||g' | tr " " "."`)
       declare -a LANGUAGES=(`cat /tmp/nzbmatrix_$ENTRY.found | grep ^LANGUAGE | sed 's|^LANGUAGE:\(.*\)$|\1|' | sed 's|;$||g' | tr " " "."`)
       declare -a CATEGORIES=(`cat /tmp/nzbmatrix_$ENTRY.found | grep ^CATEGORY | sed 's|^NZBNAME:\(.*\)$|\1|' | sed 's|;$||g' | tr " " "."`)

	MAXVAL=`expr ${#NAMES[@]} - 1`
	echo "NzbMatrix Results: ${#NAMES[@]} found"
	for i in ${!NAMES[*]} 
	do
		if [ ${LANGUAGES,,} == "$LANGUAGE" ] ; then
			echo ${NAMES[$i]}
		else
			echo "NOT $LANGUAGE" 
		fi
	done

       URL="$SUSEARCHURL?t=movie&imdbid=$ENTRY&extended=1&cat=2050,2040,2010,5020,5040,5070,5030&apikey=$SUAPI"
       #curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbsu_$ENTRY.found
       declare -a NAMES=(`xpath -q -e /rss/channel/item/title /tmp/nzbsu_$ENTRY.found | sed 's|<title>\(.*\)</title>|\1|g' | tr ' ' '.'`)
       declare -a LINKS=(`xpath -q -e /rss/channel/item/link /tmp/nzbsu_$ENTRY.found | sed 's|<link>\(.*\)</link>|\1|g'`)

	MAXVAL=`expr ${#NAMES[@]} - 1`
	echo "Nzb.su Results: ${#NAMES[@]} found"
	for i in ${!NAMES[*]} 
	do
		GERMAN=`echo ${NAMES[$i]} | egrep -i $LANGUAGE `
		if [ -z $GERMAN ] ; then
			echo "NOT $LANGUAGE"
		else
			echo ${NAMES[$i]}
		fi
	done
	
	#echo ${LINKS[@]}
done
