# Bash Script for Whisper Video Transcription and Translation
 
Automates subtitle creation for multiple videos using OpenAI's speech recognition model, (Whisper)[https://github.com/openai/whisper].

## Overview

This repository provides a bash script tailored to process all video files within a specified directory and its subdirectories. It uses the 'whisper' command, a highly versatile speech recognition model developed by OpenAI, capable of tasks such as multilingual speech recognition, speech translation, and language identification.

The script provides an array of options allowing the user to define the video language, file extensions to be processed, output formats, and the specific task for Whisper. Moreover, it facilitates lowering the CPU and I/O priority of the whisper process using the `nice` command.

Prior to running this script, please ensure the `whisper` program is correctly installed on your system. This can be checked by executing the `whisper` command on its own, for instance:

```bash
whisper --task transcribe --language en --model small --output_format txt --output_dir ./ ./myvideo.mp4
```

If an error message appears or the output doesn't meet expectations, it could signify a problem with your `whisper` installation.

## Installation of Whisper

Before using the script in this repository, install OpenAI's Whisper, a general-purpose speech recognition model. Here are simplified steps to get you started:

1. **Python and PyTorch**: The Whisper codebase is compatible with Python 3.8-3.11 and recent PyTorch versions. If not already installed, Python can be downloaded [here](https://www.python.org/downloads/), and PyTorch [here](https://pytorch.org/get-started/locally/).

2. **Install Whisper**: You can install the latest release of Whisper with the following command:

    ```
    pip install -U openai-whisper
    ```

3. **ffmpeg**: This tool is necessary for handling video and audio files. Installation instructions vary by operating system:

    - **Ubuntu or Debian**
        ```
        sudo apt update && sudo apt install ffmpeg
        ```

    - **MacOS** (using Homebrew)
        ```
        brew install ffmpeg
        ```

For more detailed information, consult the official [Whisper documentation](https://github.com/openai/whisper).

## Installing this Script

After you've installed all the necessary dependencies and have verified that Whisper works correctly on your system, follow these steps to install and use the `whisper-batch-subtitler` script.

1. **Clone the repository**: Use the `git clone` command to clone the `whisper-batch-subtitler` repository to your local machine:

   ```bash
   git clone https://github.com/mettamatt/whisper-batch-subtitler.git
   ```

2. **Navigate to the repository folder**: After cloning, navigate to the newly created directory:

   ```bash
   cd whisper-batch-subtitler
   ```

3. **Make the script executable**: Before you can run the script, you need to make it executable. You can do this with the `chmod` command:

   ```bash
   chmod +x whisper-batch-subtitler.sh
   ```

Now, you can run the script using the following syntax:

```bash
./whisper-batch-subtitler.sh [OPTIONS] <dir>
```

Please replace `<dir>` with the directory of the videos you want to process. If you don't specify a directory, the script will use the current one. Refer to the "Usage" section above for information about the different options available with this script.

Remember, always ensure the `whisper` program is properly installed and functional before running this script.

## Usage

```bash
./whisper-batch-subtitler.sh [OPTIONS] <dir>
```

Here, `<dir>` denotes the directory to process. In the absence of a specified directory, the script will default to the current directory.

### Options

- `-h, --help`                 Displays help message and exits.
- `-e, --extensions <ext>`     Defines a comma-separated list of file extensions to process. Default is `mp4,mkv,avi,flv,wmv`.
- `-l, --language <lang>`      Defines the language used in the videos. Default is `en`.
- `-o, --output_format <fmt>`  Specifies a comma-separated list of output formats. Default is `txt,vtt,srt,tsv,json`.
- `-n, --nice`                 If specified, the script will utilize the 'nice' command to lower the CPU and I/O priority of the whisper process.
- `-t, --task <task>`          Defines the task for whisper to perform. Options are `transcribe` or `translate`. Default is `transcribe`.
- `-m, --model <model>`        Specifies the model for whisper to use. Options include `tiny.en`, `tiny`, `base.en`, `base`, `small.en`, `small`, `medium.en`, `medium`, `large-v1`, `large-v2`, or `large`. Default is `small`.

## Note on Whisper Models

Switching between different Whisper models using the `-m` or `--model` option necessitates running the `whisper` command again separately. This step enables Whisper to download the new model before processing files in bulk using the script. For example:

```bash
whisper --task transcribe --language en --model medium --output_format txt --output_dir ./ ./myvideo.mp4
```

This command downloads the `medium` model if it's not already present on your system. Subsequent uses of the `medium` model with the script will then proceed without needing to download the model again.

## Dependencies

This script's operation relies on [Whisper](https://github.com/openai/whisper) being installed and accessible in your system's PATH. Refer to the official OpenAI Whisper documentation for installation instructions.
