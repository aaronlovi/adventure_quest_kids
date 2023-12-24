import { readFileSync } from 'fs';
import { load } from 'js-yaml';

/*
    Starting from the first page of a story_data.yaml file, does a DFS
    traversal of the YAML structure and prints out the path taken.
*/

function traverseDFS(node, path, yamlData) {
    console.log(`Current Page: ${path} - ${node.text}`);
    if (node.choices) {
        Object.keys(node.choices).forEach(choice => {
            const choiceData = node.choices[choice];
            console.log(`----> Choice: ${choice} - ${choiceData.text}\n`);
            if (choiceData.nextPageId && yamlData[choiceData.nextPageId]) {
                traverseDFS(yamlData[choiceData.nextPageId], choiceData.nextPageId, yamlData);
            }
        });
    }
    console.log(`Finished processing ${path} - ${node.text} -- BACK UP A LEVEL.\n`);
}

function startTraversal(yamlFilePath) {
    try {
        const fileContents = readFileSync(yamlFilePath, 'utf8');
        const yamlData = load(fileContents);

        const firstPageId = yamlData.first_page;
        if (firstPageId && yamlData.pages[firstPageId]) {
            traverseDFS(yamlData.pages[firstPageId], firstPageId, yamlData.pages);
        } else {
            console.error(`Root page (${firstPageId}) not found in the YAML structure.`);
        }
    } catch (e) {
        console.error(e);
    }
}

// Use the first command-line argument as the YAML file path
const yamlFilePath = process.argv[2];
if (!yamlFilePath) {
    console.error('Please provide a YAML file path as the first argument.');
    process.exit(1);
}

startTraversal(yamlFilePath);
