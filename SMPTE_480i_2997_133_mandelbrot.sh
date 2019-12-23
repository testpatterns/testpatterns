#! /usr/bin/env bash

# set +x

TEMPFOLDER="tmp"
rm -rf "${TEMPFOLDER:?}/*"
mkdir -p ${TEMPFOLDER}
# TEMPFOLDER="${TMPDIR}" # When using POSIX
LOGLEVEL="info"
TESTPATTERN="mandelbrot"
# TESTPATTERN="smptebars"
# TESTPATTERN="smptehdbars"
# TESTPATTERN="color"
# TESTPATTERN="testsrc"
# TESTPATTERN="testsrc2"
# TESTPATTERN="random" # Note: Not an FFmpeg test source
FONTFILE="/Library/Fonts/Courier\ New.ttf"
PIX_FMT="yuv422p"
CONSTANTRATEFACTOR=23
VIDEOPRESET="medium"
OUTPUTFOLDER="output"
OUTPUTBASENAME="SMPTE_480i_nonsquare_133_bt601_${PIX_FMT}_${TESTPATTERN}"
# INTERLACED=true
# OUTPUTWIDTH=480
# OUTPUTHEIGHT=704
# OUTPUTDISPLAYASPECTRATIO="4/3"
OUTPUTFIELDRATE="60*1000/1001"
OUTPUTFRAMERATE="30*1000/1001"
GUID=$(uuidgen)
PROVIDERNAME="My Provider Name"
SERVICENAME="My Service Name"
NETWORKNAME="My TV Network Name"
SERIESNAME="My Test Patterns"
ESPISODENUMBER="Episode Number 01"
TITLE="480i 29.97 10:11 BT.601 ${TESTPATTERN}"
DESCRIPTION="Standard Definition. Non-square pixels. BT.601 color space. ${PIX_FMT} pixel format. ${OUTPUTFIELDRATE} fields per second, interlaced within ${OUTPUTFRAMERATE} frames per seconds.  Requires deinterlacing by the device during playback."
COMMENT="My Comment."
REELNAME="My Reel Name"
HOMEPAGE="https://github.com/testpatterns/testpatterns"
YEAR=$(date '+%Y')
DURATION="00:00:10.000"
# Maxfilesize for Github
MAXFILESIZE="80000000"
# MAXFILESIZE="-1"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
SMPTETIMECODEOFFSET="01:00:00;00"

FFREPORT="file=${TEMPFOLDER}/${OUTPUTBASENAME}_%p_%t.ffreport:level=32" ffmpeg -y -hide_banner \
-report -loglevel "${LOGLEVEL}" \
-stats -vstats -vstats_file "${TEMPFOLDER}/${OUTPUTBASENAME}_ffvstats_${TIMESTAMP}.ffvstats" \
-progress "${TEMPFOLDER}/${OUTPUTBASENAME}_ffprogress_${TIMESTAMP}.ffprogress" -benchmark \
-f "lavfi" -i "${TESTPATTERN}=size=640x480:rate=${OUTPUTFIELDRATE},format=pix_fmts=${PIX_FMT},\
drawtext=fontfile=${FONTFILE}:fontcolor=white:fontsize=32:box=1:boxcolor=black:text='%{frame_num}':start_number=1:x=(main_w-text_w)/2:y=0,\
interlace=scan=tff,\
setparams=field_mode=tff:range=tv:color_primaries=smpte170m:color_trc=smpte170m:colorspace=smpte170m,\
drawtext=fontfile=${FONTFILE}:timecode='01\:00\:00\;00':timecode_rate=${OUTPUTFRAMERATE}:fontcolor=white:fontsize=32:box=1:boxcolor=black:x=(main_w-text_w)/2:y=main_h-text_h,\
scale=width=704:height=480:in_color_matrix=auto:in_range=auto:out_color_matrix=bt601:out_range=tv:flags=lanczos:interl=-1,\
setdar=dar=4/3,\
setpts=expr=(PTS-STARTPTS)" \
-f "lavfi" -i "anullsrc=sample_rate=48000,loudnorm=i=-24:tp=-2:lra=7,asetpts=expr=(PTS-STARTPTS)" \
-map "0:v:0" \
-c:v "libx264" -crf:v "${CONSTANTRATEFACTOR}" -preset:v "${VIDEOPRESET}" -vsync:v "cfr" \
-flags:v "+ildct+ilme" -top:v "1" -field_order:v "tt" -weightp:v "0" \
-pix_fmt:v "${PIX_FMT}" -colorspace:v "bt709" -color_primaries:v "bt709" -color_trc:v "bt709" -color_range:v "tv" \
-map "1:a:0" -c:a "pcm_s16le" -ac "2" -ar "48000" \
-metadata:g provider_name="${PROVIDERNAME}" \
-metadata:g service_name="${SERVICENAME}" \
-metadata:g network="${NETWORKNAME}" \
-metadata:g show="${SERIESNAME}" \
-metadata:g episode_id="${ESPISODENUMBER}" \
-metadata:g guid="${GUID}" \
-metadata:g title="${TITLE}" \
-metadata:g description="${DESCRIPTION}" \
-metadata:g comment="${COMMENT}" \
-metadata:g reel_name="${REELNAME}" \
-metadata:g author="${HOMEPAGE}" \
-metadata:g year="${YEAR}" \
-metadata:g date="${TIMESTAMP}" \
-metadata:s:v arbitraryvideotag="An arbitrary video metadata tag" \
-metadata:s:a arbitraryaudiotag="An arbitrary audio metadata tag" \
-metadata:s:a language="eng" \
-metadata:s:d language="eng" \
-metadata:s:d reel_name="${REELNAME}" \
-metadata:s:d arbitrarytag="An arbitrary data metadata tag" \
-t ${DURATION} -fs ${MAXFILESIZE} -timecode "${SMPTETIMECODEOFFSET}" \
-f "tee" \
"[onfail=ignore:f=mxf]${OUTPUTFOLDER}/${OUTPUTBASENAME}.mxf|\
[onfail=ignore:f=ffmetadata]${OUTPUTFOLDER}/${OUTPUTBASENAME}.ffmetadata"

# [onfail=ignore:f=mov:movflags=+faststart:write_tmcd=on]${OUTPUTFOLDER}/${OUTPUTBASENAME}.mov|\

sleep 2
# FFREPORT="file=${TEMPFOLDER}/${OUTPUTBASENAME}_%p_%t.ffreport:level=32"
ffprobe -hide_banner -loglevel "${LOGLEVEL}" -print_format "json" -i "${OUTPUTFOLDER}/${OUTPUTBASENAME}.mxf" -show_versions -show_streams -show_format -show_programs > "${OUTPUTFOLDER}/${OUTPUTBASENAME}_ffprobe.json"

ffmpeg -y -hide_banner -loglevel "error" -i "${OUTPUTFOLDER}/${OUTPUTBASENAME}.mxf" -vf "scale=width=192:height=144" -vframes "1" -f "image2" "${OUTPUTFOLDER}/${OUTPUTBASENAME}_192x144.png"

exit 0
