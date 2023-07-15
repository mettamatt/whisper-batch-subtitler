#!/bin/bash

# Default values
extensions="mp4,mkv,avi,flv,wmv"
language="en"
output_format="txt,vtt,srt,tsv,json"
nice_flag=0
nice_command=''
task="transcribe"
model="small"

# If nice_flag is set to 1 and ionice is available, enable nice_command
if [ "$nice_flag" -eq 1 ]; then
  if command -v ionice >/dev/null 2>&1; then
    nice_command='nice -n 19 ionice -c 3'
  else
    nice_command='nice -n 19'
  fi
fi

# List of valid languages
valid_languages="af am ar as az ba be bg bn bo br bs ca cs cy da de el en es et eu fa fi fo fr gl gu ha haw he hi hr ht hu hy id is it ja jw ka kk km kn ko la lb ln lo lt lv mg mi mk ml mn mr ms mt my ne nl nn no oc pa pl ps pt ro ru sa sd si sk sl sn so sq sr su sv sw ta te tg th tk tl tr tt uk ur uz vi yi yo zh"

# List of valid tasks
valid_tasks="transcribe translate"

# List of valid models
valid_models="tiny.en tiny base.en base small.en small medium.en medium large-v1 large-v2 large"

# Function to check if a value is in a list
contains() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

# Help function
display_help() {
    echo "Usage: $0 [OPTIONS] <dir>"
    echo
    echo "This script is used to process all video files in a given directory and its subdirectories using the 'whisper' command."
    echo "You can specify the file extensions, language, output formats, CPU and I/O priority, and task for whisper."
    echo "If an option is not provided, the script will use its default value."
    echo
    echo "Options:"
    echo "-h, --help                 Show this help message and exit."
    echo "-e, --extensions <ext>     Specify a comma-separated list of file extensions to process. (default: mp4,mkv,avi,flv,wmv)"
    echo "-l, --language <lang>      Specify the language used in the videos. (default: en)"
    echo "-o, --output_format <fmt>  Specify a comma-separated list of output formats. (default: txt,vtt,srt,tsv,json)"
    echo "-n, --nice                 If set to 1, the script will use the 'nice' command to lower the CPU and I/O priority of the whisper process. If set to 0, it won't. (default: 0)"
    echo "-t, --task <task>          Specify the task for whisper to perform. Options are 'transcribe' or 'translate'. (default: transcribe)"
    echo "-m, --model <model>        Specify the model for whisper to use. Options are 'tiny.en', 'tiny', 'base.en', 'base', 'small.en', 'small', 'medium.en', 'medium', 'large-v1', 'large-v2', or 'large'. (default: small)"
    echo
    echo "<dir> is the directory to process. If no directory is specified, the script will use the current directory."
    echo
    echo "Note: This script checks if the 'whisper' command exists and is executable, if the directory exists and is readable, and if there are any video files with the given extensions in the directory."
    echo "      If any of these checks fail, the script will display an error message and exit."
    echo
    echo "      For the language option, only the following language codes are supported:"
    echo "      $valid_languages"
    echo
    echo "Whisper is a general-purpose speech recognition model. It is trained on a large dataset of diverse audio and is also a multitasking model that can perform multilingual speech recognition, speech translation, and language identification."
    echo
    exit 1
}

# Function to process video files
process_video_files() {
    dir=$1
    extensions=$2
    language=$3
    output_format=$4
    nice_command=$5
    task=$6

    # Check if whisper command exists and is executable
    if ! [ -x "$(command -v whisper)" ]; then
        echo 'Error: whisper command not found or not executable.' >&2
        exit 1
    fi

    # Check if directory exists and is readable
    if [ ! -d "$dir" ] || [ ! -r "$dir" ]; then
        echo "Error: Directory does not exist or is not readable." >&2
        exit 1
    fi

    # Check if there are any video files with given extensions in the directory
    ext_found=0
    for ext in ${extensions//,/ }; do
        if find "$dir" -type f -name "*.$ext" | read; then
            ext_found=1
            break
        fi
    done
    if [ $ext_found -eq 0 ]; then
        echo "Error: No video files with given extensions found in the specified directory." >&2
        exit 1
    fi

    # Iterate over all video files with given extensions in the directory and its subdirectories
      for ext in ${extensions//,/ }; do
          find "$dir" -type f -name "*.$ext" -print0 | while IFS= read -r -d '' file; do
              # Extract base name and directory for the file
              base_name="$(basename "$file" ".$ext")"
              dir_name="$(dirname "$file")"
              
              echo "------------------------------"
              echo "Processing file: $file"   # Display the current file being processed
              
              if [ -n "$nice_command" ]; then
                  whisper_command="${nice_command} whisper --task \"${task}\" --language \"${language}\" --model \"${model}\" --output_format \"${output_format}\" --output_dir \"${dir_name}\" \"${file}\""
                else
                  whisper_command="whisper --task \"${task}\" --language \"${language}\" --model \"${model}\" --output_format \"${output_format}\" --output_dir \"${dir_name}\" \"${file}\""
                fi
              echo "  Running: $whisper_command"
              echo "------------------------------"
              echo ""
              if ! eval "$whisper_command"; then
                  echo "Error: Failed to process file $file" >&2
              fi
          done
      done
}

# Parse command-line arguments
while (( "$#" )); do
  case "$1" in
    -e|--extensions)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        extensions=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -l|--language)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        if echo $valid_languages | grep -wq $2; then
          language=$2
          shift 2
        else
          echo "Error: Invalid language $2. Supported languages are: $valid_languages" >&2
          exit 1
        fi
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -o|--output_format)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        output_format=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -n|--nice)
      if [ -n "$2" ] && [ "$2" != "-" ]; then
        nice_flag=$2
        shift 2
      else
        echo "Error: Argument for '--nice'/'-n' is missing" >&2
        exit 1
      fi
      ;;
    -m|--model)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        if echo $valid_models | grep -wq $2; then
          model=$2
          shift 2
        else
          echo "Error: Invalid model $2. Supported models are: $valid_models" >&2
          exit 1
        fi
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -t|--task)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        if echo $valid_tasks | grep -wq $2; then
          task=$2
          shift 2
        else
          echo "Error: Invalid task $2. Supported tasks are: $valid_tasks" >&2
          exit 1
        fi
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

# Check if a directory has been specified, if not, use the current directory
if [ -z "$1" ]; then
    dir="."
else
    dir="${1%/}"
fi

# Process video files
process_video_files "$dir" "$extensions" "$language" "$output_format" "$nice_command" "$task" "$model"

echo "Script completed successfully. All video files have been processed."
