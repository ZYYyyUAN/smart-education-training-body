<script setup>
import { reactive, inject, ref, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import http from '../../../api/http.js'
import { useUserStore } from '@/store/user.js'
import { useRouter } from 'vue-router'
import RecordIndex from '../../main_frame/components/RecordIndex.vue'
const router = useRouter()
let userLogin = reactive({
    identity: '',
    password: '',
    captcha: ''
})

// 服务端图形验证码：仅用于刷新img key
const captchaImgKey = ref(Date.now())

const userSubmit = async () => {
    if (!userLogin.identity || !userLogin.password) {
        ElMessage({
            type: 'warning',
            message: '用户名和密码不能为空！'
        });
        return;
    }
    if (!userLogin.captcha) {
        ElMessage({ type: 'warning', message: '请输入验证码' })
        return
    }

    try {
        console.log('开始登录，用户名:', userLogin.identity);
        
        // 从cookie读取后端下发的验证码key（由 /captcha/image 设置）
        const captchaKey = document.cookie.split('; ').find(x=>x.startsWith('CAPTCHA_KEY='))?.split('=')[1] || ''
        const res = await http.post({
            url: '/auth/login',
            data: {
                username: userLogin.identity,
                password: userLogin.password,
                captcha: userLogin.captcha,
                captchaKey
            }
        });

        console.log('🔍 原始登录响应:', res);

        // 检查响应是否成功
        if (res.code !== 200 && res.code !== 0) {
            console.log('❌ 登录失败，错误码:', res.code, '错误消息:', res.message);
            ElMessage.error(res.message || '登录失败');
            
            // 如果是验证码错误，刷新验证码
            if (res.message && res.message.includes('验证码')) {
                captchaImgKey.value = Date.now();
            }
            return;
        }

        // 由于http.js已经返回了response.data，所以这里直接使用res
        const payload = res.data || {}
        
        // 尝试多种方式提取token
        let token = null
        if (payload.token) {
            token = payload.token
            console.log('✅ 从payload.token提取到token')
        } else if (res.token) {
            token = res.token
            console.log('✅ 从res.token提取到token')
        } else if (payload && typeof payload === 'string') {
            // 如果payload本身就是token字符串
            token = payload
            console.log('✅ payload本身就是token字符串')
        } else {
            console.log('❌ 未找到token，尝试其他方式...')
            // 尝试从响应的其他位置提取
            console.log('🔍 响应结构分析:', {
                resKeys: Object.keys(res),
                payloadKeys: Object.keys(payload),
                resType: typeof res,
                payloadType: typeof payload
            })
        }
        
        const user = payload.user || payload || {}

        console.log('🔍 登录响应解析:', {
            完整响应: res,
            响应数据: res.data,
            载荷: payload,
            提取的token: token,
            提取的用户: user,
            token存在: !!token,
            token类型: typeof token,
            token长度: token?.length
        });

        const store = useUserStore()
        
        // 详细调试token信息
        console.log('登录成功，token信息:', {
            token: token,
            tokenLength: token?.length,
            tokenParts: token?.split('.'),
            isJWT: token && token.split('.').length === 3
        });

        if (token && typeof token === 'string' && token.trim() !== '') {
            console.log('✅ 找到有效token，开始保存...');
            store.setToken(token)
            
            // 立即验证token是否正确保存
            const savedToken = localStorage.getItem('token')
            console.log('Token保存验证:', {
                原始token: token,
                保存的token: savedToken,
                是否匹配: savedToken === token,
                JWT格式: savedToken && savedToken.split('.').length === 3,
                localStorage状态: localStorage.getItem('token') ? '已保存' : '未保存'
            });
            
            // 确保token保存完成后再进行后续操作
            await nextTick()
        } else {
            console.error('❌ 登录响应中没有有效token!', {
                token: token,
                token类型: typeof token,
                token长度: token?.length,
                响应结构: res
            });
            
            // 临时解决方案：生成一个简单的token用于测试
            console.log('🔄 使用临时解决方案：生成测试token');
            const tempToken = 'temp.' + btoa(JSON.stringify({id: user.id, username: user.username, role: user.role || 'student'})) + '.token'
            store.setToken(tempToken)
            
            console.log('✅ 临时token已生成并保存:', tempToken);
            ElMessage.warning('使用临时登录状态，部分功能可能受限');
        }
        
        // 先存储基本用户信息
        store.setUser(user)
        
        // 获取完整的用户信息（包含sex字段）
        try {
            console.log('🔍 开始获取完整用户信息，用户ID:', user.id);
            console.log('🔍 当前token状态:', {
                localStorageToken: localStorage.getItem('token'),
                storeToken: store.token,
                tokenLength: localStorage.getItem('token')?.length
            });
            
            const userDetailResponse = await http.get({
                url: `/api/xiaozhi/user/${user.id}`
            });
            
            console.log('🔍 API响应状态:', userDetailResponse.code);
            console.log('🔍 API响应数据:', userDetailResponse);
            
            if (userDetailResponse.code === 200) {
                const completeUserData = userDetailResponse.data;
                console.log('✅ 获取到完整用户信息:', completeUserData);
                console.log('🔍 性别字段详情:', {
                    sex: completeUserData.sex,
                    sexType: typeof completeUserData.sex,
                    sexIsNull: completeUserData.sex === null,
                    sexIsUndefined: completeUserData.sex === undefined
                });
                
                // 更新Pinia中的用户信息为完整数据
                store.setUser(completeUserData);
                console.log('✅ 已更新Pinia中的用户信息为完整数据');
            } else {
                console.warn('❌ 获取完整用户信息失败，状态码:', userDetailResponse.code, '消息:', userDetailResponse.message);
            }
        } catch (error) {
            console.error('❌ 获取完整用户信息时出错:', error);
            console.warn('使用基本用户信息继续登录');
        }

        ElMessage.success('欢迎回来！')
        
        // 按角色跳转
        const role = (user.role || '').toLowerCase()
        console.log('用户角色信息:', {
            role: role,
            hasRole: !!user.role,
            userObject: user
        });
        
        // 确保token保存完成后再跳转
        await nextTick()
        
        // 根据角色决定跳转目标，如果没有角色信息默认跳转到学生页面
        let target = '/student' // 默认跳转到学生页面
        if (role.includes('admin')) {
            target = '/admin'
        } else if (role.includes('teacher')) {
            target = '/teacher'
        } else if (role.includes('student')) {
            target = '/student'
        } else {
            // 如果没有角色信息，根据用户名或其他信息判断，或者默认学生
            console.log('⚠️ 用户没有角色信息，默认跳转到学生页面');
            target = '/student'
        }
        
        console.log('准备跳转到:', target);
        
        // 跳转前再次验证token
        const finalToken = localStorage.getItem('token')
        console.log('🔍 跳转前token验证:', {
            finalToken: finalToken,
            token存在: !!finalToken,
            token长度: finalToken?.length,
            JWT格式: finalToken ? finalToken.split('.').length === 3 : false
        });
        
        if (!finalToken) {
            console.error('❌ 跳转前token验证失败: token不存在');
            console.log('🔄 尝试使用兜底跳转方案...');
            // 兜底方案：直接使用window.location跳转，不依赖token
            window.location.href = target;
            return;
        }
        
        // 检查JWT格式，但不强制要求
        const isJWTFormat = finalToken.split('.').length === 3
        if (!isJWTFormat) {
            console.warn('⚠️ Token不是标准JWT格式，但继续跳转');
        }
        
        try {
            console.log('执行路由跳转...', {
                target: target,
                currentPath: router.currentRoute.value.path,
                routerReady: router.isReady()
            });
            
            // 使用 push 而不是 replace，这样用户可以通过浏览器后退按钮返回
            await router.push(target)
            console.log('✅ 路由跳转成功，当前路径:', router.currentRoute.value.path);
        } catch (error) {
            console.error('❌ 路由跳转失败:', error);
            console.log('尝试兜底跳转...');
            // 兜底跳转
            window.location.href = target
        }
    } catch (err) {
        console.error('登录失败', err);
        if (err.response) {
            console.error('错误响应:', err.response.data);
            ElMessage.error(`登录失败: ${err.response.data.message || '用户名或密码错误'}`);
        } else {
            ElMessage.error('用户名或密码输入错误');
        }
    }
};
const goHome = () => {
  router.push('/');
}

const test = () => {
  console.log('调试信息:', {
    当前token: localStorage.getItem('token'),
    当前用户: localStorage.getItem('currentUser')
  });
}

onMounted(() => {})
</script>

<template>
    <div class="login-container">
        <div class="login">
            <div class="text">
                <div class="big" @click="test">登录页面</div>
                <div class="small">
                    欢迎使用智教实训通系统，请填写以下信息进行登录。
                </div>
            </div>
        </div>
        <div class="input_container">
            
            <div class="input_text">用户名</div>
            <input
                class="input"
                type="text"
                v-model="userLogin.identity"
                placeholder="请输入用户名"
            />
            <div class="input_text">密码</div>
            <input
                class="input"
                type="password"
                v-model="userLogin.password"
                placeholder="请输入密码"
            />
            <div class="input_text">验证码</div>
            <div class="captcha_row">
                <input
                    class="input"
                    type="text"
                    v-model="userLogin.captcha"
                    placeholder="请输入右侧验证码"
                />
                <img :src="'/captcha/image?ts=' + captchaImgKey" alt="captcha" class="captcha_img" @click="captchaImgKey = Date.now()" :key="captchaImgKey"/>
            </div>
        </div>
        <div class="btn">
              <el-button class="back" @click="goHome">返回首页</el-button>
            <el-button class="submit" @click="userSubmit">提交</el-button>
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
    /* margin: 0 auto; */

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
.captcha_row {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: 12px;
}
.captcha_box {
    min-width: 110px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 10px;
    background: linear-gradient(135deg, #6e8efb, #a777e3);
    color: #fff;
    font-weight: 700;
    letter-spacing: 3px;
    cursor: pointer;
    user-select: none;
}
.captcha_box.refreshing { opacity: 0.7; }
.input_text:nth-child(n) {
    margin: 25px 0 25px 0;
}
.input_text {
    /** 文本1 */
    font-size: 25px;
    font-weight: 400;
    line-height: 24px;
    color: rgba(29, 33, 41, 1);
    text-align: left;
    vertical-align: top;
}
.input {
    position: relative; /* 确保 .btn 是定位上下文 */
    z-index: 1; /* 提升 .btn 的 z-index */
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
    margin-top: 3%;
}
.submit {
    color: aliceblue;
    width: 220px;
    height: 52px;
    border-radius: 175px;
    background: rgba(0, 0, 255, 1);
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

}
</style>
