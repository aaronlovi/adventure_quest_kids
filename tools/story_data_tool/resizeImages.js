import sharp from 'sharp';
import { existsSync, lstatSync, mkdirSync, readdirSync } from 'fs';
import { extname, join, basename } from 'path';

// Check if the correct number of command-line arguments is provided
if (process.argv.length !== 4) {
    console.error('Usage: node resizeImages.js inputDirectoryPath outputDirectoryPath');
    process.exit(1);
}

const inputDirectoryPath = process.argv[2];
const outputDirectoryPath = process.argv[3];

// Check if the input directory exists
if (!existsSync(inputDirectoryPath) || !lstatSync(inputDirectoryPath).isDirectory()) {
    console.error('Input directory does not exist.');
    process.exit(1);
}

// Check if the output directory exists, create it if not
if (!existsSync(outputDirectoryPath)) {
    mkdirSync(outputDirectoryPath);
}

// Get a list of image files in the input directory
const originalImageFiles = readdirSync(inputDirectoryPath)
    .filter(file => ['.jfif', '.jpg', '.jpeg', '.png'].includes(extname(file).toLowerCase()));

// Process each image file
originalImageFiles.forEach(originalImageFile => {
    const inputFilePath = join(inputDirectoryPath, originalImageFile);
    const extension = extname(originalImageFile);
    const fileNameWithoutExtension = basename(originalImageFile, extension);
    const outputFilePath = join(outputDirectoryPath, fileNameWithoutExtension + '.jpg');

// Resize the image and save it as a JPEG file
sharp(inputFilePath)
    .metadata()
    .then(metadata => {
        const inputWidth = metadata.width;
        const inputHeight = metadata.height;

        return sharp(inputFilePath)
            .resize(256, 256)
            .toFile(outputFilePath, (err, info) => {
                if (err) {
                    console.error(`Error processing ${inputFilePath}:`, err);
                } else {
                    console.log(`Conversion finished for ${inputFilePath}`);
                    console.log('Input dimensions:', inputWidth, 'x', inputHeight);
                    console.log('Output dimensions:', info.width, 'x', info.height);
                }
            });
    })
    .catch(err => {
        console.error(`Error getting metadata for ${inputFilePath}:`, err);
    });
});
