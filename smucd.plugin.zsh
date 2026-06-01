autoload -U colors && colors

function cd() {
  emulate -L zsh
  setopt localoptions extendedglob nullglob noxtrace

  local input="$*"

  if [[ -z "$input" || "$input" == "-" || "$input" == "." || "$input" == ".." ]]; then
    builtin cd "$input"
    return
  fi

  local dir_part=""
  local base_part="$input"

  if [[ "$input" == */* ]]; then
    dir_part="${input%/*}/"
    base_part="${input##*/}"
  fi

  local dp="$dir_part"
  [[ "$dp" == ~* ]] && dp="${~dp}"

  local pure_sq=""
  local pure="${base_part// /}"
  if (( ${#pure} > 0 )); then
    pure_sq="${(L)pure[1]}"
    for (( i=2; i<=${#pure}; i++ )); do
      [[ "${(L)pure[i]}" != "${(L)pure[i-1]}" ]] && pure_sq+="${(L)pure[i]}"
    done
  fi

  local matches=()
  local in_len=${#pure_sq}

  if [[ -z "$base_part" ]]; then
    matches=( ${~dp}*(N-/) )
  else
    local globs=()

    globs+=( "(#i)${base_part}*" "(#i)*${base_part}*" )
    
    globs+=( "(#i)${pure_sq}*" "(#i)*${pure_sq}*" )

    if [[ "$base_part" == *" "* ]]; then
      local wglob="(#i)*"
      for word in ${=base_part}; do
        local err=$(( ${#word} / 3 ))
        wglob+="(#a${err})${word}*"
      done
      globs+=( "$wglob" )
    fi

    local subseq="(#i)*"
    for (( i=1; i<=${#pure_sq}; i++ )); do subseq+="${pure_sq[$i]}*"; done
    globs+=( "$subseq" )

    if (( in_len >= 3 )); then globs+=( "(#ia1)${pure_sq}*" ); fi
    if (( in_len >= 5 )); then globs+=( "(#ia2)${pure_sq}*" ); fi
    if (( in_len >= 7 )); then globs+=( "(#ia3)${pure_sq}*" ); fi
    if (( in_len >= 4 )); then globs+=( "(#ia1)*${pure_sq}*" ); fi
    if (( in_len >= 6 )); then globs+=( "(#ia2)*${pure_sq}*" ); fi

    if (( in_len >= 5 )); then
      globs+=( "(#i)${pure_sq[1]}*${pure_sq[-3,-1]}*" ) # First + Last 3
      globs+=( "(#i)*${pure_sq[1]}*${pure_sq[-3,-1]}*" ) 
      globs+=( "(#i)${pure_sq[1,2]}*${pure_sq[-2,-1]}*" ) # First 2 + Last 2
    fi
    if (( in_len >= 4 )); then
      globs+=( "(#i)${pure_sq[1]}*${pure_sq[-2,-1]}*" ) # First + Last 2
    fi

    if (( in_len >= 4 )); then
      local chop_len=$(( in_len - 1 ))
      while (( chop_len >= 3 )); do
        globs+=( "(#i)${pure_sq[1,$chop_len]}*" )
        (( chop_len-- ))
      done
    fi

    if (( in_len >= 5 )); then
      globs+=( "(#i)${pure_sq[1]}*${pure_sq[-1]}*" )
    fi

    for pat in "${globs[@]}"; do
      matches=( ${~dp}${~pat}(N-/oe:'REPLY=${#REPLY}':) )
      if (( ${#matches} > 0 )); then
        break # STOP at the very first successful heuristic!
      fi
    done
  fi

  matches=( ${(u)matches} )
  local total=${#matches[@]}

  if (( total == 0 )); then
    print -P "%F{#ff5555}✖ No directories match '%F{#f1fa8c}${input}%F{#ff5555}'%f"
    return 1
  elif (( total == 1 )); then
    builtin cd "${matches[1]}"
    return
  fi

  local _scd_sel=1
  local _scd_start=1
  local limit=10
  local actual_lines=$(( total > limit ? limit : total ))
  local _scd_target_end=$actual_lines
  
  print -n "\e[?25l\e[?7l"

  local total_menu_height=$(( actual_lines + 2 ))
  for (( i=0; i<total_menu_height; i++ )); do print ""; done
  print -n "\e[${total_menu_height}A\e7"

  _cleanup_tui() {
    print -n "\e8\e[J\e[?25h\e[?7h"
  }

  _draw_menu() {
    local is_flash=$1
    local current_end=$2

    print -n "\e8"

    print -P "%F{#bd93f9}╭─ 󰉋 %1~ %F{#6272a4}• %f%F{#8be9fd}${total}%f %F{#6272a4}matches%f"$'\e[K'
    for (( i=_scd_start; i<=current_end; i++ )); do
      local m="${matches[i]}"
      local bname="${m:t}"
      local dname="${m:h}/"
      
      [[ "$dname" == "./" || "$dname" == "/" ]] && dname=""

      local max_len=$(( ${COLUMNS:-80} - 14 ))
      (( max_len < 5 )) && max_len=5
      if (( (${#dname} + ${#bname}) > max_len )); then
        bname="${bname[1,$((max_len - ${#dname}))]}…"
      fi

if (( i == _scd_sel )); then
        if [[ "$is_flash" == "flash" ]]; then
          print -P "│ %B%F{#f1fa8c} ❯   %F{#ffffff}${dname}${bname}%f%b"$'\e[K'
        else
          print -P "│ %B%F{#50fa7b} ❯   %F{#6272a4}${dname}%F{#8be9fd}${bname}%f%b"$'\e[K'
        fi
      else
        print -P "│ %F{#6272a4}      ${dname}%F{#f8f8f2}${bname}%f"$'\e[K'
      fi
    done

    if (( total > limit )); then
      print -P "%F{#bd93f9}╰─ %F{#6272a4}󰜴 Use ↓/↑ scroll • ↵ select • Esc cancel%f"$'\e[K'
    else
      print -P "%F{#bd93f9}╰─ %F{#6272a4}󰜴 Use ↓/↑ move • ↵ select • Esc cancel%f"$'\e[K'
    fi
    
    print -n "\e[J"
  }

  local _scd_anim_idx=1
  while (( _scd_anim_idx <= _scd_target_end )); do
    _draw_menu "" "$_scd_anim_idx"
    if read -t 0.02 -k 1 -s; then break; fi
    (( _scd_anim_idx++ ))
  done

  local _scd_end=$_scd_target_end
  while true; do
    _draw_menu "" "$_scd_end"

    read -r -s -k 1
    
    case "$REPLY" in
      $'\x1b') 
        if read -r -s -k 2 -t 0.05; then
          if [[ "$REPLY" == "[A" ]]; then (( _scd_sel-- ))
          elif [[ "$REPLY" == "[B" ]]; then (( _scd_sel++ ))
          fi
        else
          _cleanup_tui; return 0
        fi
        ;;
      'k'|'K') (( _scd_sel-- )) ;;
      'j'|'J') (( _scd_sel++ )) ;;
      'q'|'Q') _cleanup_tui; return 0 ;;
      $'\n'|$'\r')
        _draw_menu "flash" "$_scd_end"
        read -t 0.08 -k 1 -s
        
        _cleanup_tui
        builtin cd "${matches[$_scd_sel]}"
        return 0
        ;;
    esac

    if (( _scd_sel < 1 )); then
      _scd_sel=$total
      _scd_end=$total
      _scd_start=$(( total - limit + 1 ))
      (( _scd_start < 1 )) && _scd_start=1
    elif (( _scd_sel > total )); then
      _scd_sel=1
      _scd_start=1
      _scd_end=$(( total > limit ? limit : total ))
    elif (( _scd_sel < _scd_start )); then
      (( _scd_start-- ))
      (( _scd_end-- ))
    elif (( _scd_sel > _scd_end )); then
      (( _scd_start++ ))
      (( _scd_end++ ))
    fi
  done
}
