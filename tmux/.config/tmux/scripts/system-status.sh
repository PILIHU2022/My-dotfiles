#!/usr/bin/env bash
# tmux 状态栏性能信息：CPU 利用率、内存占用、CPU 温度。
# 数据来自 Linux /proc 与 sysfs，不需要 sensors 等额外命令。
set -euo pipefail
umask 077

readonly PROC_STAT="/proc/stat"
readonly PROC_MEMINFO="/proc/meminfo"
readonly SAMPLE_SECONDS="0.2"

CPU_TOTAL=0
CPU_IDLE=0

read_cpu_counters() {
  local _ user nice system idle iowait irq softirq steal
  read -r _ user nice system idle iowait irq softirq steal _ < "${PROC_STAT}"
  CPU_TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))
  CPU_IDLE=$((idle + iowait))
}

cpu_usage() {
  local cache_dir cache_file
  local now prev_time=0 prev_total=0 prev_idle=0
  local cached_time="" cached_total="" cached_idle=""
  local total_delta idle_delta age usage

  now="$(date +%s)"
  read_cpu_counters
  if [[ -n "${XDG_RUNTIME_DIR:-}" ]] &&
    mkdir -p -m 700 "${XDG_RUNTIME_DIR}/tmux-status-${UID}" 2>/dev/null; then
    cache_dir="${XDG_RUNTIME_DIR}/tmux-status-${UID}"
  else
    cache_dir="${TMPDIR:-/tmp}/tmux-status-${UID}"
    mkdir -p -m 700 "${cache_dir}" 2>/dev/null || true
  fi
  cache_file="${cache_dir}/cpu"

  if [[ -d "${cache_dir}" && -O "${cache_dir}" &&
    -f "${cache_file}" && -r "${cache_file}" && -O "${cache_file}" ]]; then
    read -r cached_time cached_total cached_idle < "${cache_file}" || true
    if [[ "${cached_time}" =~ ^[0-9]+$ ]] &&
      [[ "${cached_total}" =~ ^[0-9]+$ ]] &&
      [[ "${cached_idle}" =~ ^[0-9]+$ ]]; then
      prev_time="${cached_time}"
      prev_total="${cached_total}"
      prev_idle="${cached_idle}"
    fi
  fi

  total_delta=$((CPU_TOTAL - prev_total))
  idle_delta=$((CPU_IDLE - prev_idle))
  age=$((now - prev_time))

  if ((prev_total <= 0 || prev_idle < 0 || total_delta <= 0 ||
    idle_delta < 0 || idle_delta > total_delta || age < 1 || age > 60)); then
    prev_total="${CPU_TOTAL}"
    prev_idle="${CPU_IDLE}"
    sleep "${SAMPLE_SECONDS}"
    read_cpu_counters
    total_delta=$((CPU_TOTAL - prev_total))
    idle_delta=$((CPU_IDLE - prev_idle))
    now="$(date +%s)"
  fi

  if [[ -d "${cache_dir}" && -O "${cache_dir}" ]] &&
    temp_file="$(mktemp "${cache_file}.XXXXXX" 2>/dev/null)"; then
    printf '%s %s %s\n' "${now}" "${CPU_TOTAL}" "${CPU_IDLE}" > "${temp_file}" &&
      mv -f "${temp_file}" "${cache_file}" 2>/dev/null || rm -f "${temp_file}"
  fi

  if ((total_delta <= 0)); then
    printf '--'
    return
  fi

  usage=$(((100 * (total_delta - idle_delta) + total_delta / 2) / total_delta))
  if ((usage < 0)); then
    usage=0
  elif ((usage > 100)); then
    usage=100
  fi
  printf '%s%%' "${usage}"
}

memory_usage() {
  local key value total=0 available=0 free=0 buffers=0 cached=0 used

  while read -r key value _; do
    case "${key}" in
      MemTotal:) total="${value}" ;;
      MemAvailable:) available="${value}" ;;
      MemFree:) free="${value}" ;;
      Buffers:) buffers="${value}" ;;
      Cached:) cached="${value}" ;;
    esac
  done < "${PROC_MEMINFO}"

  if ((available <= 0)); then
    available=$((free + buffers + cached))
  fi
  if ((total <= 0)); then
    printf -- '--'
    return
  fi

  used=$((total - available))
  if ((used < 0)); then
    used=0
  fi
  printf '%s%%' "$(((100 * used + total / 2) / total))"
}

cpu_temperature() {
  local dir name raw_file raw best=0 celsius
  local zone zone_type

  for dir in /sys/class/hwmon/hwmon*; do
    [[ -r "${dir}/name" ]] || continue
    name="$(<"${dir}/name")"
    case "${name}" in
      coretemp|k10temp|zenpower|cpu_thermal|soc_thermal|x86_pkg_temp|acpitz|*cpu*|*soc*) ;;
      *) continue ;;
    esac

    for raw_file in "${dir}"/temp*_input; do
      [[ -r "${raw_file}" ]] || continue
      raw="$(<"${raw_file}")"
      [[ "${raw}" =~ ^[0-9]+$ ]] || continue
      if ((raw >= 1000 && raw <= 150000)); then
        celsius=$(((raw + 500) / 1000))
        if ((celsius > best)); then
          best="${celsius}"
        fi
      fi
    done
  done

  if ((best == 0)); then
    for zone in /sys/class/thermal/thermal_zone*; do
      [[ -r "${zone}/type" && -r "${zone}/temp" ]] || continue
      zone_type="$(<"${zone}/type")"
      case "${zone_type}" in
        cpu*|*cpu*|soc*|*soc*|x86_pkg_temp|acpitz) ;;
        *) continue ;;
      esac

      raw="$(<"${zone}/temp")"
      [[ "${raw}" =~ ^[0-9]+$ ]] || continue
      if ((raw >= 1000 && raw <= 150000)); then
        celsius=$(((raw + 500) / 1000))
        if ((celsius > best)); then
          best="${celsius}"
        fi
      fi
    done
  fi

  if ((best > 0)); then
    printf '%s°C' "${best}"
  else
    printf -- '--'
  fi
}

printf 'CPU %s | MEM %s | TEMP %s\n' \
  "$(cpu_usage)" "$(memory_usage)" "$(cpu_temperature)"
