const express = require('express')
const multer = require('multer')
const cors = require('cors')
const path = require('path')
const fs = require('fs')
const { exec } = require('child_process')

const app = express()
const port = 3001

app.use(cors())

const uploadDir = path.join(__dirname, 'uploads')
const pdfDir = path.join(__dirname, 'pdfs')
const sofficePath = `"C:\\Program Files\\LibreOffice\\program\\soffice.exe"`;
// 创建文件夹
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir)
if (!fs.existsSync(pdfDir)) fs.mkdirSync(pdfDir)

app.use('/uploads', express.static(uploadDir))
app.use('/pdfs', express.static(pdfDir))

// 配置上传
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const timestamp = Date.now()
    
    // 关键：将 latin1 编码的原始文件名转换成 utf8，避免中文乱码
    const originalNameBuffer = Buffer.from(file.originalname, 'latin1') 
    const originalName = originalNameBuffer.toString('utf8')

    // 安全清理：空格 -> 下划线，去掉特殊字符，仅保留英文、数字、中文、点、横线
    const safeName = originalName
      .replace(/\s+/g, '_')
      .replace(/[^\w\u4e00-\u9fa5.-]/g, '')

    const filename = `${timestamp}-${safeName}`
    cb(null, filename)
  }
})

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 } // 限制50MB
})

// 判断是否是 Office 文档
const isOfficeFile = (ext) =>
  ['.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'].includes(ext.toLowerCase())

// 转换为 PDF
const convertToPdf = (inputPath, outputDir) => {
  return new Promise((resolve, reject) => {
    const cmd = `${sofficePath} --headless --convert-to pdf --outdir "${outputDir}" "${inputPath}"`;
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        console.error('转换命令错误：', stderr);
        return reject(error);
      }
      const pdfPath = path.join(
        outputDir,
        path.basename(inputPath).replace(path.extname(inputPath), '.pdf')
      );
      if (fs.existsSync(pdfPath)) {
        resolve(pdfPath);
      } else {
        reject(new Error('PDF 文件未生成'));
      }
    });
  });
};

// PDF 预览接口
app.get('/pdfs/:filename', (req, res) => {
  const filePath = path.join(pdfDir, req.params.filename)
  if (fs.existsSync(filePath)) {
    res.setHeader('Content-Type', 'application/pdf')
    res.setHeader('Content-Disposition', `inline; filename="${req.params.filename}"`)
    res.sendFile(filePath)
  } else {
    res.status(404).send('PDF 文件不存在')
  }
})

// 上传接口
app.post('/upload', upload.single('file'), async (req, res) => {
  const file = req.file
  if (!file) {
    return res.status(400).json({ success: false, message: '文件上传失败' })
  }
  const decodedName = Buffer.from(file.originalname, 'latin1').toString('utf8')
  const ext = path.extname(file.originalname).toLowerCase()
  const originalUrl = `http://localhost:${port}/uploads/${file.filename}`
  let pdfUrl = null

  if (isOfficeFile(ext)) {
    try {
      const pdfPath = await convertToPdf(file.path, pdfDir)
      const pdfFilename = path.basename(pdfPath)
      pdfUrl = `http://localhost:${port}/pdfs/${pdfFilename}`
    } catch (err) {
      console.error('PDF 转换失败:', err)
      return res.status(500).json({
        success: false,
        message: 'PDF 转换失败，请检查文件格式或 LibreOffice 是否安装'
      })
    }
  }

  res.json({
    success: true,
    url: pdfUrl || originalUrl,
    name: decodedName
  })

  
})

// 启动服务
app.listen(port, () => {
  console.log(`✅ 上传服务运行中：http://localhost:${port}`)
})