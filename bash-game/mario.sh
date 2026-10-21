#!/usr/bin/env bash
# mario.sh — platformówka 2D w terminalu (sterowanie strzałkami)
# Wymaga: bash >= 4, tput.   Użycie: ./mario.sh [-a]    (-a = tylko znaki ASCII)
#
# Silnik: arytmetyka stałoprzecinkowa (100 = 1 kafelek), stały krok 30 FPS,
# jeden printf na klatkę, kolorowanie całej klatki hurtowo (podstawienia na
# jednym łańcuchu), czekanie na następną klatkę przez `read -t` (bez forków).

export LC_ALL=C
if (( BASH_VERSINFO[0] < 4 )); then echo "Wymagany bash >= 4." >&2; exit 1; fi

FPS=30; FRAME_US=33333
LH=16; GROUND=14                      # wiersze 0..15, ziemia od wiersza 14
RUN=28; ACC=5; AACC=3; GRAV=7; MAXFALL=60; JUMPV=80; HOLDT=9
MAXLEVEL=3
ASCII=0; [[ ${1-} == -a ]] && ASCII=1

declare -a LV ROW EX EY EVX ES
LW=0; NE=0; START=3
LEVEL=1; LIVES=3; SCORE=0; COINS=0
HOLD=0; PAUSE=0; RES=0; KEY=""
PX=0; PY=0; VX=0; VY=0; ONG=1; DIR=0; HT=0; JB=0; FACE=1; ANIM=0
CAM=0; TIME=300; FR=0; NEXT=0
COLS=80; ROWS=24; VW=80; OLD_STTY=""

# ---------- grafika ----------
setup_glyphs() {
  local e=$'\e['
  local g_grd='▓' g_brk='▚' g_q='?' g_used='■' g_hard='▒' g_pipe='█' g_coin='●' g_pole='│' g_flag='▶'
  if (( ASCII )); then
    g_grd='#' g_brk='%' g_used='x' g_hard='X' g_pipe='|' g_coin='o' g_pole='|' g_flag='>'
  fi
  COINCH=$g_coin
  SK="${e}0;48;5;117m"                          # tło nieba
  R_GRD="${e}0;38;5;94;48;5;130m${g_grd}${SK}"
  R_BRK="${e}0;38;5;94;48;5;166m${g_brk}${SK}"
  R_Q="${e}1;38;5;94;48;5;220m${g_q}${SK}"
  R_USED="${e}0;38;5;94;48;5;137m${g_used}${SK}"
  R_HARD="${e}0;38;5;240;48;5;250m${g_hard}${SK}"
  R_PT="${e}0;38;5;46;48;5;28m${g_pipe}${SK}"
  R_PB="${e}0;38;5;34;48;5;22m${g_pipe}${SK}"
  R_COIN="${e}1;38;5;226m${g_coin}${SK}"
  R_POLE="${e}0;38;5;255m${g_pole}${SK}"
  R_FLAG="${e}1;38;5;46m${g_flag}${SK}"
  R_M="${e}1;38;5;196mM${SK}"
  R_W="${e}1;38;5;196mW${SK}"
  R_GMB="${e}1;38;5;94m@${SK}"
  R_SQ="${e}1;38;5;94m_${SK}"
}

render() {
  local r x ch out hud i
  CAM=$(( PX/100 - VW/3 ))
  (( CAM > LW - VW )) && CAM=$(( LW - VW ))
  (( CAM < 0 )) && CAM=0

  for (( r = 0; r < LH; r++ )); do ROW[r]=${LV[r]:CAM:VW}; done

  for (( i = 0; i < NE; i++ )); do
    (( ES[i] == 0 )) && continue
    x=$(( (EX[i]+50)/100 - CAM )); r=$(( EY[i]/100 ))
    (( x < 0 || x >= VW || r >= LH )) && continue
    if (( ES[i] > 0 )); then ch='@'; else ch='_'; fi
    ROW[r]=${ROW[r]:0:x}$ch${ROW[r]:x+1}
  done

  x=$(( (PX+50)/100 - CAM )); r=$(( (PY+50)/100 ))
  if (( r >= 0 && r < LH && x >= 0 && x < VW )); then
    if (( VX != 0 && ONG && (ANIM/3) % 2 )); then ch=W; else ch=M; fi
    ROW[r]=${ROW[r]:0:x}$ch${ROW[r]:x+1}
  fi

  printf -v out '%s\n' "${ROW[@]}"
  out=${out//"#"/$R_GRD};  out=${out//"B"/$R_BRK};  out=${out//"?"/$R_Q}
  out=${out//"U"/$R_USED}; out=${out//"H"/$R_HARD}; out=${out//"P"/$R_PT}
  out=${out//"p"/$R_PB};   out=${out//"c"/$R_COIN}; out=${out//"F"/$R_POLE}
  out=${out//"f"/$R_FLAG}; out=${out//"M"/$R_M};    out=${out//"W"/$R_W}
  out=${out//"@"/$R_GMB};  out=${out//"_"/$R_SQ}
  out=${out//$'\n'/$'\e[0m\n'$SK}

  printf -v hud ' PKT %06d  %sx%02d  POZ %d  CZAS %03d  ŻYCIA %d  [%s]' \
    "$SCORE" "$COINCH" "$COINS" "$LEVEL" "$TIME" "$LIVES" \
    "$( (( HOLD )) && echo przytrzymanie || echo ciągły )"
  printf '\e[H\e[0;1;37;44m%s\e[K\e[0m\n%s%s\e[0m\e[J' "$hud" "$SK" "$out"
}

# ---------- budowanie poziomów ----------
newgrid() {
  LW=$1; local r blank
  printf -v blank '%*s' "$LW" ''
  for (( r = 0; r < LH; r++ )); do LV[r]=$blank; done
  NE=0; EX=(); EY=(); EVX=(); ES=()
}
put()    { LV[$2]=${LV[$2]:0:$1}$3${LV[$2]:$1+1}; }
hput()   { local i; for (( i = 0; i < $3; i++ )); do put $(( $1 + i )) "$2" "$4"; done; }
ground() { local r; for (( r = GROUND; r < LH; r++ )); do hput "$1" "$r" $(( $2 - $1 + 1 )) '#'; done; }
pit()    { local r; for (( r = GROUND; r < LH; r++ )); do hput "$1" "$r" $(( $2 - $1 + 1 )) ' '; done; }
pipe()   { local r; for (( r = GROUND - $2; r < GROUND; r++ )); do
             if (( r == GROUND - $2 )); then hput "$1" "$r" 2 P; else hput "$1" "$r" 2 p; fi
           done; }
stairs() { local i r; for (( i = 0; i < $2; i++ )); do
             for (( r = GROUND - 1 - i; r < GROUND; r++ )); do put $(( $1 + i )) "$r" H; done
           done; }
goomba() { local y=${2:-$(( GROUND - 1 ))}
           EX[NE]=$(( $1 * 100 )); EY[NE]=$(( y * 100 )); EVX[NE]=-8; ES[NE]=1; NE=$(( NE + 1 )); }
flag()   { local r; for (( r = 3; r < GROUND; r++ )); do put "$1" "$r" F; done; put $(( $1 - 1 )) 4 f; }

level1() {
  newgrid 150; START=3
  ground 0 149
  pit 52 54; pit 90 93; pit 118 120
  put 14 9 '?'; put 20 9 B; put 21 9 '?'; put 22 9 B; put 23 9 '?'; put 24 9 B; put 22 5 '?'
  hput 70 10 5 B; put 72 6 '?'; hput 78 9 3 '?'
  pipe 30 2; pipe 40 3; pipe 62 2
  hput 33 11 4 c; hput 52 11 3 c; hput 90 10 4 c; hput 100 11 5 c; hput 72 8 3 c
  local x; for x in 26 35 46 58 68 75 84 98 110 123; do goomba $x; done
  stairs 126 5; flag 138
}

level2() {
  newgrid 170; START=3
  ground 0 169
  pit 24 27; pit 46 49; pit 66 69; pit 92 95; pit 118 121; pit 134 137
  pipe 14 2; pipe 34 3; pipe 56 4; pipe 76 2; pipe 100 3; pipe 112 2; pipe 128 4
  hput 36 10 4 B; put 37 6 '?'; put 38 6 B; put 8 9 '?'; put 9 9 B; put 10 9 '?'
  hput 80 9 5 B; put 82 5 '?'; hput 104 9 3 '?'
  hput 24 10 4 c; hput 46 10 4 c; hput 66 10 4 c; hput 92 10 4 c; hput 118 10 4 c
  local x; for x in 20 30 40 52 72 80 86 98 106 124 130 140; do goomba $x; done
  stairs 144 6; flag 158
}

level3() {
  newgrid 190; START=3
  ground 0 189
  pit 18 21; pit 30 34; pit 50 53; pit 60 64; pit 76 79; pit 96 100; pit 112 115; pit 126 130
  put 32 11 H; put 62 11 H; put 98 11 H; put 128 11 H
  pipe 10 2; pipe 26 3; pipe 42 4; pipe 56 2; pipe 70 3; pipe 84 4; pipe 104 2; pipe 120 3; pipe 134 4
  hput 12 9 3 B; put 13 5 '?'; hput 44 9 4 '?'; hput 86 9 3 B; put 87 5 '?'; hput 138 9 4 B
  hput 18 10 4 c; hput 50 10 4 c; hput 76 10 4 c; hput 112 10 4 c; hput 126 9 5 c
  local x; for x in 14 24 38 46 55 66 74 82 90 108 118 124 138 146 160 166 170; do goomba $x; done
  stairs 150 6; flag 178
}

load_level() {
  "level$LEVEL"
  PX=$(( START * 100 )); PY=$(( (GROUND - 1) * 100 ))
  VX=0; VY=0; ONG=1; DIR=0; HT=0; JB=0; FACE=1; ANIM=0
  CAM=0; TIME=300; FR=0; RES=0; PAUSE=0
}

# ---------- fizyka ----------
solid() {   # tx ty -> 0 gdy kafelek stały
  (( $1 < 0 || $1 >= LW )) && return 0
  (( $2 < 0 || $2 >= LH )) && return 1
  case ${LV[$2]:$1:1} in '#'|B|'?'|U|H|P|p) return 0 ;; esac
  return 1
}

add_coin() { (( COINS++, SCORE += 50 )); (( COINS % 20 == 0 )) && (( LIVES++ )); }

bump() {    # x y — uderzenie blokiem od dołu
  case ${LV[$2]:$1:1} in
    '?') put "$1" "$2" U; (( SCORE += 150 )); add_coin ;;
    B)   put "$1" "$2" ' '; (( SCORE += 50 )) ;;
  esac
}

update() {
  local nx c r1 r2 ny rr cl cr cc x y ch i a tgt oldpy pvy

  # --- sterowanie poziome z bezwładnością ---
  if (( HOLD )); then if (( HT > 0 )); then (( HT-- )); else DIR=0; fi; fi
  tgt=$(( DIR * RUN )); a=$(( ONG ? ACC : AACC ))
  if (( VX < tgt )); then (( VX += a )); (( VX > tgt )) && VX=$tgt
  elif (( VX > tgt )); then (( VX -= a )); (( VX < tgt )) && VX=$tgt; fi

  # --- skok (bufor 5 klatek) i grawitacja ---
  if (( JB > 0 )); then (( JB-- )); if (( ONG )); then VY=-$JUMPV; ONG=0; JB=0; fi; fi
  (( VY += GRAV )); (( VY > MAXFALL )) && VY=$MAXFALL
  pvy=$VY; oldpy=$PY

  # --- ruch poziomy + kolizje ---
  if (( VX != 0 )); then
    nx=$(( PX + VX ))
    if (( nx < -10 )); then nx=-10; VX=0
    else
      if (( VX > 0 )); then c=$(( (nx+89)/100 )); else c=$(( (nx+10)/100 )); fi
      r1=$(( PY/100 )); r2=$(( (PY+99)/100 ))
      if solid $c $r1 || solid $c $r2; then
        if (( VX > 0 )); then nx=$(( c*100 - 90 )); else nx=$(( (c+1)*100 - 10 )); fi
        VX=0
      fi
    fi
    PX=$nx
  fi

  # --- ruch pionowy + kolizje ---
  ny=$(( PY + VY )); ONG=0
  cl=$(( (PX+10)/100 )); cr=$(( (PX+89)/100 ))
  if (( VY >= 0 )); then
    rr=$(( (ny+99)/100 ))
    if solid $cl $rr || solid $cr $rr; then ny=$(( rr*100 - 100 )); VY=0; ONG=1; fi
  else
    (( ny < 0 )) && ny=0
    rr=$(( ny/100 ))
    if solid $cl $rr || solid $cr $rr; then
      cc=$(( (PX+50)/100 ))
      if   solid $cc $rr; then bump $cc $rr
      elif solid $cl $rr; then bump $cl $rr
      else bump $cr $rr; fi
      ny=$(( (rr+1)*100 )); VY=0
    fi
  fi
  PY=$ny
  (( ANIM++ ))

  # --- monety i meta ---
  for (( y = PY/100; y <= (PY+99)/100; y++ )); do
    for (( x = (PX+10)/100; x <= (PX+89)/100; x++ )); do
      (( x >= LW || y >= LH )) && continue
      ch=${LV[y]:x:1}
      case $ch in
        c) put $x $y ' '; add_coin ;;
        F|f) RES=1 ;;
      esac
    done
  done
  (( RES )) && return

  # --- przeciwnicy ---
  for (( i = 0; i < NE; i++ )); do
    if (( ES[i] < 0 )); then (( ES[i]++ )); continue; fi
    (( ES[i] == 0 )) && continue
    (( EX[i] - PX > 2500 || PX - EX[i] > 2500 )) && continue
    nx=$(( EX[i] + EVX[i] ))
    if (( EVX[i] > 0 )); then c=$(( (nx+89)/100 )); else c=$(( (nx+10)/100 )); fi
    r1=$(( EY[i]/100 ))
    if solid $c $r1 || ! solid $c $(( r1 + 1 )); then EVX[i]=$(( -EVX[i] )); else EX[i]=$nx; fi
    if (( PX+90 > EX[i]+10 && PX+10 < EX[i]+90 && PY+100 > EY[i]+25 && PY < EY[i]+100 )); then
      if (( pvy > 0 && oldpy + 100 <= EY[i] + 60 )); then
        ES[i]=-10; (( SCORE += 100 )); VY=-48; ONG=0
      else
        RES=4; return
      fi
    fi
  done

  # --- czas, przepaść ---
  if (( ++FR >= FPS )); then FR=0; (( TIME-- )); (( TIME <= 0 )) && { RES=4; return; }; fi
  (( PY > (LH + 1) * 100 )) && RES=4
}

# ---------- wejście i pętla czasu ----------
handle_key() {
  local s
  if [[ $1 == $'\e' ]]; then
    IFS= read -rsn2 -t 0.005 s
    case $s in
      '[A'|OA) KEY=UP ;; '[B'|OB) KEY=DOWN ;; '[C'|OC) KEY=RIGHT ;; '[D'|OD) KEY=LEFT ;;
      *) KEY=ESC ;;
    esac
  else KEY=$1; fi
  case $KEY in
    LEFT|a|A)  DIR=-1; HT=$HOLDT; FACE=-1 ;;
    RIGHT|d|D) DIR=1;  HT=$HOLDT; FACE=1 ;;
    DOWN|s|S)  DIR=0;  HT=0 ;;
    UP|w|W|' ') JB=5 ;;
    p|P) PAUSE=1 ;;
    r|R) RES=3 ;;
    m|M) HOLD=$(( 1 - HOLD )); DIR=0; HT=0 ;;
    q|Q|ESC) RES=2 ;;
  esac
}

wait_frame() {
  local now rem t k
  if [[ -n ${EPOCHREALTIME-} ]]; then
    while :; do
      now=${EPOCHREALTIME/[.,]/}
      rem=$(( NEXT - now ))
      (( rem < 500 || RES )) && break
      (( rem > FRAME_US )) && rem=$FRAME_US
      printf -v t '0.%06d' "$rem"
      IFS= read -rsn1 -t "$t" k && handle_key "$k"
    done
    (( now > NEXT + FRAME_US * 3 )) && NEXT=$now
    NEXT=$(( NEXT + FRAME_US ))
  else
    IFS= read -rsn1 -t 0.03 k && handle_key "$k"
  fi
}

drain() { local _; while IFS= read -rsn1 -t 0.01 _; do :; done; }

run_level() {
  [[ -n ${EPOCHREALTIME-} ]] && NEXT=${EPOCHREALTIME/[.,]/}
  drain
  while (( ! RES )); do
    update
    render
    (( RES )) && break
    wait_frame
    if (( PAUSE )); then
      PAUSE=0
      printf '\e[%d;%dH\e[0;1;37;41m  PAUZA - dowolny klawisz  \e[0m' $(( ROWS / 2 )) $(( COLS / 2 - 12 ))
      IFS= read -rsn1 _; drain
      [[ -n ${EPOCHREALTIME-} ]] && NEXT=${EPOCHREALTIME/[.,]/}
    fi
  done
}

# ---------- ekrany ----------
vlen() { local t=${1//[ -~]/}; VL=$(( ${#1} - ${#t} / 2 )); }

splash() {   # linie...; Enter/spacja = 0, q = 1
  local lines=("$@") n=$# i row col k
  printf '\e[0;1;38;5;232;48;5;117m\e[2J'
  row=$(( (ROWS - n) / 2 )); (( row < 1 )) && row=1
  for (( i = 0; i < n; i++ )); do
    vlen "${lines[i]}"
    col=$(( (COLS - VL) / 2 + 1 )); (( col < 1 )) && col=1
    printf '\e[%d;%dH%s' $(( row + i )) $col "${lines[i]}"
  done
  drain
  while IFS= read -rsn1 k; do
    case $k in ''|' ') return 0 ;; q|Q) return 1 ;; esac
  done
  return 1
}

TITLE_ART=(
' __  __    _    ____  ___ ___  '
'|  \/  |  / \  |  _ \|_ _/ _ \ '
'| |\/| | / _ \ | |_) || | | | |'
'| |  | |/ ___ \|  _ < | | |_| |'
'|_|  |_/_/   \_\_| \_\___\___/ '
)

title_screen() {
  splash "${TITLE_ART[@]}" '' 'Platformówka 2D w terminalu' '' \
    'Strzałki lewo/prawo - bieg (ciągły), strzałka w dół - hamulec' \
    'Strzałka w górę lub SPACJA - skok (skacz na wrogów, uderzaj w bloki)' \
    'M - tryb sterowania (ciągły / przytrzymanie), P - pauza, R - restart, Q - wyjście' \
    '' '[ENTER] start     [Q] wyjście'
}

play_game() {
  local bonus l1 l2
  LEVEL=1; LIVES=3; SCORE=0; COINS=0
  while :; do
    load_level; run_level
    case $RES in
      1) bonus=$(( TIME * 10 )); (( SCORE += bonus ))
         if (( LEVEL >= MAXLEVEL )); then
           printf -v l1 'Wynik końcowy: %d   Monety: %d' "$SCORE" "$COINS"
           splash 'GRATULACJE!' '' 'Ukończyłeś wszystkie poziomy.' '' "$l1" '' '[ENTER]'; return
         fi
         printf -v l1 'Premia za czas: %d' "$bonus"; printf -v l2 'Wynik: %d' "$SCORE"
         splash "POZIOM $LEVEL UKOŃCZONY" '' "$l1" "$l2" '' '[ENTER] - następny poziom'
         (( LEVEL++ )) ;;
      2) return ;;
      3) ;;
      4) (( LIVES-- ))
         if (( LIVES <= 0 )); then
           printf -v l1 'Wynik: %d' "$SCORE"; splash 'KONIEC GRY' '' "$l1" '' '[ENTER]'; return
         fi
         printf -v l1 'Pozostało żyć: %d' "$LIVES"
         splash 'AU! STRACIŁEŚ ŻYCIE' '' "$l1" '' '[ENTER] - spróbuj ponownie' ;;
    esac
  done
}

# ---------- terminal ----------
init_term() { tput smcup; tput civis; stty -echo 2>/dev/null; printf '\e[?7l\e[0m\e[2J'; }
restore_term() {
  printf '\e[?7h\e[0m'; tput cnorm; tput rmcup
  [[ -n $OLD_STTY ]] && stty "$OLD_STTY" 2>/dev/null
}

main() {
  command -v tput >/dev/null || { echo "Brak tput (pakiet ncurses)." >&2; exit 1; }
  setup_glyphs
  COLS=$(tput cols); ROWS=$(tput lines)
  if (( ROWS < LH + 2 || COLS < 40 )); then
    echo "Terminal za mały: potrzeba min. 40x$(( LH + 2 )), jest ${COLS}x${ROWS}." >&2; exit 1
  fi
  VW=$(( COLS > 100 ? 100 : COLS ))
  OLD_STTY=$(stty -g 2>/dev/null)
  trap restore_term EXIT
  trap 'exit 130' INT TERM
  init_term
  while title_screen; do play_game; done
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main
