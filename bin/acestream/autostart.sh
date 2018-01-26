#!/bin/sh

. /etc/profile
oe_setup_addon service.system.acestreammedia

log(){   
   IS_DEBUG=$is_debug
   [ -z $IS_DEBUG ] && IS_DEBUG="false"
   [ $IS_DEBUG == "true" ] && echo "$(date +"%y-%m-%d %T")|"service.system.acestreammedia"|$(basename "$0")|$@" >> $LOG
}

ACEDIR=$(readlink -f $(dirname $0))
ACECHROOT="androidfs"
LOG="$ACEDIR/aceaddon.log"

log " ===================== RESTART Ace Stream Media (LibreELEC ARM7) ========================"

log "Directory Ace Strean Engine: $ACEDIR"
log "Directory croot: $ACEDIR/$ACECHROOT"

chmod +x $ACEDIR/acestream.start
chmod +x $ACEDIR/autostart.sh
chmod +x $ACEDIR/acestream.stop
chmod +x $ACEDIR/mount_disk.sh
chmod +x $ACEDIR/$ACECHROOT/system/bin/* $ACEDIR/$ACECHROOT/acestream.engine/python/bin/python

PARAMETER_CACHE_DIR="/storage/.ACEStream"

LIVE_CACHE_TYPE=$live_cache_type
VOD_CACHE_TYPE=$vod_cache_type
ACCESS_TOKEN=$access_token
TOTAL_MAX_DOWNLOAD_RATE=$total_max_download_rate
TOTAL_MAX_UPLOAD_RATE=$total_max_upload_rate
MEMORY_CACHE_LIMIT=$memory_cache_limit
MAX_PEERS=$max_peers
MAX_CONNECTS=$max_connects
LIVE_BUFFER_TIME=$live_buffer_time
PLAYER_BUFFER_TIME=$player_buffer_time
DISK_CACHE_LIMIT=$disk_cache_limit
IS_DEBUG=$is_debug
IS_EXPERIMENT=$is_experiment
PLAYLIST_OUTPUT_FORMAT_VOD=$playlist_output_format_vod
PLAYLIST_OUTPUT_FORMAT_LIVE=$playlist_output_format_live
[ $allow_intranet_access = "true" ] && ALLOW_INTRANET_ACCESS=1
[ $allow_intranet_access = "false" ] && ALLOW_INTRANET_ACCESS=0
[ $allow_remote_access = "true" ] && ALLOW_REMOTE_ACCESS=1
[ $allow_remote_access = "false" ] && ALLOW_REMOTE_ACCESS=0
LOGIN=$login
PASSWORD=$password

log "allow_intranet_access=$allow_intranet_access; allow_remote_access=$allow_remote_access"

[ -z "$LIVE_CACHE_TYPE" ] && LIVE_CACHE_TYPE="memory"
[ -z "$VOD_CACHE_TYPE" ] && VOD_CACHE_TYPE="memory"
[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN="WEBUITOKEN"
[ -z "$TOTAL_MAX_DOWNLOAD_RATE" ] && TOTAL_MAX_DOWNLOAD_RATE=0
[ -z "$TOTAL_MAX_UPLOAD_RATE" ] && TOTAL_MAX_UPLOAD_RATE=0
[ -z "$MEMORY_CACHE_LIMIT" ] && MEMORY_CACHE_LIMIT=150
[ -z "$MAX_PEERS" ] && MAX_PEERS=50
[ -z "$MAX_CONNECTS" ] && MAX_CONNECTS=500
[ -z "$LIVE_BUFFER_TIME" ] && LIVE_BUFFER_TIME=20
[ -z "$PLAYER_BUFFER_TIME" ] && PLAYER_BUFFER_TIME=5
[ -z "$DISK_CACHE_LIMIT" ] && DISK_CACHE_LIMIT=5
[ -z "$IS_DEBUG" ] && IS_DEBUG="false"
[ -z "$IS_EXPERIMENT" ] && IS_EXPERIMENT="false"
[ -z "$PLAYLIST_OUTPUT_FORMAT_VOD" ] && PLAYLIST_OUTPUT_FORMAT_VOD="http"
[ -z "$PLAYLIST_OUTPUT_FORMAT_LIVE" ] && PLAYLIST_OUTPUT_FORMAT_LIVE="auto"
[ -z "$ALLOW_INTRANET_ACCESS" ] && ALLOW_INTRANET_ACCESS=1
[ -z "$ALLOW_REMOTE_ACCESS" ] && ALLOW_REMOTE_ACCESS=0
[ -z "$LOGIN" ] && LOGIN="ACESTREAM_LOGIN"
[ -z "$PASSWORD" ] && PASSWORD="ACESTREAM_PASSW"

/usr/bin/python - <<END
import pickle
playerconf = {}
playerconf['live_cache_type']="$LIVE_CACHE_TYPE"
playerconf['vod_cache_type']="$VOD_CACHE_TYPE"
playerconf['memory_cache_limit']=$MEMORY_CACHE_LIMIT*1024*1024
playerconf['max_peers']=$MAX_PEERS
playerconf['max_connects']=$MAX_CONNECTS
playerconf['live_buffer_time']=$LIVE_BUFFER_TIME
playerconf['player_buffer_time']=$PLAYER_BUFFER_TIME
playerconf['disk_cache_limit']=$DISK_CACHE_LIMIT*1024*1024*1024
playerconf['allow_intranet_access']=$ALLOW_INTRANET_ACCESS
playerconf['allow_remote_access']=$ALLOW_REMOTE_ACCESS
playerconf['playlist_output_format_vod']="$PLAYLIST_OUTPUT_FORMAT_VOD"
playerconf['playlist_output_format_live']="$PLAYLIST_OUTPUT_FORMAT_LIVE"
isexper = "$IS_EXPERIMENT"
sdump = pickle.dumps(playerconf,0)
playerconf_pickle = open('$ACEDIR/playerconf.pickle', 'wt')
playerconf_pickle.write(sdump)
playerconf_pickle.close()
END

if [ $IS_DEBUG == "true" ]; then
   PLAYERCONF_PICKLE="live_cache_type=$LIVE_CACHE_TYPE;vod_cache_type=$VOD_CACHE_TYPE;memory_cache_limit=$(($MEMORY_CACHE_LIMIT * 1024 * 1024));max_peers=$MAX_PEERS;max_connects=$MAX_CONNECTS;live_buffer_time=$LIVE_BUFFER_TIME;player_buffer_time=$PLAYER_BUFFER_TIME;disk_cache_limit=$(($DISK_CACHE_LIMIT * 1024 * 1024 * 1024));allow_intranet_access=$ALLOW_INTRANET_ACCESS;allow_remote_access=$ALLOW_REMOTE_ACCESS;playlist_output_format_vod=$PLAYLIST_OUTPUT_FORMAT_VOD;playlist_output_format_live=$PLAYLIST_OUTPUT_FORMAT_LIVE"
   log "playerconf.pickle|$PLAYERCONF_PICKLE"
   if [ $IS_EXPERIMENT == "true" ]; then
      PLAYERCONF_PICKLE=""
     log "playerconf.pickle|is_experiment|$PLAYERCONF_PICKLE"
   fi
fi

ARG="--client-console \
     --bind-all \
	 --login $LOGIN \
     --password $PASSWORD \
	 --access-token $ACCESS_TOKEN \
	 --cache-dir $PARAMETER_CACHE_DIR \
	 --state-dir $PARAMETER_CACHE_DIR \
	 --download-limit $TOTAL_MAX_DOWNLOAD_RATE \
	 --upload-limit $TOTAL_MAX_UPLOAD_RATE \
	 --max-peers-limit 100 \
     --max-upload-slots 10 \
     --stats-report-interval 2 \
     --slots-manager-use-cpu-limit 1 \
     --core-dlr-periodic-check-interval 5 \
     --check-live-pos-interval 5 \
     --refill-buffer-interval 1 \
     --core-skip-have-before-playback-pos 1 \
     --webrtc-allow-outgoing-connections 1 \
	 --vod-drop-max-age 120"
	 
if [ $IS_DEBUG == "true" ]; then
    ARG_DEBUG="--log-debug 1 --log-modules root:D --debug-profile"
else
    ARG_DEBUG="--log-debug 0"
fi

log $ARG $ARG_DEBUG

$ACEDIR/acestream.start $ARG $ARG_DEBUG

