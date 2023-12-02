import ffmpeg from 'fluent-ffmpeg';

// Check if the correct number of command-line arguments is provided
if (process.argv.length !== 6) {
  console.error('Usage: node trimAudio.js inputFilePath outputFilePath startTime duration\nstartTime and duration are in seconds.');
  process.exit(1);
}

const inputFilePath = process.argv[2];
const outputFilePath = process.argv[3];
const startTime = parseFloat(process.argv[4]);
const duration = parseFloat(process.argv[5]);

// Check if startTime and duration are valid numbers
if (isNaN(startTime) || isNaN(duration)) {
  console.error('Invalid startTime or duration. Please provide valid numeric values.');
  process.exit(1);
}

ffmpeg()
  .input(inputFilePath)
  .setStartTime(startTime)
  .setDuration(duration)
  .audioCodec('copy') // Copy audio stream without re-encoding
  .on('end', () => {
    console.log('Trimming finished');
  })
  .on('error', (err) => {
    console.error('Error:', err);
  })
  .save(outputFilePath);