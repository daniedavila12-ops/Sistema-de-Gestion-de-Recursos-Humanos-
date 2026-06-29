const fs = require('fs');
const path = require('path');

const directoryPath = path.join(__dirname, 'lib');
const importStmt = "import 'package:innova_mobile/core/constants/api_constants.dart';\n";

function processDirectory(dir) {
    fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDirectory(fullPath);
        } else if (fullPath.endsWith('.dart') && !fullPath.includes('api_constants.dart')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            let modified = false;

            // Replace exact matches
            if (content.includes("'http://10.0.2.2:3007'") || content.includes("'http://localhost:3007'")) {
                content = content.replace(/'http:\/\/10\.0\.2\.2:3007'/g, "ApiConstants.baseUrl");
                content = content.replace(/'http:\/\/localhost:3007'/g, "ApiConstants.baseUrl");
                modified = true;
            }

            // Replace strings with interpolations or suffixes, like 'http://10.0.2.2:3007/api...' -> '${ApiConstants.baseUrl}/api...'
            const regex = /'http:\/\/(?:10\.0\.2\.2|localhost):3007([^']*)'/g;
            if (regex.test(content)) {
                content = content.replace(regex, "'${ApiConstants.baseUrl}$1'");
                modified = true;
            }

            if (modified) {
                // Ensure import is present
                if (!content.includes('api_constants.dart')) {
                    // Find the last import or put it after the first // comment
                    const importIndex = content.lastIndexOf('import ');
                    if (importIndex !== -1) {
                        const endOfLine = content.indexOf('\n', importIndex) + 1;
                        content = content.slice(0, endOfLine) + importStmt + content.slice(endOfLine);
                    } else {
                        content = importStmt + content;
                    }
                }
                fs.writeFileSync(fullPath, content, 'utf8');
                console.log('Updated:', fullPath);
            }
        }
    });
}

processDirectory(directoryPath);
console.log('Refactoring complete.');
