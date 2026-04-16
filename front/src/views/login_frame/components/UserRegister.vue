<script setup>
import { reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import http from '../../../api/http.js'

const router = useRouter()

// 表单数据
const registerForm = reactive({
    username: '',
    password: '',
    confirmPassword: '',
    email: '',
    role: 'student',
    real_name: '',
    sex: '',
    className: '',
    school: ''
})

// 详细的表单验证
const validateForm = () => {
    // 用户名验证
    if (!registerForm.username || registerForm.username.trim() === '') {
        ElMessage.warning('请输入用户名！')
        return false
    }
    if (registerForm.username.length < 3 || registerForm.username.length > 20) {
        ElMessage.warning('用户名长度应在3-20个字符之间！')
        return false
    }
    if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(registerForm.username)) {
        ElMessage.warning('用户名只能包含字母、数字、下划线和中文！')
        return false
    }
    
    // 密码验证
    if (!registerForm.password || registerForm.password.trim() === '') {
        ElMessage.warning('请输入密码！')
        return false
    }
    if (registerForm.password.length < 6 || registerForm.password.length > 20) {
        ElMessage.warning('密码长度应在6-20个字符之间！')
        return false
    }
    
    // 确认密码验证
    if (!registerForm.confirmPassword || registerForm.confirmPassword.trim() === '') {
        ElMessage.warning('请确认密码！')
        return false
    }
    if (registerForm.password !== registerForm.confirmPassword) {
        ElMessage.warning('两次输入的密码不一致！')
        return false
    }
    
    // 邮箱验证
    if (!registerForm.email || registerForm.email.trim() === '') {
        ElMessage.warning('请输入邮箱地址！')
        return false
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(registerForm.email)) {
        ElMessage.warning('请输入正确的邮箱格式！')
        return false
    }
    
    // 真实姓名验证
    if (!registerForm.real_name || registerForm.real_name.trim() === '') {
        ElMessage.warning('请输入真实姓名！')
        return false
    }
    if (registerForm.real_name.length < 2 || registerForm.real_name.length > 20) {
        ElMessage.warning('真实姓名长度应在2-20个字符之间！')
        return false
    }
    
    // 性别验证
    if (!registerForm.sex || registerForm.sex.trim() === '') {
        ElMessage.warning('请选择性别！')
        return false
    }
    
    // 学生角色班级验证
    if (registerForm.role === 'student') {
        if (!registerForm.className || registerForm.className.trim() === '') {
            ElMessage.warning('学生角色请填写班级信息！')
            return false
        }
        if (registerForm.className.length < 2 || registerForm.className.length > 50) {
            ElMessage.warning('班级名称长度应在2-50个字符之间！')
            return false
        }
    }
    
    // 学校验证
    if (!registerForm.school || registerForm.school.trim() === '') {
        ElMessage.warning('请填写学校名称！')
        return false
    }
    if (registerForm.school.length < 2 || registerForm.school.length > 100) {
        ElMessage.warning('学校名称长度应在2-100个字符之间！')
        return false
    }
    
    return true
}

// 角色选项
const roleOptions = [
    { label: '学生', value: 'student' },
    { label: '教师', value: 'teacher' },
    { label: '管理员', value: 'admin' }
]

// 性别选项
const sexOptions = [
    { label: '男', value: '男' },
    { label: '女', value: '女' }
]

// 是否显示班级字段（只有学生角色才显示）
const showClassField = computed(() => registerForm.role === 'student')

// 提交注册
const handleSubmit = async () => {
    if (!validateForm()) {
        return
    }
    
    try {
        // 构建提交数据
        const submitData = {
            username: registerForm.username,
            password: registerForm.password,
            email: registerForm.email,
            role: registerForm.role,
            real_name: registerForm.real_name,
            sex: registerForm.sex,
            school: registerForm.school
        }
        
        // 如果是学生角色，添加班级信息
        if (registerForm.role === 'student' && registerForm.className) {
            submitData.className = registerForm.className
        }
        
        // 发送注册请求
        const res = await http.post({
            url: '/auth/register',
            data: submitData
        })
        
        console.log('注册响应:', res)
        
        if (res.code === 200) {
            ElMessage.success('注册成功！')
            // 跳转到登录页面
            router.replace('/loginIndex/userLogin')
        } else {
            ElMessage.error(res.message || '注册失败')
        }
    } catch (error) {
        console.error('注册错误:', error)
        
        if (error.code === 'ERR_NETWORK') {
            ElMessage.error('网络连接失败，请检查后端服务是否启动')
        } else if (error.code === 'ECONNABORTED') {
            ElMessage.error('请求超时，请检查网络连接')
        } else if (error.response) {
            // 服务器响应了错误状态码
            const status = error.response.status
            if (status === 400) {
                ElMessage.error('请求参数错误，请检查输入信息')
            } else if (status === 500) {
                ElMessage.error('服务器内部错误，请稍后重试')
            } else {
                ElMessage.error(`注册失败，错误码：${status}`)
            }
        } else {
            ElMessage.error('注册失败，请检查网络连接')
        }
    }
}

// 重置表单
const resetForm = () => {
    registerForm.username = ''
    registerForm.password = ''
    registerForm.confirmPassword = ''
    registerForm.email = ''
    registerForm.role = 'student'
    registerForm.real_name = ''
    registerForm.sex = ''
    registerForm.className = ''
    registerForm.school = ''
}

// 已去除测试连接功能

// 返回首页
const goHome = () => {
    router.push('/')
}


</script>

<template>
    <div>
        <div class="register">
            <div class="text">
                <div class="big">注册页面</div>
                <div class="small">
                    欢迎使用智教实训通系统，请填写以下信息进行注册。
                </div>
            </div>
        </div>
        <div class="input_container">
            <div class="input_text">用户名</div>
            <input
                class="input"
                type="text"
                v-model="registerForm.username"
                placeholder="请输入用户名"
            />
            <div class="input_text">密码</div>
            <input
                class="input"
                type="password"
                v-model="registerForm.password"
                placeholder="请输入密码"
            />
            <div class="input_text">确认密码</div>
            <input
                class="input"
                type="password"
                v-model="registerForm.confirmPassword"
                placeholder="请再次输入密码"
            />
            <div class="input_text">邮箱</div>
            <input
                class="input"
                type="email"
                v-model="registerForm.email"
                placeholder="请输入邮箱地址"
            />
            <div class="input_text">角色</div>
            <select class="input" v-model="registerForm.role">
                <option value="student">学生</option>
                <option value="teacher">教师</option>
                <option value="admin">管理员</option>
            </select>
            <div class="input_text">真实姓名</div>
            <input
                class="input"
                type="text"
                v-model="registerForm.real_name"
                placeholder="请输入真实姓名"
            />
            <div class="input_text">性别</div>
            <select class="input" v-model="registerForm.sex">
                <option value="男">男</option>
                <option value="女">女</option>
            </select>
            <div class="input_text">学校</div>
            <input
                class="input"
                type="text"
                v-model="registerForm.school"
                placeholder="请输入学校名称（如：智教实训通学院）"
            />
            <div v-if="showClassField" class="input_text">班级</div>
            <input
                v-if="showClassField"
                class="input"
                type="text"
                v-model="registerForm.className"
                placeholder="请输入班级（如：计算机科学1班）"
            />
        </div>
        <div class="btn">
            <el-button class="back" @click="goHome">返回首页</el-button>
            <el-button class="reset" @click="resetForm">重置</el-button>
            
            <el-button class="submit" @click="handleSubmit">注册</el-button>
        </div>
        <div class="color"></div>
    </div>
</template>

<style scoped>
.text {
    text-align: center;
}
.big {
    margin: 50px 0 20px 0;
    font-size: 48px;
    font-weight: 700;
    line-height: 56px;
    color: rgba(29, 33, 41, 1);
    vertical-align: top;
}

.small {
    font-size: 18px;
    font-weight: 400;
    line-height: 28px;
    color: rgba(29, 33, 41, 1);
    vertical-align: top;
}

.input_container {
    margin-top: 100px;
    margin-left: 33%;
}
.input_text:nth-child(n) {
    margin: 25px 0 25px 0;
}
.input_text {
    font-size: 25px;
    font-weight: 400;
    line-height: 24px;
    color: rgba(29, 33, 41, 1);
    text-align: left;
    vertical-align: top;
}
.input {
    position: relative;
    z-index: 1;
    font-size: 16px;
    outline: none;
    padding-left: 15px;
    width: 336px;
    height: 52px;
    opacity: 1;
    border-radius: 40px;
    background: rgba(255, 255, 255, 1);
    border: 1px solid rgba(0, 0, 0, 0.1);
}

.input:focus {
    border: 1px solid rgba(0, 0, 0, 0.6);
}
.btn {
    text-align: center;
    margin-top: 10%;
}
.submit {
    color: aliceblue;
    width: 220px;
    height: 52px;
    border-radius: 175px;
    background: rgba(0, 0, 255, 1);
    margin: 0 10px;
}

.reset {
    color: aliceblue;
    width: 220px;
    height: 52px;
    border-radius: 175px;
    background: rgba(255, 165, 0, 1);
    margin: 0 10px;
}

.test {
    color: aliceblue;
    width: 220px;
    height: 52px;
    border-radius: 175px;
    background: rgba(34, 139, 34, 1);
    margin: 0 10px;
}

.color {
    float: left;
    position: absolute;
    top: 500px;
    left: 800px;
    width: 509.06px;
    height: 156.52px;
    opacity: 1;
    transform: rotate(31.71deg);
    background: linear-gradient(
        90deg,
        rgba(240, 0, 240, 0.15) 0%,
        rgba(0, 128, 255, 0.15) 45.84%,
        rgba(21, 0, 255, 0.15) 100%
    );
    filter: blur(100px);
}
.back {
  width: 220px;
  height: 52px;
  border-radius: 175px;
  background: rgba(100, 100, 100, 0.8);
  color: white;
  margin: 0 10px;
}
</style>
