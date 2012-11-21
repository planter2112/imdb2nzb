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



TV_ENTRIES=`curl -s --user-agent $USERAGENT $WATCHLIST | grep "<title" | egrep -v WATCHLIST | grep "TV Series" | sed 's|<title>||g' | sed 's|</title>||g' |  sed 's|^ *||g' | sed 's|\ (.*)$||g' | perl -MHTML::Entities -ne 'print decode_entities($_)' | perl -MURI::Escape -lne 'print uri_escape($_)'`
MOVIE_ENTRIES=`curl -s --user-agent $USERAGENT $WATCHLIST | grep "<title" | egrep -v WATCHLIST | egrep -v "TV Series" | sed 's|<title>||g' | sed 's|</title>||g' | sed 's|^ *||g' | sed 's|\ (.*)$||g' | perl -MHTML::Entities -ne 'print decode_entities($_)' | perl -MURI::Escape -lne 'print uri_escape($_)'`


### Search in Lokal Directories here :
## TODO
#######################################

# Search NZBMatrix and NZB.SU for TV-Shows an Movies
for ENTRY in $TV_ENTRIES 
do
	#URL="$NZBSEARCHURL?search=$ENTRY%20$LANGUAGE&searchin=name&cat=$CATEGORY&larger=$MINSIZE&smaller=$MAXSIZE&age=$MAXAGE&username=$USER&apikey=$API"
	echo "$ENTRY:"
	URL="$NZBSEARCHURL?search=$ENTRY&searchin=name&catid=$TV_CATEGORY&larger=$MINSIZE&smaller=$MAXSIZE&age=$MAXAGE&username=$USER&apikey=$MATRIXAPI"
	curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbmatrix_$ENTRY.found
	URL="$SUSEARCHURL?t=search&q=$ENTRY&extended=1&cat=2050,2040,2010&apikey=$SUAPI"
	#echo $URL
	curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbsu_$ENTRY.found
	sleep 1
done
for ENTRY in $MOVIE_ENTRIES
do
	#URL="$NZBSEARCHURL?search=$ENTRY%20$LANGUAGE&searchin=name&cat=$CATEGORY&larger=$MINSIZE&smaller=$MAXSIZE&age=$MAXAGE&username=$USER&apikey=$API"
	echo "$ENTRY:"
	URL="$NZBSEARCHURL?search=$ENTRY&searchin=name&catid=$MOVIE_CATEGORY&larger=$MINSIZE&smaller=$MAXSIZE&age=$MAXAGE&username=$USER&apikey=$MATRIXAPI"
	curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbmatrix_$ENTRY.found
	URL="$SUSEARCHURL?t=search&q=$ENTRY&extended=1&cat=5020,5040,5070,5030&apikey=$SUAPI"
	#echo $URL
	curl -s --user-agent $USERAGENT "$URL" > /tmp/nzbsu_$ENTRY.found
	sleep 1
done
