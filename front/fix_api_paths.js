const fs = require('fs');
const path = require('path');

// 递归查找所有Vue文件
function findVueFiles(dir) {
  const files = [];
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
      files.push(...findVueFiles(fullPath));
    } else if (item.endsWith('.vue')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

// 修复单个文件中的API路径
function fixApiPaths(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;
    
    // 替换 /api/xiaozhi 为 /xiaozhi
    const newContent = content.replace(/\/api\/xiaozhi/g, '/xiaozhi');
    
    if (newContent !== content) {
      fs.writeFileSync(filePath, newContent, 'utf8');
      console.log(`✅ 修复: ${filePath}`);
      modified = true;
    }
    
    return modified;
  } catch (error) {
    console.error(`❌ 修复失败: ${filePath}`, error.message);
    return false;
  }
}

// 主函数
function main() {
  const srcDir = path.join(__dirname, 'src');
  
  if (!fs.existsSync(srcDir)) {
    console.error('❌ src目录不存在');
    return;
  }
  
  console.log('🔍 查找Vue文件...');
  const vueFiles = findVueFiles(srcDir);
  console.log(`📁 找到 ${vueFiles.length} 个Vue文件`);
  
  let fixedCount = 0;
  
  for (const file of vueFiles) {
    if (fixApiPaths(file)) {
      fixedCount++;
    }
  }
  
  console.log(`\n🎉 修复完成! 共修复了 ${fixedCount} 个文件`);
  console.log('📝 所有 /api/xiaozhi 路径已更新为 /xiaozhi');
}

main();
