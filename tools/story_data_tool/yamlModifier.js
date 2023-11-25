import { readFileSync } from 'fs';
import yaml from 'js-yaml';

// Read YAML file
const readYamlFile = (filePath) => {
    try {
        const fileContent = readFileSync(filePath, 'utf8');
        return yaml.load(fileContent);
    } catch (error) {
        console.error(`Error reading YAML file: ${error.message}`);
        process.exit(1);
    }
};

// Write YAML object to console
const writeYamlToConsole = (yamlObject) => {
    try {
        // Set options for YAML string
        const yamlString = yaml.dump(yamlObject, { quotingType: '"', forceQuotes: true });
        console.log(yamlString);
    } catch (error) {
        console.error(`Error writing YAML to console: ${error.message}`);
        process.exit(1);
    }
};

const addPropertyToPages = (yamlObject, propertyName, value) => {
    if (!yamlObject?.pages)
        return;

    Object.keys(yamlObject.pages).forEach((key) => {
        const page = yamlObject.pages[key];
        if (page && !page.hasOwnProperty(propertyName))
            page[propertyName] = value;
    });
};

///////////////////////////////////////////////////////////////////////////////

// Example usage
const filePath = process.argv[2];

// Check if a file path is provided
if (!filePath) {
    console.error('Please provide a file path as a command-line argument.');
    process.exit(1);
}

const storyObject = readYamlFile(filePath);

// Modify the properties of the object as needed
// storyObject.someProperty = 'Modified Value';

// Add a property to each page
addPropertyToPages(storyObject, 'soundFileName', 'default.mp3');

// Write the modified object to console
writeYamlToConsole(storyObject);
