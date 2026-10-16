#!/usr/bin/env bash
# ascii_player.sh — odtwarzacz MP4 jako ASCII w terminalu
# Wymaga: ffmpeg, ffprobe, od, awk (opcjonalnie ffplay dla dźwięku)
set -euo pipefail

usage() {
  echo "Użycie: $0 [-w szer] [-f fps] [-c] [-s] [-l] plik.mp4"
  echo "  -w  szerokość w znakach (domyślnie: terminal)"
  echo "  -f  klatki/s (domyślnie 15)"
  echo "  -c  kolor (truecolor)"
  echo "  -s  dźwięk (ffplay)"
  echo "  -l  pętla"
  exit 1
}

FPS=15; COLOR=0; SOUND=0; LOOP=0
W=$(tput cols); ROWS=$(tput lines)
while getopts "w:f:csl" o; do
  case $o in
    w) W=$OPTARG ;; f) FPS=$OPTARG ;; c) COLOR=1 ;; s) SOUND=1 ;; l) LOOP=1 ;; *) usage ;;
  esac
done
shift $((OPTIND - 1))
FILE=${1:-}
[[ -f $FILE ]] || usage
command -v ffmpeg >/dev/null || { echo "Brak ffmpeg"; exit 1; }

# Proporcje wideo; znak ≈ 2x wyższy niż szerszy
IFS=, read -r VW VH < <(ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height -of csv=p=0 "$FILE")
H=$(( W * VH / VW / 2 ))
MAXH=$(( ROWS - 1 ))
if (( H > MAXH )); then H=$MAXH; W=$(( H * 2 * VW / VH )); fi
(( H < 1 )) && H=1
(( W < 1 )) && W=1

if (( COLOR )); then PIX=rgb24; BPR=$(( W * 3 )); else PIX=gray; BPR=$W; fi

AUDIO_PID=""
cleanup() {
  [[ -n $AUDIO_PID ]] && kill "$AUDIO_PID" 2>/dev/null || true
  tput cnorm; tput sgr0; clear
}
trap cleanup EXIT INT TERM
tput civis; clear

AWK_PROG='
BEGIN { ramp=" .:-=+*#%@"; n=length(ramp); row=0; buf="" }
{
  line=""
  if (color) {
    for (i=1; i<=NF; i+=3) {
      r=$i; g=$(i+1); b=$(i+2)
      l=0.299*r+0.587*g+0.114*b
      line = line sprintf("\033[38;2;%d;%d;%dm%s", r, g, b, substr(ramp, int(l*(n-1)/255)+1, 1))
    }
    line = line "\033[0m"
  } else {
    for (i=1; i<=NF; i++) line = line substr(ramp, int($i*(n-1)/255)+1, 1)
  }
  buf = buf line "\n"
  if (++row == H) { printf "\033[H%s", buf; fflush(); buf=""; row=0 }
}'

play() {
  if (( SOUND )) && command -v ffplay >/dev/null; then
    ffplay -nodisp -autoexit -loglevel quiet "$FILE" &
    AUDIO_PID=$!
  fi
  # -re: tempo czasu rzeczywistego (synchronizacja klatek)
  ffmpeg -v error -re -i "$FILE" \
    -vf "fps=$FPS,scale=${W}:${H}:flags=area" \
    -f rawvideo -pix_fmt "$PIX" - \
  | od -An -v -tu1 -w"$BPR" \
  | awk -v H="$H" -v color="$COLOR" "$AWK_PROG"
  [[ -n $AUDIO_PID ]] && kill "$AUDIO_PID" 2>/dev/null || true
  AUDIO_PID=""
}

if (( LOOP )); then while true; do play; done; else play; fi