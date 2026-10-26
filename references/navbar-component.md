# 自定义导航栏组件（nav-bar 四件套）

> 使用方式：将下列 4 段代码分别保存为项目 `components/nav-bar/` 下的同名文件，页面 json 中 `"usingComponents": {"nav-bar": "/components/nav-bar/nav-bar"}` 引用。

## nav-bar.js

```js
// 自定义导航栏组件逻辑
// 用法：<nav-bar title="页面标题" back="{{true}}" bind:back="onBack" />
Component({
  options: { multipleSlots: true },
  properties: {
    title: { type: String, value: '' },
    back: { type: Boolean, value: false },       // 是否显示返回按钮
    transparent: { type: Boolean, value: false } // 沉浸透明模式（背景透出）
  },
  data: {
    statusBarHeight: 0,
    navBarHeight: 0,        // 状态栏 + 标题栏总高
    titleBarHeight: 0,      // 标题栏（胶囊行）高度
    menuHeight: 32,
    contentPaddingRight: 94 // 标题区右侧避让胶囊（默认 = 7 右距 + 87 胶囊宽，初始化时动态覆盖）
  },
  lifetimes: {
    attached() {
      this.init()
    }
  },
  methods: {
    init() {
      const app = getApp()
      // 优先读全局缓存（app.js onLaunch 已算好）
      if (app && app.globalData && app.globalData.navBarHeight > 0) {
        const g = app.globalData
        this.setData({
          statusBarHeight: g.statusBarHeight,
          navBarHeight: g.navBarHeight,
          titleBarHeight: g.navBarHeight - g.statusBarHeight,
          menuHeight: g.menuHeight,
          contentPaddingRight: g.contentPaddingRight
        })
        return
      }
      // 无全局缓存时自行计算（含降级）
      const hasNewAPI = typeof wx.getWindowInfo === 'function'
      const win = hasNewAPI ? wx.getWindowInfo() : wx.getSystemInfoSync()
      const source = hasNewAPI ? wx.getDeviceInfo() : wx.getSystemInfoSync()
      const isIOS = /ios/i.test(source.system || '')
      const statusBarHeight = win.statusBarHeight || (isIOS ? 44 : 24)
      let menuHeight = 32, gap = 4
      let rect = null
      try { rect = wx.getMenuButtonBoundingClientRect() } catch (e) { rect = null }
      if (!rect || !rect.top || !rect.height) {
        // 胶囊 rect 偶发全 0（iOS 多见）→ 固定值兜底：胶囊高 32，间距 iOS 4 / Android 7
        menuHeight = 32
        gap = isIOS ? 4 : 7
      } else {
        menuHeight = rect.height
        gap = rect.top - statusBarHeight
      }
      const titleBarHeight = menuHeight + gap * 2
      const menu = rect || { height: menuHeight, left: win.screenWidth - 7 - 87 }
      this.setData({
        statusBarHeight,
        navBarHeight: statusBarHeight + titleBarHeight,
        titleBarHeight,
        menuHeight,
        contentPaddingRight: win.screenWidth - menu.left
      })
    },
    onBack() {
      this.triggerEvent('back')
      const pages = getCurrentPages()
      if (pages.length > 1) {
        wx.navigateBack()
      } else {
        // reLaunch 对 tabBar 页和非 tabBar 页都有效；目标路径按项目首页调整
        wx.reLaunch({ url: '/pages/index/index' })
      }
    }
  }
})
```

## nav-bar.json

```json
{
  "component": true,
  "styleIsolation": "isolated"
}
```

## nav-bar.wxml

```xml
<!-- 自定义导航栏：状态栏沉浸 + 胶囊避让 -->
<view class="nav-container {{transparent ? 'nav-transparent' : ''}}" style="height: {{navBarHeight}}px;">
  <!-- 状态栏占位（沉浸区：背景与导航栏一致，内容不放这里） -->
  <view class="status-bar" style="height: {{statusBarHeight}}px;"></view>
  <!-- 标题栏：与胶囊垂直居中对齐 -->
  <view class="title-bar" style="height: {{titleBarHeight}}px; padding-right: {{contentPaddingRight}}px;">
    <view wx:if="{{back}}" class="nav-back" style="height: {{menuHeight}}px; width: {{menuHeight}}px;" bind:tap="onBack">
      <view class="back-arrow"></view>
    </view>
    <view class="nav-title">{{title}}</view>
    <slot name="right"></slot>
  </view>
</view>
<!-- 固定定位占位：撑开页面内容，防止被 fixed 导航遮挡（transparent 沉浸模式不占位，内容顶到导航栏下方） -->
<view wx:if="{{!transparent}}" style="height: {{navBarHeight}}px;"></view>
```

## nav-bar.wxss

```css
/* 自定义导航栏样式 */
.nav-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 1000;
  background: #ffffff;
}

.nav-transparent {
  background: transparent;
}

.status-bar {
  width: 100%;
}

.title-bar {
  position: relative;
  display: flex;
  align-items: center;
  box-sizing: border-box;
  padding-left: 24rpx;
}

.nav-back {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-right: 16rpx;
}

.back-arrow {
  width: 20rpx;
  height: 20rpx;
  border-left: 4rpx solid #232323;
  border-bottom: 4rpx solid #232323;
  transform: rotate(45deg);
}

.nav-title {
  /* 绝对定位在胶囊左侧可用区域内水平居中，与微信原生导航视觉一致 */
  position: absolute;
  left: 88rpx;
  right: 88rpx;
  text-align: center;
  font-size: 34rpx;
  font-weight: 600;
  color: #232323;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  pointer-events: none;
}
```
