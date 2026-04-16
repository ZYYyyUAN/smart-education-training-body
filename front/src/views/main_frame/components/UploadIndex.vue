<!-- 上传图片界面 -->
<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import http from '../../../api/http.js'
// 提交成功后，控制图片的再次展示
let dialogPictureVisible = ref(false)

// img_url
const imgUrl = [
    'https://img.js.design/assets/img/657843b299920a4223384862.png',
    'https://img.js.design/assets/img/658329ee2ab3fa5e3cdb001e.png',
    'https://img.js.design/assets/img/658329ee7c6c4a259addfa54.png',
    'https://img.js.design/assets/img/658329eea9191da08245d7c4.png',
    'https://img.js.design/assets/img/657849f99ffa09f5ae6dfb85.png',
    'https://img.js.design/assets/img/658329eec992267b04a68adf.png',
    'https://img.js.design/assets/img/658329ee4d644979c8c3d62a.png',
    'https://img.js.design/assets/img/658329eea9191da08245d7c4.png'
]
// 预加载图片的函数
function preloadImages(urls) {
    const promises = urls.map((url) => {
        return new Promise((resolve, reject) => {
            /* 
            // 创建一个新的图像实例
var img = new Image();

// 设置图像的源
img.src = 'path/to/your/image.png';

// 添加加载完成的事件监听器
img.onload = function() {
  console.log('图像已加载');
  // 在这里可以将图像添加到 DOM 或进行其他操作
};

// 添加加载失败的事件监听器
img.onerror = function() {
  console.error('图像加载失败');
}; */
            const img = new Image()
            img.onload = () => resolve(img)
            img.onerror = reject
            img.src = url
        })
    })
    return Promise.all(promises)
}

// 在组件挂载后预加载图片
onMounted(() => {
    preloadImages(imgUrl)
        .then((images) => {
            console.log('所有图片已预加载完成')
        })
        .catch((error) => {
            console.error('预加载图片时发生错误', error)
        })
})

// 图片上传
const fileList = ref([])
const dialogImageUrl = ref('')
const dialogImageUrl2 = ref('')
const dialogVisible = ref(false)

const handleRemove = (uploadFile, uploadFiles) => {
    console.log(uploadFile, uploadFiles)
}

// 展示内容
const states = ref('')
const advice1 = reactive([
    '肺实质内无异常密度增高区域',
    '支气管壁光滑，无狭窄或扩张',
    '没有胸腔积液或其他伴随症状'
])
const advice2 = reactive([
    '结节边缘不规则，可能出现分叶状、毛刺征象',
    '可能伴有空洞形成、胸膜凹陷等表现',
    '可能存在淋巴结肿大或远处转移迹象'
])
const advice3 = reactive([
    '边缘较为光滑、圆润，形状规则',
    '密度相对均匀，可能呈现钙化点',
    '不会引起周围组织结构显著改变',
    '在增强扫描中，强化程度较低或无明显强化'
])
let advice = reactive()
// 全屏展示图片
const handlePictureCardPreview = (uploadFile) => {
    dialogImageUrl.value = uploadFile.url
    dialogVisible.value = true
}

const uploadFiles = async () => {
    // 控制图片的显示隐藏

    // 假设 fileList 是一个包含文件对象的数组
    let formData = new FormData()
    console.log('fileList', fileList.value)
    fileList.value.forEach((file) => {
        formData.append('file', file.raw)
        // axios.post('https://run.mocky.io/v3/9d059bf9-4660-45f2-925d-ce80ad6c4d15', formData, {

        // }).then(response => {
        //   console.log('Upload success', response);
        //  ElMessage({
        //         dangerouslyUseHTMLString: true,
        //         showClose: true,
        //         message: '<div class="tip">登录成功</div>',
        //         type: 'success'
        //     })
        // }).catch(error => {
        //   console.error('Upload error', error);
        // });
    })
    await http
        .post({
            url: '/tasks/create',
            data: formData
        })
        .then((res) => {
            dialogImageUrl2.value = fileList._rawValue[0].url
            dialogPictureVisible.value = true
            fileList.value = ''
            console.log(res)
            if (res.data.data == 'benign') {
                states.value = '良性'
                advice = [
                    '肺实质内无异常密度增高区域',
                    '支气管壁光滑，无狭窄或扩张',
                    '没有胸腔积液或其他伴随症状'
                ]
            } else if (res.data.data == 'malignant') {
                states.value = '恶性'
                advice = [
                    '结节边缘不规则，可能出现分叶状、毛刺征象',
                    '可能伴有空洞形成、胸膜凹陷等表现',
                    '可能存在淋巴结肿大或远处转移迹象'
                ]
            } else {
                states.value = '正常'
                advice = [
                    '肺实质内无异常密度增高区域',
                    '支气管壁光滑，无狭窄或扩张',
                    '没有胸腔积液或其他伴随症状'
                ]
            }
        })
    console.log(advice)

    console.log('Object.fromEntries(formData)', Object.fromEntries(formData))
}

const closeDialog2 = () => {
    dialogPictureVisible.value = false
}
</script>

<template>
    <div class="top">
        <div class="title">肺癌病例展示</div>
        <div class="text">以下是一些肺癌病例图片展示</div>
        <div class="img_container">
            <div class="small_img" v-for="(item, index) in imgUrl" :key="index">
                <img :src="item" alt="" />
            </div>
        </div>
    </div>
    <div class="big_img"></div>
    <div class="bottom">
        <div class="title">上传图片</div>
        <div class="text">请上传您的肺部CT图片</div>
        <div class="input_bottom">
            <div class="input_text">上传图片</div>
            <el-upload
                v-model:file-list="fileList"
                action="https://run.mocky.io/v3/9d059bf9-4660-45f2-925d-ce80ad6c4d15"
                list-type="picture-card"
                :on-preview="handlePictureCardPreview"
                :on-remove="handleRemove"
                :auto-upload="false"
            >
                <el-icon><Plus /></el-icon>
            </el-upload>

            <el-dialog v-model="dialogVisible" style="text-align: center">
                <img
                    style="width: 100%"
                    :src="dialogImageUrl"
                    alt="Preview Image"
                />
            </el-dialog>
        </div>
        <div>
            <el-button type="primary" class="upload_button" @click="uploadFiles"
                >上传图片</el-button
            >
        </div>
    </div>
    <el-dialog
        v-model="dialogPictureVisible"
        width="900"
        style="text-align: center"
    >
        <span class="advice">{{ states }}</span>
        <img style="width: 100%" :src="dialogImageUrl2" alt="Preview Image" />
        <div class="advice" v-for="(item, index) in advice" :key="index">
            {{ item }}
        </div>
        <template #footer>
            <div class="dialog-footer">
                <el-button type="primary" @click="dialogPictureVisible = false">
                    返回
                </el-button>
            </div>
        </template>
    </el-dialog>
</template>

<style scoped>
input[type='number']::-webkit-inner-spin-button,
input[type='number']::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
.title {
    margin-top: 90px;
    font-size: 56px;
    font-weight: 700;
    color: rgba(29, 33, 41, 1);
    text-align: center;
}

.text {
    margin-top: 20px;
    font-size: 18px;
    font-weight: 400;
    color: rgba(29, 33, 41, 1);
    text-align: center;
}

.img_container {
    display: grid;
    grid-template-columns: repeat(4, 1fr); /* 创建 4 列，每列占用等分的空间 */
    grid-template-rows: repeat(2, auto); /* 创建 2 行，行高自动 */
    gap: 5px; /* 设置网格项之间的间隙 */
    width: 86%;
    margin: 30px auto;
}
.small_img {
    margin: 10px;
    height: 300px;
}

.small_img > img {
    width: 100%;
    height: 100%;
}

.big_img {
    margin-left: 5%;
    width: 90%;
    height: 320px;
    opacity: 1;
    background: url(https://img.js.design/assets/img/657842649ebde7f10a9fd7b5.png)
        no-repeat center;
    background-position: 10% 60%;
    background-size: cover;
}
/* .big_img > img {
    width: 90%;
    height: 400px;
} */

.input_text {
    margin: 20px 0;
    font-size: 20px;
    font-weight: 550;
    color: rgba(29, 33, 41, 1);
    text-align: left;
    vertical-align: top;
}

.input_bottom {
    margin-top: 30px;
    margin: 0 auto;
    width: 48%;
}

.upload_button {
    cursor: pointer;
    margin-top: 80px;
    margin-left: 50%;
    transform: translateX(-360px);
    width: 720px;
    height: 52px;
    border-radius: 52px;
}

.advice {
    font-size: 40px;
    font-weight: 700;
    color: rgba(29, 33, 41, 1);
    margin-top: 40px;
}
</style>
