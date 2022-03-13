#!/bin/bash
set -u

TASKS=(
  'Task 1:task_1'
  'Task 2:task_2'
)
USAGE() {
cat <<EOF
$0 [-h] [-i] [TASK_ID]

Options:
  -h            : Show this help
  -i            : Interactive mode
  -b            : Batch(not-Interactive) mode (default)

Tasks:
EOF

for (( i = 0; i < ${#TASKS[@]}; i++ )); do
  IFS=: read task_subject task_cmd <<<"${TASKS[$i]}"
  printf "%2d. %s\n"  $((i + 1)) "${task_subject}"
done
echo ""
exit 1
}

function task_1 {
  cmd 'whoami'
  cmd 'id'
}

function task_2 {
  cmd 'uname -a'
}


function out {
  D=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${D}][${HOSTNAME}] $*"
}

function cmd {
  out "# $@"
  eval "$@"
  local _RC=$?
  if [ "${_RC}" -ne 0 ];then
    out "RC = ${_RC}"
  fi
  return ${_RC}
}

function start_task {
  CURRENT_TASK_ID=${1}
  IFS=: read task_subject task_cmd <<<"$2"
  CURRENT_TASK="${task_subject}"
  if [ "${INTERACTIVE}" = "on" ]; then
    echo ""
    echo "🟡 Next task is: ${CURRENT_TASK_ID}. ${task_subject}"
    read -p "Continue ? [y(es)/n(o)/S(kip)]: " ANSWER
    case "${ANSWER}" in
      [yY]*) ;;
      [nN]*)
        echo "exit"
        exit 1
        ;;
      *)
        echo "skip"
        return 0
    esac
  fi
  out "➡️  ${CURRENT_TASK_ID}. ${task_subject}"
  eval "${task_cmd}"
  end_task $?
}
function end_task {
  local _RC=${1:-0}
  if [ "${_RC}" -eq 0 ]; then
    out "✅ ${CURRENT_TASK}"
    echo ""
    return 0
  else
    out "🛑 ${CURRENT_TASK} [RC=${_RC}]"
    exit 2
  fi
}

# -----------------------------------------------
# Main
# -----------------------------------------------
INTERACTIVE=off

while getopts :ibh OPT
do
  case "${OPT}" in 
    h) USAGE;;
    i) INTERACTIVE=on;;
    b) INTERACTIVE=off;;
  esac
done
shift $((OPTIND - 1))

task_begin=${1:-1}

for (( i = $((task_begin -1)); i < ${#TASKS[@]}; i++)); do
  start_task $((i + 1)) "${TASKS[$i]}"
done

