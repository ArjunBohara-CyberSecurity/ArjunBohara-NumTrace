#!/usr/bin/env bash

NUMTRACE_PHONE_INPUT=
NUMTRACE_TARGET_INPUT=
NUMTRACE_NORMALIZED=
NUMTRACE_NATIONAL=
NUMTRACE_COUNTRY=
NUMTRACE_COUNTRY_CODE=
NUMTRACE_NUMBER_TYPE=
NUMTRACE_TIMEZONE=
NUMTRACE_VALIDITY=
NUMTRACE_CONFIDENCE=
NUMTRACE_PHONE_SOURCE=
NUMTRACE_PHONE_REMARK=

numtrace_country_meta() {
  code=$1
  case "$code" in
    IN) printf '91|India|Asia/Kolkata|mobile|10';;
    US) printf '1|United States|America/New_York|unknown|10';;
    CA) printf '1|Canada|America/Toronto|unknown|10';;
    GB) printf '44|United Kingdom|Europe/London|unknown|10';;
    AU) printf '61|Australia|Australia/Sydney|unknown|9';;
    SG) printf '65|Singapore|Asia/Singapore|unknown|8';;
    AE) printf '971|United Arab Emirates|Asia/Dubai|unknown|8';;
    DE) printf '49|Germany|Europe/Berlin|unknown|10';;
    FR) printf '33|France|Europe/Paris|unknown|9';;
    NL) printf '31|Netherlands|Europe/Amsterdam|unknown|9';;
    BR) printf '55|Brazil|America/Sao_Paulo|unknown|10';;
    *) return 1;;
  esac
}

numtrace_country_from_cc() {
  digits=$1
  case "$digits" in
    91*) printf 'IN';;
    1*) printf 'US';;
    44*) printf 'GB';;
    61*) printf 'AU';;
    65*) printf 'SG';;
    971*) printf 'AE';;
    49*) printf 'DE';;
    33*) printf 'FR';;
    31*) printf 'NL';;
    55*) printf 'BR';;
    *) printf '';;
  esac
}

numtrace_strip_non_digits() {
  printf '%s' "$1" | tr -cd '0-9+'
}

numtrace_normalize_phone() {
  input=$1
  country=${2:-}
  clean=$(numtrace_strip_non_digits "$input")
  clean=${clean#tel:}
  if [ -z "$clean" ]; then
    return 1
  fi

  plus=0
  case "$clean" in
    +*)
      plus=1
      digits=${clean#+}
      ;;
    *)
      digits=$clean
      ;;
  esac

  digits=$(printf '%s' "$digits" | tr -cd '0-9')
  if [ -z "$digits" ]; then
    return 1
  fi
  if [ "${#digits}" -lt 8 ] || [ "${#digits}" -gt 15 ]; then
    NUMTRACE_PHONE_REMARK='Digits outside a plausible international range'
    return 1
  fi

  if [ "$plus" -eq 1 ]; then
    NUMTRACE_NORMALIZED="+$digits"
    NUMTRACE_COUNTRY=$(numtrace_country_from_cc "$digits")
    if [ -n "$NUMTRACE_COUNTRY" ]; then
      meta=$(numtrace_country_meta "$NUMTRACE_COUNTRY") || true
      NUMTRACE_COUNTRY_CODE=${meta%%|*}
      rest=${meta#*|}
      NUMTRACE_COUNTRY_NAME=${rest%%|*}
      rest=${rest#*|}
      NUMTRACE_TIMEZONE=${rest%%|*}
      rest=${rest#*|}
      NUMTRACE_DEFAULT_TYPE=${rest%%|*}
      rest=${rest#*|}
      NUMTRACE_EXPECTED_LEN=$rest
    fi
    return 0
  fi

  if [ -n "$country" ]; then
    meta=$(numtrace_country_meta "$country") || return 1
    NUMTRACE_COUNTRY=$country
    NUMTRACE_COUNTRY_CODE=${meta%%|*}
    rest=${meta#*|}
    NUMTRACE_COUNTRY_NAME=${rest%%|*}
    rest=${rest#*|}
    NUMTRACE_TIMEZONE=${rest%%|*}
    rest=${rest#*|}
    NUMTRACE_DEFAULT_TYPE=${rest%%|*}
    rest=${rest#*|}
    expected_len=$rest
    case "$digits" in
      ${NUMTRACE_COUNTRY_CODE}*)
        national_part=${digits#${NUMTRACE_COUNTRY_CODE}}
        if [ "${#national_part}" -eq "$expected_len" ]; then
          NUMTRACE_NORMALIZED="+$digits"
          return 0
        fi
        ;;
    esac
    case "$digits" in
      0*) digits=${digits#0} ;;
    esac
    if [ "${#digits}" -eq "$expected_len" ]; then
      NUMTRACE_NORMALIZED="+${NUMTRACE_COUNTRY_CODE}${digits}"
    elif [ "${#digits}" -eq $((expected_len + 1)) ] && [ "${digits#0}" != "$digits" ]; then
      digits=${digits#0}
      NUMTRACE_NORMALIZED="+${NUMTRACE_COUNTRY_CODE}${digits}"
    elif [ "$country" = "US" ] && [ "${#digits}" -eq 11 ] && [ "${digits#1}" != "$digits" ]; then
      NUMTRACE_NORMALIZED="+1${digits#1}"
    else
      NUMTRACE_PHONE_REMARK='Length does not match known national plan'
      return 1
    fi
    return 0
  fi

  guess_country=
  case "${#digits}" in
    11|12)
      case "$digits" in
        91*) [ "${#digits}" -eq 12 ] && guess_country=IN ;;
        1*) [ "${#digits}" -eq 11 ] && guess_country=US ;;
        44*) [ "${#digits}" -eq 12 ] && guess_country=GB ;;
        61*) [ "${#digits}" -eq 11 ] && guess_country=AU ;;
        65*) [ "${#digits}" -eq 10 ] && guess_country=SG ;;
        971*) [ "${#digits}" -eq 11 ] && guess_country=AE ;;
        49*) [ "${#digits}" -eq 12 ] && guess_country=DE ;;
        33*) [ "${#digits}" -eq 11 ] && guess_country=FR ;;
        31*) [ "${#digits}" -eq 11 ] && guess_country=NL ;;
        55*) [ "${#digits}" -eq 12 ] && guess_country=BR ;;
      esac
      ;;
  esac
  if [ -z "$guess_country" ]; then
    NUMTRACE_PHONE_REMARK='Ambiguous number without country context'
    return 1
  fi
  meta=$(numtrace_country_meta "$guess_country") || return 1
  NUMTRACE_COUNTRY=$guess_country
  NUMTRACE_COUNTRY_CODE=${meta%%|*}
  rest=${meta#*|}
  NUMTRACE_COUNTRY_NAME=${rest%%|*}
  rest=${rest#*|}
  NUMTRACE_TIMEZONE=${rest%%|*}
  rest=${rest#*|}
  NUMTRACE_DEFAULT_TYPE=${rest%%|*}
  rest=${rest#*|}
  expected_len=$rest
  if [ "$guess_country" = "IN" ] && [ "${#digits}" -eq 10 ]; then
    NUMTRACE_NORMALIZED="+91$digits"
  elif [ "$guess_country" = "US" ] && [ "${#digits}" -eq 11 ] && [ "${digits#1}" != "$digits" ]; then
    NUMTRACE_NORMALIZED="+1${digits#1}"
  else
    NUMTRACE_NORMALIZED="+${digits}"
  fi
  return 0
}

numtrace_detect_number_type() {
  digits=$1
  country=${2:-}
  case "$country" in
    IN)
      case "$digits" in
        [6-9]*) printf 'mobile' ;;
        *) printf 'unknown' ;;
      esac
      ;;
    *)
      printf 'unknown'
      ;;
  esac
}

numtrace_analyze_phone() {
  input=$1
  country=${2:-}
  NUMTRACE_PHONE_INPUT=$input
  NUMTRACE_TARGET_INPUT=$input
  NUMTRACE_NORMALIZED=
  NUMTRACE_NATIONAL=
  NUMTRACE_COUNTRY=UNKNOWN
  NUMTRACE_COUNTRY_CODE=UNKNOWN
  NUMTRACE_NUMBER_TYPE=unknown
  NUMTRACE_TIMEZONE=UNKNOWN
  NUMTRACE_VALIDITY=UNKNOWN
  NUMTRACE_CONFIDENCE=low
  NUMTRACE_PHONE_REMARK=
  if ! numtrace_normalize_phone "$input" "$country"; then
    NUMTRACE_VALIDITY=INVALID
    NUMTRACE_CONFIDENCE=low
    NUMTRACE_NUMBER_TYPE=unknown
    NUMTRACE_NATIONAL=UNKNOWN
    NUMTRACE_COUNTRY=UNKNOWN
    NUMTRACE_COUNTRY_CODE=UNKNOWN
    NUMTRACE_TIMEZONE=UNKNOWN
    return 1
  fi

  digits=${NUMTRACE_NORMALIZED#+}
  case "$NUMTRACE_COUNTRY" in
    IN)
      national=${digits#91}
      NUMTRACE_NATIONAL=$national
      ;;
    US|CA)
      national=${digits#1}
      NUMTRACE_NATIONAL=$national
      ;;
    GB)
      national=${digits#44}
      NUMTRACE_NATIONAL=$national
      ;;
    AU)
      national=${digits#61}
      NUMTRACE_NATIONAL=$national
      ;;
    SG)
      national=${digits#65}
      NUMTRACE_NATIONAL=$national
      ;;
    AE)
      national=${digits#971}
      NUMTRACE_NATIONAL=$national
      ;;
    DE)
      national=${digits#49}
      NUMTRACE_NATIONAL=$national
      ;;
    FR)
      national=${digits#33}
      NUMTRACE_NATIONAL=$national
      ;;
    NL)
      national=${digits#31}
      NUMTRACE_NATIONAL=$national
      ;;
    BR)
      national=${digits#55}
      NUMTRACE_NATIONAL=$national
      ;;
    *)
      NUMTRACE_NATIONAL=UNKNOWN
      ;;
  esac

  if [ -z "${NUMTRACE_COUNTRY_NAME:-}" ] && [ -n "$NUMTRACE_COUNTRY" ]; then
    meta=$(numtrace_country_meta "$NUMTRACE_COUNTRY") || true
    NUMTRACE_COUNTRY_CODE=${meta%%|*}
    rest=${meta#*|}
    NUMTRACE_COUNTRY_NAME=${rest%%|*}
    rest=${rest#*|}
    NUMTRACE_TIMEZONE=${rest%%|*}
    rest=${rest#*|}
    NUMTRACE_DEFAULT_TYPE=${rest%%|*}
  fi

  if [ -n "$NUMTRACE_COUNTRY" ] && [ "$NUMTRACE_COUNTRY" = "IN" ]; then
    national_digits=$NUMTRACE_NATIONAL
    NUMTRACE_NUMBER_TYPE=$(numtrace_detect_number_type "$national_digits" "$NUMTRACE_COUNTRY")
  else
    NUMTRACE_NUMBER_TYPE=${NUMTRACE_DEFAULT_TYPE:-unknown}
  fi

  NUMTRACE_VALIDITY=VALID
  NUMTRACE_CONFIDENCE=medium
  NUMTRACE_PHONE_SOURCE='Numbering plan'
  if [ "$NUMTRACE_COUNTRY" = "IN" ] || [ "$NUMTRACE_COUNTRY" = "US" ] || [ "$NUMTRACE_COUNTRY" = "GB" ]; then
    NUMTRACE_CONFIDENCE=high
  fi
  if [ -n "$NUMTRACE_PHONE_REMARK" ]; then
    NUMTRACE_CONFIDENCE=low
  fi
  return 0
}

numtrace_number_display_field() {
  label=$1
  value=$2
  source=$3
  confidence=$4
  cat <<EOF
$label:
$value

Source:
$source

Confidence:
$confidence
EOF
}
