---
name: weapp-design-paradigm
slug: weapp-design-paradigm
displayName: 微信小程序设计范式
version: "1.2.0"
summary: 微信小程序界面设计范式与适配规范，整合官方设计指南、大屏适配指南、DarkMode、适老化与无障碍规范，并提供大小屏适配、状态栏沉浸、胶囊避让、安全区预留、系统组件规避的可执行方案与复用组件。
description: 微信小程序界面设计范式与适配规范。整合微信官方设计指南（七大章节、字体 22/17/15/14/12pt、375/390px 设计稿基准、7-9mm 触控、Tab 2-5 个）、大屏适配指南（7 种布局模式、PC 默认 414×736、resizable）、DarkMode（theme.json）、适老化（关怀模式 1.4 倍）与无障碍（aria-component），以及自定义导航栏、沉浸式状态栏、刘海屏/全面屏适配、胶囊按钮避让、安全区（safe-area）适配、大小屏/iPad/折叠屏/横屏适配、rpx/vw 单位、底部 tabBar 与吸底操作栏适配。当开发/审查小程序页面、做界面设计评审、编写 WXML/WXSS 时，必须加载本 skill。触发词：小程序设计、设计规范、小程序适配、导航栏、状态栏、沉浸式、胶囊、安全区、刘海屏、rpx、vw、大小屏、大屏、PC 适配、暗色模式、DarkMode、适老化、无障碍。
---

# Weapp Design Paradigm（微信小程序设计范式）

## Overview

规范微信小程序界面设计与适配的六类核心问题：状态栏沉浸、胶囊按钮避让、安全区预留、大小屏/大屏响应式、系统组件规避、主题与可访问性（DarkMode/适老化/无障碍）。核心原则只有一条：**所有边界尺寸必须动态获取，禁止硬编码**。

## 适配总览图（先建立空间模型）

```
┌─────────────────────────────────┐ ─┬─ 屏幕顶 y=0
│  状态栏 (statusBarHeight)        │  │ 沉浸区：页面背景可延伸至此
├─────────────────────────────────┤ ─┤
│  导航栏区 (navBarHeight)  [胶囊]◀│  │ 胶囊按钮是系统级控件，永远在右上角
├─────────────────────────────────┤ ─┤ ← 导航栏底线 = safeArea.top 附近
│                                 │  │
│  页面内容区（可控）               │  │
│                                 │  │
├─────────────────────────────────┤ ─┤ ← safeArea.bottom
│  底部安全区 (Home 指示条) 34px    │  │ 吸底元素必须避让
└─────────────────────────────────┘ ─┴─ 屏幕底
```

## 硬性规则（红线）

1. **禁止硬编码**：状态栏高度、导航栏高度、胶囊位置、安全区高度一律动态获取。禁止出现 `padding-top: 44px`（状态栏）、`height: 88px`（导航栏）等魔法数。
2. **胶囊不可定制**：胶囊按钮是微信原生控件，只有深浅两套配色，任何页面它都在。自定义导航栏的所有右侧内容必须避让胶囊区。
3. **getSystemInfoSync 已废弃**：基础库 2.20.1 起停止维护。新代码一律用 `wx.getWindowInfo()` / `wx.getDeviceInfo()` / `wx.getAppBaseInfo()`。
4. **字号下限 24rpx（≈12pt）**：更小字号在小屏上不可读；320px 窄屏建议直接锁 12px。系统强制文案（版权、法律声明）也不例外。
5. **constant() 在前 env() 在后**：CSS 安全区兼容写法顺序不能反，引擎会忽略不认识的函数。

## 决策流程

```
接到一个页面 →
├─ 需要沉浸式头部（图片背景/搜索框上移/纯色延伸到状态栏）？
│   └─ 是 → 页面 json 配 navigationStyle: custom → 走【沉浸式范式】
│   └─ 否 → 保持默认导航栏 → 只需处理底部安全区
├─ 页面有吸底操作栏/tabBar？
│   └─ 是 → 走【底部安全区范式】
├─ 需要 iPad/折叠屏/横屏/PC 大屏支持？
│   └─ 是 → 走【大小屏范式】，app.json 配 resizable + pageOrientation（见 3.3 / 3.5）
├─ 需要暗色模式/适老化/无障碍？
│   └─ 是 → 走【主题与可访问性范式】
└─ 页面里有 map/video/canvas/textarea 等原生组件？
    └─ 是 → 走【原生组件规避范式】
```

## 范式一：沉浸式状态栏 + 自定义导航栏

### 1.1 配置

页面 json（推荐页面级，慎用全局）：

```json
{
  "navigationStyle": "custom"
}
```

全局配置会影响所有页面，简单页面需显式覆盖回 `default`。

### 1.2 高度计算（核心公式）

在 `app.js` 的 `onLaunch` 中计算一次，存入 globalData：

```js
App({
  onLaunch() {
    this.calcNavBarInfo()
  },
  globalData: {
    statusBarHeight: 0,   // 状态栏高度 px
    navBarHeight: 0,      // 导航栏总高（状态栏 + 标题栏）px
    menuHeight: 0,        // 胶囊高度 px
    menuBottom: 0,        // 胶囊上下间距（对称）px
    menuRight: 0,         // 胶囊右边缘距屏幕右侧 px
    contentPaddingRight: 0 // 标题需避让胶囊的宽度 px
  },
  calcNavBarInfo() {
    // 新 API（基础库 >= 2.20.1）
    const win = wx.getWindowInfo()
    const menu = wx.getMenuButtonBoundingClientRect()

    // 降级：胶囊 rect 偶发返回全 0，用固定值兜底（标题栏 = 胶囊32 + 间距*2）
    if (!menu || !menu.top || !menu.height) {
      const isIOS = /ios/i.test(wx.getDeviceInfo().system)
      this.globalData.statusBarHeight = win.statusBarHeight || (isIOS ? 44 : 24)
      this.globalData.menuHeight = 32
      this.globalData.menuBottom = isIOS ? 4 : 7
      this.globalData.navBarHeight = this.globalData.statusBarHeight + (isIOS ? 40 : 46)
      this.globalData.menuRight = 7
      this.globalData.contentPaddingRight = 94
      return
    }

    const gap = menu.top - win.statusBarHeight // 胶囊上下间距
    this.globalData.statusBarHeight = win.statusBarHeight
    // 导航栏总高 = 状态栏 + 间距*2 + 胶囊高（保证标题栏与胶囊垂直居中且上下对称）
    this.globalData.navBarHeight = menu.bottom + gap
    this.globalData.menuHeight = menu.height
    this.globalData.menuBottom = gap
    this.globalData.menuRight = win.screenWidth - menu.right
    // 自定义导航栏内容（标题/按钮）右边界不能超过胶囊 left
    this.globalData.contentPaddingRight = win.screenWidth - menu.left
  }
})
```

### 1.3 通用导航栏组件

完整可复用组件四件套（js/json/wxml/wxss）见 [references/navbar-component.md](references/navbar-component.md)，按文件名保存到项目 `components/nav-bar/` 下即可使用。要点：

- 容器 `position: fixed; top: 0`，高度绑 `navBarHeight`
- 状态栏区域单独一个占位 view（背景色与导航栏一致，实现沉浸）
- 标题区使用 `padding-right: contentPaddingRight + 'px'` 避开胶囊
- 页面内容用等高占位 view 撑开，避免 fixed 导航遮挡内容

### 1.4 机型参考值（仅用于校验，禁止用于编码）

| 机型 | 状态栏 | 胶囊高 | 上下间距 | 导航栏总高 |
|------|-------|--------|---------|-----------|
| iPhone 8 及以下 | 20 | 32 | 4 | 60 |
| iPhone X~15 系列 | 44~59 | 32 | 4 | 84~99 |
| Android 主流（非刘海） | 24 | 29~32 | 7 | 67~70 |
| Android 刘海/挖孔 | 24~48 | 29~32 | 4~7 | 61~94 |

> Android 机型碎片化严重，上表只用于判断计算结果是否明显异常。

## 范式二：底部安全区（吸底按钮 / 自定义 tabBar）

### 2.1 CSS 方案（首选）

```css
/* 吸底操作栏 */
.footer-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding-bottom: constant(safe-area-inset-bottom); /* iOS 11.0-11.2 */
  padding-bottom: env(safe-area-inset-bottom);      /* iOS 11.2+ */
}

/* 高度固定的吸底元素：用 calc 扩展，扩展区必须有背景色 */
.footer-calc {
  height: calc(120rpx + constant(safe-area-inset-bottom));
  height: calc(120rpx + env(safe-area-inset-bottom));
  background: #fff;
}
```

### 2.2 JS 方案（CSS 失效时兜底）

部分安卓 ROM（EMUI/旧版 MIUI）和微信 8.0.32 以下版本 `env()` 可能返回 0：

```js
// 小程序 WXSS 天然支持 env()，无需 viewport-fit 配置（那是 H5 的要求）
const win = wx.getWindowInfo()
const safeBottom = win.safeArea ? win.screenHeight - win.safeArea.bottom : 0
this.setData({ safeBottom })
```

```xml
<view class="footer" style="padding-bottom: {{safeBottom}}px">...</view>
```

### 2.3 自定义 tabBar

自定义 tabBar 容器必须包含 `env(safe-area-inset-bottom)` 的 padding-bottom，且内容高度（不含安全区）建议 100~120rpx，触控目标最小 88rpx。

## 范式三：大小屏响应式（手机 / iPad / 折叠屏 / 横屏）

### 3.1 单位选择（官方已优先推荐 vw）

> 官方 WXSS 原文：CSS 标准的 `vw` 已获广泛支持，**优先推荐 vw**；不建议滥用 vw/rpx，需配合 Media Query。基础库 3.3.0+ 可开 `"convertRpxToVw": true` 修复 rpx 精度问题。

| 场景 | 用什么 | 原因 |
|------|-------|------|
| 布局尺寸（宽高/边距/圆角） | rpx（存量）/ vw（新项目优先） | 随屏宽等比；新项目按官方建议用 vw |
| 字号正文/标题 | rpx 或 px（设上限） | 大屏需防字号被等比放大 |
| 微文案、表单标签 | px，最小 12px | 小屏可读性 |
| 1px 发丝线、阴影偏移 | px | rpx 在窄屏会小于 0.5px 消失 |
| 内容容器最大宽度 | px + max-width | 防大屏过度拉伸 |

### 3.2 rpx 缺陷与大屏约束（必做）

rpx 按 750 等分屏宽，iPad 横屏（窗口宽 >1000px）下元素会等比放大到不可接受。所有页面根容器必须约束：

```css
/* 页面根容器：大屏下限制内容宽度并居中 */
.page-root {
  width: 100%;
  max-width: 750px;   /* 大屏封顶；内容型页面建议 480~600px 更易读 */
  margin: 0 auto;
}

/* 断点：iPad / 折叠屏展开 */
@media (min-width: 768px) {
  .list { display: flex; flex-wrap: wrap; }
  .list-item { width: 50%; }          /* 单列变双列 */
  .product-grid .item { width: 33.33%; }
}

/* 断点：横屏手机 / 桌面微信 */
@media (orientation: landscape) {
  .form-row { display: flex; gap: 24rpx; }
}
```

- 断点参考：480px（大屏手机/折叠屏折叠态）、768px（iPad 竖/折叠屏展开）、1024px（iPad 横屏）
- `@media` 官方明确支持；逻辑判断用 `match-media` 组件或 `this.createMediaQueryObserver()`（详见 [references/layout-adaptation.md](references/layout-adaptation.md) §4）
- WXSS 媒体查询阈值用 px 写（媒体查询里 rpx 表现不稳定）

### 3.3 横屏与屏幕旋转

`app.json` 中：

```json
{
  "resizable": true,
  "pageOrientation": "auto"
}
```

- `resizable`：iPad 支持屏幕旋转、PC 可任意拖拽/最大化窗口（默认关闭，2.3.0+）
- `pageOrientation`：`auto` 跟随旋转（2.4.0+）/ `landscape` 固定横屏（2.5.0+）/ `portrait` 默认
- 组件内用 `pageLifetimes.resize` 监听；`wx.onWindowResize` 官方标注不推荐

配合页面 `onResize` 重新计算导航与安全区（横竖屏切换后 statusBarHeight/safeArea 会变化）：

```js
Page({
  onResize() {
    // 旋转后 statusBarHeight/safeArea/胶囊位置可能变化，必须重算而非读旧缓存
    const app = getApp()
    if (app.calcNavBarInfo) app.calcNavBarInfo()
    const win = wx.getWindowInfo()
    const g = app.globalData || {}
    this.setData({
      navBarHeight: g.navBarHeight,
      safeBottom: win.safeArea ? win.screenHeight - win.safeArea.bottom : 0
    })
  }
})
```

### 3.4 rpx↔px 换算（canvas/动画场景）

```js
// canvas、wx.createSelectorQuery、动画接口全部只认 px
function rpx2px(rpx) {
  return rpx / 750 * wx.getWindowInfo().windowWidth
}
```

### 3.5 大屏与响应式（官方 7 种布局模式）

官方给出七种动态布局：**左右伸缩、换行排列、横向拓展、分页展现、分层展现、自由布局、侧边栏**。完整规则见 [references/layout-adaptation.md](references/layout-adaptation.md) §5.3。

- 未配 `resizable` 时，PC 端固定 414×736（竖屏）/ 768×1024（横屏），窗口**不可拖拽**
- `Navigation Bar` 与 `Tab Bar` 高度在大屏下**保持不变**
- PC 端下拉刷新不友好，刷新需提供按钮等稳定形式
- 栅格：`row/col` 整行最多 **24 份**；PC 可启用分栏模式（frameset）

## 范式四：系统组件区域规避速查

| 系统元素 | 位置 | 规避方式 |
|---------|------|---------|
| 胶囊按钮 | 右上角，永远存在 | 右侧内容右边界 ≤ 胶囊 left；导航栏标题区 padding-right ≥ contentPaddingRight |
| 状态栏 | 顶部 | 沉浸式：背景延伸 + 内容从 navBarHeight 以下开始 |
| Home 指示条 | 底部 34px (iOS) | env(safe-area-inset-bottom) |
| 原生 tabBar | 底部 | 页面高度计算用 windowHeight（不含 tabBar），不要用 screenHeight |
| 键盘 | 底部弹出 | input/textarea 配 `adjust-position="{{false}}"` + `bindkeyboardheightchange` 手动上移 |
| 悬浮权限弹窗 | 顶部系统级 | 页面顶部关键操作按钮下移至 navBarHeight + 8px 之后 |

## 范式五：原生组件层级规避

map/video/canvas/camera/live-player 等原生组件层级最高，普通 view 盖不住（同层渲染仅部分场景生效）。规则：

1. 需要覆盖在原生组件上的元素（关闭按钮、蒙层、弹窗）用 `cover-view` / `cover-image`。
2. 弹窗类交互优先把原生组件 `wx:if` 隐藏再展示弹窗，而非依赖 cover-view 排版（cover-view 内组件受限，不支持复杂布局）。
3. 同层渲染：video（基础库 2.4.0+）、map/canvas 2d（2.7.0+）已支持，可按普通组件处理，但安卓端仍有兼容风险，关键 UI 不依赖同层渲染。

## 范式六：主题与可访问性（DarkMode / 适老化 / 无障碍）

完整规则见 [references/theme-accessibility.md](references/theme-accessibility.md)。

| 主题 | 最小落地 |
|------|---------|
| DarkMode | `app.json` 配 `"darkmode": true` + `"themeLocation": "theme.json"`，颜色用 `@变量`；WXSS 用 `@media (prefers-color-scheme: dark)` |
| 适老化 | 读 `wx.getAppBaseInfo().fontSizeSetting`；元素随倍率放大、间距固定；关怀模式 ×1.4；对比度 ≥4.5:1 |
| 无障碍 | 非原生内容用 aria-component：`aria-role` / `aria-label` / `aria-hidden`；装饰图隐藏，图标按钮必须有替代文本 |

关键约束：

- `prefers-color-scheme` **不受** `darkmode` 开关影响，系统切暗色即生效
- 主题切换事件**只在** `darkmode: true` 时触发
- 自定义导航栏、自定义 tabBar **不会**自动适老化，需按 1.18 / 1.4 倍率单独适配
- 小元素热区最小 **40×40pt**，图标周围加 **12pt** 反馈热区
- 文本对比度 ≥ 4.5:1（大字 >18dp/pt 时 ≥3:1）

## 检查清单（交付前逐项过）

- [ ] 无硬编码状态栏/导航栏高度，无 `44px`/`88px` 魔法数
- [ ] 自定义导航栏标题在胶囊左侧区域内，未遮挡
- [ ] iOS 全 0 降级分支已写（胶囊 rect 可能为 0）
- [ ] `safeArea` 已判空（部分机型不返回该字段）
- [ ] 吸底元素有 safe-area-inset-bottom，扩展区有背景色
- [ ] 页面根容器有 max-width 约束（防 iPad/PC 拉伸）
- [ ] 关键断点（480 / 768 / 1024）有布局变化处理
- [ ] PC 拖拽窗口无横向滚动条，大屏下导航栏/Tab 高度未放大
- [ ] 横屏场景监听 onResize 重算高度
- [ ] 原生组件上的覆盖层用 cover-view 或改为条件隐藏
- [ ] 字号 ≥ 24rpx（微文案 ≥ 12px）
- [ ] DarkMode 下文字对比度 ≥ 4.5:1
- [ ] 图标按钮有 `aria-label`，装饰图 `aria-hidden`
- [ ] 自定义导航栏/自定义 tabBar 已按适老化倍率适配
- [ ] 触控目标 ≥ 88rpx（小元素热区 ≥ 40×40pt）
- [ ] 真机验证过：至少 1 台 iOS 刘海屏 + 1 台 Android

## 官方设计规范速查（对齐官方口径）

> 完整原文整理见 [references/official-design-guide.md](references/official-design-guide.md)。

**官方规范要点（一句话版）**

| 原则 | 要求 |
|------|------|
| 友好礼貌 | 每页一个重点；不做打断目标流程的内容 |
| 清晰明确 | 告知用户在哪、能去哪、怎么回；次级页左上角必有返回 |
| 便捷优雅 | 减少输入，优先让用户选择；触控区 7-9mm 防误操作 |
| 统一稳定 | 跨页控件与交互一致，优先用微信标准控件 |
| 视觉规范 | 字体跟随系统，字号只用 22/17/15/14/12pt |

**硬指标**

| 项 | 官方要求 | 换算 / 落地 |
|----|---------|------------|
| 字号 | 22 / 17 / 15 / 14 / 12 pt | 44 / 34 / 30 / 28 / 24 rpx（1pt = 2rpx） |
| 最小字号 | 12pt | 24rpx（与本 skill 红线一致） |
| 触控目标 | 7-9mm 物理尺寸 | 不小于 88rpx |
| Tab 数量 | 2-5 个，建议≤4 | 单页不超一组标签栏 |
| 设计稿基准 | 375px 固定布局 或 390px 响应式布局 | 375px 稿 1px = 2rpx |
| 轻提示时长 | 图标型 / 文字型 1.5s 自动消失 | 错误提示禁用一闪而过形式 |
| 加载动画 | 同页最多 1 个 | 长加载须有取消 + 进度条 |

**不可自定义的系统区域**

- 胶囊（小程序菜单）：内容不可改，只能选深浅配色；必须预留区域，附近交互元素防冲突。
- 启动页：除 Logo 外全部由微信统一提供，不可改。
- 下拉刷新：微信提供标准样式，无需自研。

## References

- [references/spec-index.md](references/spec-index.md)：**规范索引与来源台账**，单一事实来源、官方 URL、版本基线、已知冲突与待验证项
- [references/official-design-guide.md](references/official-design-guide.md)：微信官方设计指南全文整理（七大章节 + 视觉规范 + 设计稿尺寸 + 落地映射）
- [references/layout-adaptation.md](references/layout-adaptation.md)：单位策略（vw/rpx）、设计稿基准、断点、旋转、媒体查询、大屏 7 种布局、栅格与分栏
- [references/theme-accessibility.md](references/theme-accessibility.md)：DarkMode、适老化、无障碍（aria）规则与落地清单
- [references/device-data.md](references/device-data.md)：主流机型状态栏/安全区/导航栏高度实测数据表，以及 rpx 换算表
- [references/api-guide.md](references/api-guide.md)：getWindowInfo/safeArea/胶囊 API 字段速查与降级策略

## Assets

- [references/navbar-component.md](references/navbar-component.md)：可直接复制的自定义导航栏组件四件套（js/json/wxml/wxss 代码，含胶囊避让与 iOS 降级）
