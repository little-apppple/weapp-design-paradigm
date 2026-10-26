# 主题、适老化与无障碍（统一文档）

> 本文整合官方三份文档：DarkMode 适配指南、小程序适老化设计指南、小程序无障碍设计指南，并参考《信息技术 小程序应用无障碍技术要求》（国标草案）。

---

## 一、DarkMode（暗色模式）

### 1.1 开启

```json
// app.json
{
  "darkmode": true,
  "themeLocation": "theme.json"
}
```

- 微信支持起点：iOS 7.0.12 / Android 7.0.13；基础库 **2.11.0+**；开发者工具 1.03.2004271+。
- 开启后所有基础组件按系统主题展示默认样式，navigation bar 与 tab bar 按配置自动切换。

### 1.2 theme.json 变量

```json
{
  "light": {
    "navBgColor": "#f6f6f6",
    "navTxtStyle": "black",
    "bgColor": "#ffffff",
    "bgTxtStyle": "light"
  },
  "dark": {
    "navBgColor": "#191919",
    "navTxtStyle": "white",
    "bgColor": "#1f1f1f",
    "bgTxtStyle": "dark"
  }
}
```

引用方式：配置值以 `@` 开头。

```json
{
  "window": {
    "navigationBarBackgroundColor": "@navBgColor",
    "navigationBarTextStyle": "@navTxtStyle",
    "backgroundColor": "@bgColor",
    "backgroundTextStyle": "@bgTxtStyle"
  }
}
```

### 1.3 支持变量配置的属性（官方清单）

- 全局 `window` 与页面配置：
  - `navigationBarBackgroundColor`
  - `navigationBarTextStyle`
  - `backgroundColor`
  - `backgroundTextStyle`
  - `backgroundColorTop`
  - `backgroundColorBottom`
- `tabBar`：
  - `color` / `selectedColor` / `backgroundColor` / `borderStyle`
  - `list[].iconPath` / `list[].selectedIconPath`

### 1.4 WXSS 暗色样式

```css
.card { background: #ffffff; color: #1a1a1a; }

@media (prefers-color-scheme: dark) {
  .card { background: #1b1b1b; color: #ffffff; }
}
```

### 1.5 获取与监听主题

```js
const { theme } = wx.getAppBaseInfo()  // 'light' | 'dark'（需 darkmode: true）

App({
  onThemeChange({ theme }) { /* 主题切换 */ }
})

wx.onThemeChange(({ theme }) => {})
wx.offThemeChange(fn)
```

### 1.6 注意事项（官方 Bug & Tip）

1. **WXSS 的 `prefers-color-scheme` 不受 `darkmode` 开关影响**：只要客户端支持，系统切暗色时媒体查询就生效。
2. **主题切换事件只有在 `darkmode: true` 时才会触发**。
3. iOS 7.0.12 在 light 模式下把 tabBar `borderStyle` 设为 `white` 可能出现黑底 bug。

---

## 二、适老化（微信字体大小适配）

### 2.1 为什么要做

建议开发者**根据用户微信字体大小设置**对小程序进行适配，让老年用户平等便捷地使用。

### 2.2 字体参数（官方推荐 getAppBaseInfo）

```js
const { fontSizeSetting, fontSizeScaleFactor } = wx.getAppBaseInfo()
```

- `fontSizeSetting`：用户字体大小（px）
- `fontSizeScaleFactor`：字体缩放倍率

> 官方明确：`wx.getSystemInfo` 后续不再维护，推荐 `wx.getAppBaseInfo`。

### 2.3 档位规则

**iOS**：7 档（1 缩小 + 标准 + 5 放大）
- 标准字体 17px；`fontSizeScaleFactor = fontSizeSetting / 17`
- 「关怀模式」字号约 23.8px

**Android**：8 档（1 缩小 + 标准 + 6 放大）
- 标准字体 16px；`fontSizeSetting = 16 × fontSizeScaleFactor` 取整
- 「关怀模式」倍率 ×1.4

Android 档位倍率：`-1 ×1 / 标准 ×1 / +1 ×1 / +2 ×1.12 / +3 ×1.125 / +4 ×1.4 / +5 ×1.55 / +6 ×1.65`

### 2.4 适老化界面基础规则（官方 5 条）

1. 元素跟随文字「档位倍率」放大而放大。
2. 元素与元素、容器与容器之间的**相对间距始终保持固定**。
3. 因达极值折行时，元素/容器**默认居左对齐**。
4. 文字折行时**遵循原对齐方式**（居左/居中/居右）。
5. 文字信息尽量**完整展示**。

### 2.5 字体与对比度

- 适老化模式下：字体、图形元素、按钮**等比放大 1.4 倍**；元素间距与导航栏尺寸**保持固定**。
- 对比度：文本/文本图像、图标等至少 **4.5:1**；字号 > 18dp/pt 时至少 **3:1**。适老化下可进一步强化对比度。

### 2.6 热区规则（官方）

1. 图标、图标+文字链接、图片周围加 **12pt 反馈热区**。
2. 图标与文字指向同一结果时，用**完整连续热区**。
3. 尺寸 ≥ 44pt 且边界清晰的元素**不必**额外加热区（大按钮、大头像）。
4. 交互元素在容器内时，最大热区不超过容器本身；整个容器指向同一结果时，按压区即容器。
5. 元素间视觉距离至少 2A；热区应平分间距。
6. 特殊小元素可将热区拓展出容器，保证**最少 40 × 40pt** 热区。

### 2.7 基础组件适配规则（官方）

| 组件 | 规则 |
|------|------|
| 导航栏 | 标准档位内不缩放；大于标准档位缩放 **1.18 倍**，热区需扩展。原生已适配，**自定义导航栏需自行适配** |
| 底部标签栏 | 按功能数均分屏宽，图标与文案居中并按倍率缩放。原生已适配，**自定义 tabBar 需自行适配** |
| 顶部标签栏 | 文案与下划线等比缩放，标签间距固定 |
| 搜索栏 | 文字、图形元素等比放大，间距不变，搜索框外边距固定 |
| 功能模块 | 模块左右边距固定，元素按全局倍率缩放，缩放后保证信息完整 |

### 2.8 工具

官方适老化自动适配工具：`https://github.com/wechat-miniprogram/miniprogram-elder-transform`
> 官方声明：工具不能覆盖所有场景，转换后仍需测试并手动适配。

---

## 三、无障碍（Accessibility）

### 3.1 为什么做

帮助残障人士平等便捷地获取、使用互联网应用信息，建议结合用户群体与场景做无障碍适配。

### 3.2 官方实现方式

- 微信绘制的接口组件（如 `wx.showModal`、`navigation-bar`）**已内置无障碍特性**。
- 非原生界面内容：使用 **aria-component** 添加无障碍标签。

### 3.3 aria 属性速查

| 属性 | 作用 |
|------|------|
| `aria-role` | 声明组件角色（button、link、image 等） |
| `aria-label` | 提供给读屏的替代文本 |
| `aria-hidden` | 是否对辅助技术隐藏 |
| `aria-checked` / `aria-disabled` | 状态类信息 |

```xml
<view aria-role="button" aria-label="返回上一页" bind:tap="onBack">
  <image src="/assets/back.png" aria-hidden="true" />
</view>

<image src="/assets/banner.png" aria-role="img" aria-label="活动海报：新春满减" />
```

### 3.4 国标硬指标（《信息技术 小程序应用无障碍技术要求》草案）

| 项 | 要求 |
|----|------|
| 字体可调 | 支持随系统调整或内部设置，放大可达 **200%** 且内容/功能无损失 |
| 主要文字最大字号 | 不小于 **30 dp/pt** |
| 文本对比度 | 至少 **4.5:1**；大字（>18dp/pt）至少 **3:1** |
| 行高 | 至少 **1.5 倍**字号 |
| 段落间距 | 至少 **2 倍**字号 |
| 控件可读 | 屏幕阅读器可获取角色、状态、值、标题 |
| 图像控件 | 必须提供替代文本 |
| 输入框提示 | 提示可被读屏获取且具有对比度 |
| 背景音 | 提供关闭/暂停能力 |

### 3.5 落地清单

- [ ] 所有可点击元素有 `aria-role` + `aria-label`（图标按钮必须有）
- [ ] 装饰性图片 `aria-hidden="true"`，信息性图片有替代文本
- [ ] 字号支持系统缩放（不写死 `!important` 固定 px 到不可变）
- [ ] 正文对比度 ≥ 4.5:1，大字 ≥ 3:1
- [ ] 行高 ≥ 1.5 倍，段落间距 ≥ 2 倍
- [ ] 自定义导航栏/tabBar 已按 1.18 / 1.4 倍率适配
- [ ] 小元素热区 ≥ 40×40pt

---

## 四、主题与可访问性联动

- 暗色下对比度仍需满足 4.5:1，不能只做"颜色反转"。
- 适老化 + 暗色同时生效时，优先保证对比度与信息完整。
- 语义色（成功/警告/错误）不能只靠颜色区分，需配合图标或文字。
