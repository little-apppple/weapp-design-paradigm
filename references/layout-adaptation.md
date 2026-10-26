# 布局与屏幕适配（统一文档）

> 本文整合官方三处来源：WXSS 尺寸单位、响应显示区域变化（resizable）、大屏适配指南（design/adapt + framework/ability/adapt）。所有结论以官方文档为准，经验值单独标注。

---

## 一、适配场景分类（官方口径）

| 场景 | 官方做法 |
|------|---------|
| 同类设备尺寸细微差别（手机之间） | 用 `rpx` 等比缩放 |
| 允许旋转（手机横竖屏 / iPad） | 手机配 `pageOrientation: auto`；iPad 配 `resizable: true`；用 `onResize` 监听 |
| 不同类设备 / PC 可自由拖拽窗口 | CSS 媒体查询 + Flex/Grid；`match-media`、`MediaQueryObserver`；`row/col` 栅格；分栏模式 |

官方原文要点：设备分为小屏手机、中屏平板、大屏 PC 三类，类内还有碎片化差异。

---

## 二、单位策略（重要更新，官方已转向 vw）

### 2.1 rpx 定义

- `rpx` 表达**页面总宽度的 1/750**。屏宽 375px 时，`1rpx = 0.5px`。
- 计算规则有时会对转换结果**取整**，带来精度问题。

### 2.2 官方最新建议

> WXSS 文档原文：「由于现在 CSS 标准的 `vw` 单位已经得到广泛支持，所以还是优先推荐使用 `vw`。」「不建议滥用 `vw` `rpx` 等基于屏幕宽度比例的单位；如果不可避免，请联合使用 Media Query 等响应式布局方式。」

- 基础库 **3.3.0+** 可开启 `app.json` 的 `"convertRpxToVw": true`，把 rpx 转为 vw，修复精度问题。
- 结论：
  - **存量项目**继续用 rpx 可以，但大屏必须加 `max-width` + 断点。
  - **新项目**优先 `vw`（或 rpx + `convertRpxToVw`），并始终配合媒体查询。
  - 字号建议用 `px` 锁定上限，避免大屏字被等比放大。

### 2.3 单位使用边界

| 场景 | 推荐单位 | 原因 |
|------|---------|------|
| 手机端布局尺寸（宽高/边距/圆角） | rpx 或 vw | 随屏宽等比 |
| 大屏布局 | % / flex / grid + max-width | 防止无限放大 |
| 字号 | px（配合媒体查询）或 rpx + 上限 | 大屏可读性 |
| 1px 发丝线、阴影偏移 | px | rpx 在窄屏可能小于 0.5px 消失 |
| 内容容器最大宽度 | px | 防拉伸 |

### 2.4 设计稿基准（官方两种）

| 基准 | 布局规则 | 换算 |
|------|---------|------|
| **375px** | 固定布局，不同机型放大缩小 | 1px = 2rpx |
| **390px** | 响应式布局，不同尺寸需适配调整 | 按 750rpx 规则换算 |

### 2.5 rpx ↔ px

```js
// canvas / SelectorQuery / 动画接口只认 px
const rpx2px = rpx => rpx / 750 * wx.getWindowInfo().windowWidth
const px2rpx = px => px / wx.getWindowInfo().windowWidth * 750
```

---

## 三、旋转适配

### 3.1 配置

```json
// app.json
{
  "resizable": true,            // iPad/PC 支持改变窗口大小；iPad 不可单页配置
  "window": { "pageOrientation": "auto" }  // auto 2.4.0+ / landscape 2.5.0+
}
```

- `pageOrientation`：`portrait`（默认）/ `auto` / `landscape`。可页面级覆盖。
- `resizable`：PC 任意拖拽窗口（含最大化）；iPad 支持屏幕旋转；大屏模式（2.21.3+）。**默认关闭**。

### 3.2 监听

```js
// 页面
Page({
  onResize(res) {
    const { windowWidth, windowHeight } = res.size
    this.setData({ isLandscape: windowWidth > windowHeight })
  }
})

// 组件
Component({
  pageLifetimes: {
    resize(res) { /* res.size.windowWidth / windowHeight */ }
  }
})
```

> `wx.onWindowResize` 可监听，但官方标注**不推荐**。

### 3.3 旋转后必须重算的项

- `statusBarHeight`、`safeArea`（横屏安全区左右变化）
- 自定义导航栏高度与胶囊位置（iPad 横屏/分屏下胶囊 rect 可能是估算值）
- 吸底栏 padding-bottom
- 依赖 windowWidth 的 canvas 尺寸与动画坐标

---

## 四、响应式三件套

### 4.1 CSS 媒体查询（样式层）

```css
.my-class { width: 40px; }

@media (min-width: 480px) {
  .my-class { width: 200px; }
}

@media (prefers-color-scheme: dark) {
  /* 暗色样式，见 theme-accessibility.md */
}
```

### 4.2 match-media 组件（结构层）

```xml
<match-media min-width="768" max-width="1024">
  <view class="tablet-layout">...</view>
</match-media>
```

### 4.3 MediaQueryObserver（逻辑层）

```js
Page({
  onReady() {
    this.mq = this.createMediaQueryObserver()
    this.mq.observe({ minWidth: 768 }, matches => {
      this.setData({ isWide: matches })
    })
  },
  onUnload() {
    this.mq && this.mq.disconnect()
  }
})
```

官方说明其优势：显式、可数据绑定、可嵌套、组件化、Webview 全兼容。

### 4.4 断点建议（经验值，官方未规定固定断点）

| 断点 | 典型设备 / 场景 |
|------|----------------|
| < 480px | 小屏手机、分屏/浮窗 |
| ≥ 480px | 大屏手机、折叠屏折叠态 |
| ≥ 768px | iPad 竖屏、折叠屏展开 |
| ≥ 1024px | iPad 横屏、PC 宽窗口 |
| ≥ 1200px | PC 大窗口（建议内容区封顶后居中） |

---

## 五、大屏适配（官方 design/adapt）

### 5.1 未适配时的默认表现

| 形态 | 默认尺寸 |
|------|---------|
| 竖屏小程序 | 固定 414 × 736（手机尺寸） |
| 横屏小程序 | 固定 768 × 1024（平板尺寸） |
| 竖屏小游戏 | 基准 1072 × 768，按 320 × 568 等比缩放 |
| 横屏小游戏 | 基准 1072 × 768，按 736 × 414 等比缩放 |

> 关键含义：不做适配时 PC 窗口**不能拖动尺寸**，页面被锁在 414 宽。要获得可拖拽/最大化能力，必须配 `resizable: true`。

### 5.2 两条基本适配原则

1. **信息完整可读**：尺寸切换后不出现形变、缺失、分辨率下降。
2. **切换流畅友好**：变大后展示更多信息，切换过程不跳变。

### 5.3 七种动态布局模式（官方）

| # | 模式 | 特点 | 适配规则 | 典型页面 |
|---|------|------|---------|---------|
| 1 | 左右伸缩 | 元素水平拉伸 | 高度固定、宽度随容器变 | 列表、表格 |
| 2 | 换行排列 | 按宽度决定横排/竖排 | 容得下横排，容不下竖排 | 内容详情页 |
| 3 | 横向拓展 | 横向增加更多元素 | 元素尺寸或间距其一定值 | 电商 |
| 4 | 分页展现 | 同属性组件横向并列 | 定义单组件宽，自动算可容纳个数 | 歌单、应用列表 |
| 5 | 分层展现 | 分多栏，有主从关系 | 设每栏最小宽度，算可呈现栏数 | 工具类（左母菜单/中子菜单/右详情） |
| 6 | 自由布局 | 主模块固定，从属围绕 | 定主模块最大值与位置，从属自动算 | 内容详情页 |
| 7 | 侧边栏 | 导航在主模块，大屏转侧栏 | 设断点，超断点主导航变侧边栏 | 有主从关系的页面 |

### 5.4 大屏其他要点（官方）

1. **Navigation Bar 与 Tab Bar 高度适配后保持不变**（不随窗口放大）。
2. **弹窗**：避免形变，可采用鼠标指针跟随呈现。
3. **悬浮工具栏**：窗口变动可能移出可视区，与特定区域相关的工具栏要用更稳定的形式。
4. **页面刷新**：PC 端下拉刷新不友好，需要刷新能力时提供明确按钮等稳定形式。

### 5.5 栅格与分栏

- `row/col` 组件：**整行最多 24 份**，超出自动换行；各尺寸设置互不影响。
- 分栏模式（frameset）：PC 等大屏可把微信窗口分左右两半，各展示一个页面。

---

## 六、落地模板

```css
/* 页面根容器：手机满宽，大屏封顶居中 */
.page-root {
  width: 100%;
  max-width: 750px;
  margin: 0 auto;
  box-sizing: border-box;
}

/* 大屏：单列转多列 */
@media (min-width: 768px) {
  .list { display: flex; flex-wrap: wrap; }
  .list-item { width: 50%; }
  .grid-item { width: 33.33%; }
}

/* 大屏：主从结构转侧边栏 */
@media (min-width: 1024px) {
  .layout { display: flex; }
  .sidebar { width: 240px; flex-shrink: 0; }
  .content { flex: 1; min-width: 0; }
}

/* 字号封顶，避免大屏字过大 */
@media (min-width: 768px) {
  .body-text { font-size: 16px; }
}
```

```json
// app.json 最小大屏配置
{
  "resizable": true,
  "window": { "pageOrientation": "auto" }
}
```

---

## 七、常见错误

| 错误 | 后果 | 修正 |
|------|------|------|
| 全站只用 rpx，无 max-width | iPad/PC 元素被放大到失真 | 根容器加 max-width + 断点 |
| 固定 px 宽容器 | 大屏左侧一坨、右侧大片空白 | 百分比/flex 自适应 |
| 字号用 vw 无上限 | 大屏正文过大不可读 | 字号 px 锁定或设上限 |
| 横向溢出 | PC 出现横向滚动条 | 检查宽高计算、`box-sizing` |
| 只做手机端断点 | PC 拖拽时布局错乱 | 补 768/1024 断点 |
| 旋转后不重算 | 导航/安全区错位 | `onResize` 重算 |
