/**
 * audioTimestampRecorder.js
 * 
 * This script plays an audio file and records timestamps when any key (except 'q') is pressed.
 * The timestamps are written to an output file when 'q' is pressed.
 * 
 * Usage: node audioTimestampRecorder.js <input_file> <output_file>
 * 
 * Note: This script uses VLC media player for audio playback and only supports VLC.
 * VLC must be installed and added to the system's PATH.
 * The playback speed is set to the constant PLAYBACK_RATE below using VLC's '--rate' option.
 */
import { writeFile } from 'fs';
import keypress from 'keypress';
import playSound from 'play-sound';

const inputFilePath = process.argv[2]; // Get the input file from the command line
const outputFilePath = process.argv[3]; // Get the output file from the command line

const PLAYBACK_RATE = 0.3; // The playback rate of the audio file

if (!inputFilePath || !outputFilePath) {
    console.log('Usage: node audioTimestampRecorder.js <input_file> <output_file>');
    process.exit(1);
}

let startTime;
const opts = { players: ["vlc"] };
const player = playSound(opts);

const getTimestamp = () => {
    const now = new Date();
    const offset = now - startTime;
    const seconds = Math.floor(offset / 1000).toString().padStart(2, '0');
    const milliseconds = (offset % 1000).toString().padStart(3, '0');
    return `${seconds}.${milliseconds}`;
};

const playAudio = async (audioFilePath) => {
    try {
        await new Promise((resolve, reject) => {
            player.play(audioFilePath, { vlc: ['--rate', PLAYBACK_RATE.toString(), '--qt-start-minimized'] }, (err) => {
                if (err) reject(err);
                else resolve();
            });
        });
        console.log('Audio playback finished');
    } catch (error) {
        console.error(`Error playing audio file: ${error}`);
    }
};

/**
 * Writes the given timestamps to the output file.
 * 
 * The timestamps are scaled to account for the half-speed audio playback.
 * Each timestamp is divided by 2 before being written to the file.
 * 
 * If an error occurs while writing the file, the error is logged to the console
 * and the process exits with a status code of 1.
 * 
 * If the file is written successfully, a success message is logged to the console
 * and the process exits with a status code of 0.
 * 
 * @param {number[]} wordsTimestamps - The timestamps to write to the file.
 */
const writeTimestampFile = (wordsTimestamps) => {
    console.log(`wordsTimestamps: ${wordsTimestamps}`);

    if (wordsTimestamps.length === 0) {
        console.error('No timestamps to write.');
        process.exit(1);
    }

    const firstTimestamp = wordsTimestamps[0];
    const offsetTimestamps = wordsTimestamps.map(timestamp => timestamp - firstTimestamp);

    const inversePlaybackRate = 1 / PLAYBACK_RATE;
    const scaledTimestamps = offsetTimestamps.map(timestamp => (timestamp / inversePlaybackRate).toFixed(3));

    writeFile(outputFilePath, scaledTimestamps.join('\n'), (err) => {
        if (err) {
            console.error(`Error writing to file: ${err}`);
            process.exit(1);
        } else {
            console.log(`Timestamps written to ${outputFilePath}`);
            process.exit(0);
        }
    });
};

const main = async () => {
    try {
        const wordsTimestamps = [];

        keypress(process.stdin);

        console.log('Press a key at the start of each word. Press "q" to finish.');
        playAudio(inputFilePath);
        startTime = new Date();

        process.stdin.on('keypress', (ch, key) => {
            if (!key) return;

            if (key.name === 'q') {
                writeTimestampFile(wordsTimestamps);
            } else {
                const timestamp = getTimestamp();
                console.log(timestamp);
                wordsTimestamps.push(timestamp);
            }
        });

        process.stdin.setRawMode(true);
        process.stdin.resume();
    } catch (error) {
        console.error('Error:', error.message);
    }
};

main();
