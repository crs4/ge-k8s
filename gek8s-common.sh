#!/bin/bash

# set the current version number
VERSION="0.1"

# initialize the bash environment if needed
# . /Archive/Software/Modules/3.2.10/init/bash

# portable version of abspath
function abspath() {
    local path="${*}"
    
    if [[ -d "${path}" ]]; then
        echo "$( cd "${path}" >/dev/null && pwd )"
    else
        echo "$( cd "$( dirname "${path}" )" >/dev/null && pwd )/$(basename "${path}")"
    fi
}

function script_dir() {
  echo "$(dirname $(abspath ${BASH_SOURCE[0]}))"
}

function print_version() {
  echo "${VERSION}"
}

function log() {
    echo -e "${@}" >&2
}

function debug_log() {
    if [[ -n "${DEBUG:-}" ]]; then
        echo -e "DEBUG: ${@}" >&2
    fi
}

function log_allowed_environment_config_properties() {
    if [[ -n ${DEBUG:-} ]]; then
        debug_log "\nAllowed config properties..."
        for param in ${gek8s_allowed_config_properties}; do    
            debug_log "${param} => ${!param}"
        done
        debug_log "DONE"
    fi
}

function log_config_properities(){
    if [[ -n  ${DEBUG:-} ]]; then
        debug_log "Config properties..."
        for v in "${config_properties[@]}"; do  
            debug_log "${v}"
        done
        debug_log "DONE"
    fi
}

function error_log() {
    echo -e "ERROR: ${@}" >&2
}

function error_trap() {
    error_log "Error at line ${BASH_LINENO[1]} running the following command:\n\n\t${BASH_COMMAND}\n\n"
    error_log "Stack trace:"
    for (( i=1; i < ${#BASH_SOURCE[@]}; ++i)); do
        error_log "$(printf "%$((4*$i))s %s:%s\n" " " "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i]}")"
    done
    exit 2
}

trap error_trap ERR

function usage_error() {
    if [[ $# > 0 ]]; then
        echo -e "ERROR: ${@}" >&2
    fi
    help
    exit 2
}

# load global settings
set -o allexport
source "$(script_dir)/gek8s-settings.sh"
set +o allexport

# 
host_list=""

# Collect arguments to be passed on to the next program in an array, rather than
# a simple string. This choice lets us deal with arguments that contain spaces.
positional_parameters=()

# configuration properties from cmd options
config_properties=()

# parse arguments
while [ -n "${1-}" ]; do
    # Copy so we can modify it (can't modify $1)
    OPT="$1"
    # Detect argument termination
    if [ x"$OPT" = x"--" ]; then
        shift
        for OPT ; do
            # append to array
            positional_parameters+=("$OPT")
        done
        break
    fi
    # Parse current opt
    while [ x"$OPT" != x"-" ] ; do
        case "$OPT" in
            -h )
                help
                exit 0
                ;;
            -f )
                gek8s_config_file="${OPT#*=}"
                shift
                ;;
            --hosts )
                host_list="${2}"
                shift
                ;;
            --hosts-file )
                hosts_file="${OPT#*=}"
                shift
                ;;    
            -v )
                config_properties+=("${2}")
                shift
                ;;                  
            * )
                # append to array
                positional_parameters+=("$OPT")
                break
                ;;
        esac
        # Check for multiple short options
        # NOTICE: be sure to update this pattern to match valid options
        NEXTOPT="${OPT#-[cfr]}" # try removing single short opt
        if [ x"$OPT" != x"$NEXTOPT" ] ; then
            OPT="-$NEXTOPT"  # multiple short opts, keep going
        else
            break  # long form, exit inner loop
        fi
    done
    # move to the next param
    shift
done

# Only for debugging
log_config_properities

# check whether the config-file exists
if [[ ! -f "${gek8s_config_file}" ]]; then
    error_log "Config file ${gek8s_config_file} doen't exist!"
    exit 1
fi

# Save current environment variables
debug_log "Saving environment config properties..."
environment_config_properties=""
for v in ${gek8s_allowed_config_properties}; do
    if [[ -n "${!v}" ]]; then
        cp="${v}"="${!v}"
        environment_config_properties="${environment_config_properties} ${cp}"
        debug_log "${cp}"
    fi
done
debug_log "DONE"

# load configuration from file
set -o allexport
source "${gek8s_config_file}"
set +o allexport

# override properties on configuration file with the existing environment
debug_log "Restore existing environment variables..."
for v in ${environment_config_properties}; do    
    debug_log "${v%=*}"="${v#*=}"
    export "${v%=*}"="${v#*=}"    
done
debug_log "DONE"

# Only for debugging
log_allowed_environment_config_properties

# override default configuration by setting environment parameters
for v in "${config_properties[@]}"; do    
    export "${v%=*}"="${v#*=}"
done

# Only for debugging
log_allowed_environment_config_properties

# write node config file
debug_log "Writing node configuration parameters..."
parameters=""
for param in ${gek8s_allowed_config_properties}; do
    debug_log "Adding ${param}=${!param}"
    parameters="${parameters} ${param}=${!param}"
done
debug_log "DONE"

# set host list
if [[ -f ${hosts_file} ]]; then
    for h in $(cat ${hosts_file}); do
        host_list="${hosts_file}${h},"
    done
fi

export host_list
export config_properties
export positional_parameters
export environment_config_properties