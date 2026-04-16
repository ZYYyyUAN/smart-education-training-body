<script setup>
import { ref } from 'vue'

// 邮箱输入框的响应式数据
const input = ref('')
</script>

<template>
    <div class="floor">
        <div class="b_left">
            <div class="b_left_color"></div>
            <div class="tltle">智教实训通</div>
            <div class="follow">关注我们的GitHub</div>
            <div class="input">
                <input
                    v-model="input"
                    style="
                        padding-left: 15px;
                        width: 336px;
                        height: 52px;
                        opacity: 1;
                        border-radius: 40px;
                        background: rgba(255, 255, 255, 1);
                        border: 1px solid rgba(0, 0, 0, 0.1);
                    "
                    placeholder="输入您的邮箱地址"
                />
                <button>订阅</button>
            </div>
        </div>
        <div class="b_right">
            <div class="text">关注我们</div>
            <div class="icon">
                <img
                    style="width: 20px; height: 16.24px"
                    src="../assets/icon/image.png"
                    alt=""
                />
            </div>
        </div>
    </div>
</template>

<style scoped>
.floor {
    display: flex;
    justify-content: space-between;
    height: 396px;
}
.b_left {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    width: 65%;
    margin-left: 80px;
}

.tltle {
    margin-left: 20px;
    font-size: 22px;
    font-weight: 700;
    letter-spacing: 0px;
    line-height: 22px;
    color: rgba(29, 33, 41, 1);
    text-align: left;
    vertical-align: top;
     color: #fff;
}
.follow {
    margin: 30px 0;
    font-size: 16px;
    font-weight: 400;
    letter-spacing: 0px;
    line-height: 24px;
    color: rgba(29, 33, 41, 1);
    text-align: left;
    vertical-align: top;
     color: #fff;
}
.input button {
    margin-left: 30px;
    color: #fff;
    width: 88px;
    height: 52px;
    border: 0;
    border-radius: 40px;
    background: rgba(0, 0, 255, 1);
}

.b_right {
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-size: 16px;
    font-weight: 700;
    width: 35%;
    text-align: center;
}
.text {
    margin: 0 0 20px -80px;
}

.b_left_color {
    position: absolute;

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
</style>
