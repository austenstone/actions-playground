const fs = require('fs');
const content = fs.readFileSync('test.json');
const json = JSON.parse(content);
const parts = json.monitoredResourceId.split('/');
parts[2] = '987654321';
parts.join('/');
json.monitoredResourceId = parts;
fs.writeFileSync('test.json', JSON.stringify(json));
return json.monitoredResourceId