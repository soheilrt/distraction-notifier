set -e

# TODO: Check for possible open tabs in browser
distraction_threshold=3 # number of times user allowed work with unauthorized app
check_interval=5 # intervals in second to check user active window
distraction_notification_timeout=30 # how many seconds which this script should wait after sending notification (to avoid too much notification)

# evince:   pdf reader
# nautilus: file manager
# java:     intellij idea family :)
# code:     vscode
study_mode=('chrome' 'evince' 'nautilus')
work_mode=( "java" "code" "chrome" "slack" "genome-terminal-" )


RANDOM_ALERTS=(
    'Hey, what are you doing?'
    'You are getting distracted'
    'Seriously?'
)

active_mode='work'
if [[ $# -ge 1 ]]; then
    active_mode=$1
fi
echo "Active Mode: $active_mode"

# default mode is set to work if user does not pass wor
allowed_windows=("${work_mode[@]}")

case $active_mode in
   work)
    allowed_windows=("${work_mode[@]}")
  ;;
  study)
    allowed_windows=("${study_mode[@]}")
  ;;
esac


get_active_window_name() {
    ps -e | grep "$(xdotool getwindowpid "$(xdotool getwindowfocus)")" | grep -v grep | awk '{print $4}'
}


distraction_counter=0
while :
do
    active_window=$(get_active_window_name)

    unauthorized_window=1

    for i in "${allowed_windows[@]}" 
    do :
        if [[ "${i}" == "${active_window}" ]]; then
            echo "Authorized: $i"
            unauthorized_window=0
            break
        fi
    done

    if [[ $unauthorized_window -eq 1 ]]; then
        ((distraction_counter+=1))
        echo "distracted: $active_window : $distraction_counter"
    else
        distraction_counter=0
    fi
    

    if [[ $distraction_counter -ge $distraction_threshold ]]; then
        rand=$(( RANDOM % ${#RANDOM_ALERTS[@]} ))
        echo "Sending notification..."
        notify-send --urgency=normal "${RANDOM_ALERTS[$rand]}"

        distraction_counter=0

        sleep $distraction_notification_timeout
    fi
    
    sleep $check_interval;
done

