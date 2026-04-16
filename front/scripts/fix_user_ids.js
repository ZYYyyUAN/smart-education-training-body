const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..', 'src');

function listVueFiles(dir) {
  const out = [];
  for (const name of fs.readdirSync(dir)) {
    const p = path.join(dir, name);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      if (name === 'node_modules' || name.startsWith('.')) continue;
      out.push(...listVueFiles(p));
    } else if (name.endsWith('.vue')) {
      out.push(p);
    }
  }
  return out;
}

function ensurePiniaImport(content) {
  const importLine = "import { useUserStore } from '@/store/user.js'";
  if (content.includes(importLine)) return content;

  // Try to insert after the last import inside the first <script> block
  const scriptStart = content.indexOf('<script');
  if (scriptStart === -1) return content; // no script block
  const blockStart = content.indexOf('>', scriptStart);
  if (blockStart === -1) return content;
  const scriptEnd = content.indexOf('</script>', blockStart);
  if (scriptEnd === -1) return content;

  const block = content.slice(blockStart + 1, scriptEnd);
  const lines = block.split('\n');
  let lastImportIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('import ')) lastImportIdx = i;
  }
  if (lastImportIdx >= 0) {
    lines.splice(lastImportIdx + 1, 0, importLine);
  } else {
    lines.unshift(importLine);
  }
  const newBlock = lines.join('\n');
  return content.slice(0, blockStart + 1) + newBlock + content.slice(scriptEnd);
}

function fixFile(file) {
  let content = fs.readFileSync(file, 'utf8');
  const before = content;

  // Replace various spacing patterns
  const patterns = [
    /studentId\s*:\s*1\b/g,
    /createdBy\s*:\s*1\b/g,
  ];
  let replaced = false;
  for (const re of patterns) {
    if (re.test(content)) {
      replaced = true;
      content = content.replace(re, (m) => {
        if (m.includes('studentId')) return 'studentId: useUserStore().currentUserId';
        if (m.includes('createdBy')) return 'createdBy: useUserStore().currentUserId';
        return m;
      });
    }
  }
  // Also replace in querystring-style if any (rare)
  content = content.replace(/studentId=1\b/g, 'studentId=' + 'useUserStore().currentUserId');
  content = content.replace(/createdBy=1\b/g, 'createdBy=' + 'useUserStore().currentUserId');

  if (content !== before) {
    // Ensure import only if we inserted useUserStore usage
    if (content.includes('useUserStore().currentUserId')) {
      content = ensurePiniaImport(content);
    }
    fs.writeFileSync(file, content, 'utf8');
    console.log('✅ Fixed:', path.relative(process.cwd(), file));
    return true;
  }
  return false;
}

(function main(){
  if (!fs.existsSync(ROOT)) {
    console.error('src not found:', ROOT);
    process.exit(1);
  }
  const files = listVueFiles(ROOT);
  let count = 0;
  files.forEach(f => { if (fixFile(f)) count++; });
  console.log(`\n🎉 Done. Updated ${count} files.`);
})();
