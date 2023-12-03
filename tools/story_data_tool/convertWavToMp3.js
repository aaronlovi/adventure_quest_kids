import { readdirSync, statSync } from 'fs';
import { join } from 'path';
import ffmpeg from 'fluent-ffmpeg';

// Function to convert WAV to MP3
const convertWavToMp3 = (inputFilePath, outputFilePath) => {
  return new Promise((resolve, reject) => {
    ffmpeg()
      .input(inputFilePath)
      .audioCodec('libmp3lame')
      .toFormat('mp3')
      .on('end', () => {
        console.log(`Conversion finished: ${inputFilePath} -> ${outputFilePath}`);
        resolve();
      })
      .on('error', (err) => {
        console.error(`Error converting ${inputFilePath}: ${err}`);
        reject(err);
      })
      .save(outputFilePath);
  });
};

// Function to traverse a directory and convert all WAV files to MP3
const convertDirectory = async (inputDirectory, outputDirectory) => {
  try {
    const files = readdirSync(inputDirectory);

    for (const file of files) {
      const filePath = join(inputDirectory, file);
      const stat = statSync(filePath);

      if (stat.isDirectory()) {
        await convertDirectory(filePath); // Recursively convert subdirectories
      } else if (file.toLowerCase().endsWith('.wav')) {
        const mp3FileName = file.replace('.wav', '.mp3');
        const outputFilePath = join(outputDirectory, mp3FileName);

        await convertWavToMp3(filePath, outputFilePath);
      } else if (file.toLowerCase().endsWith('.mp4')) {
        const mp3FileName = file.replace('.mp4', '.mp3');
        const outputFilePath = join(outputDirectory, mp3FileName);

        await convertWavToMp3(filePath, outputFilePath);
      }
    }
  } catch (err) {
    console.error(`Error reading directory: ${inputDirectory}`, err);
  }
};

// Get the directory path from the command line argument
const inputDirectory = process.argv[2];
const outputDirectory = process.argv[3];

// Check if the directory path is provided
if (!inputDirectory) {
  console.error('Please provide an input directory path.');
  console.error('Usage: node convertWavToMp3.js <input_directory_path> <output_directory_path>');
  process.exit(1);
}

if (!outputDirectory) {
  console.error('Please provide an output directory path.');
  console.error('Usage: node convertWavToMp3.js <input_directory_path> <output_directory_path>');
  process.exit(1);
}

// Start the conversion process
convertDirectory(inputDirectory, outputDirectory);
