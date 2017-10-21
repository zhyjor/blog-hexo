---
title: 使用WebView的姿势大全
date: 2017-10-20 14:19:17
tags:
  - webview
  - 混合开发
  - android
 
categories: android
copyright: true
---
### api
#### webview中loadDataWithBaseURL()与loadData()的差别

**1、参数差别**
```
this.web.loadData(html, "text/html", "utf-8");
this.web.loadDataWithBaseURL("about:blank", html, "text/html", "utf-8", null);
```
**2、loadData需要先转码**
loadData不支持#、%、\、? 四种字符。但也不是完全不支持，表现很怪异。

最好的办法，是用以下方法转码：
```
final String digits = "0123456789ABCDEF";     
public String encode(String s){  
  // Guess a bit bigger for encoded form   
  StringBuilder buf = new StringBuilder(s.length() + 16);  
  for (int i = 0; i < s.length(); i++) {  
      char ch = s.charAt(i);  
      if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')  
              || (ch >= '0' && ch <= '9') || ".-*_".indexOf(ch) > -1) { //$NON-NLS-1$   
          buf.append(ch);  
      } else {  
          byte[] bytes = new String(new char[] { ch }).getBytes();  
          for (int j = 0; j < bytes.length; j++) {  
              buf.append('%');  
              buf.append(digits.charAt((bytes[j] & 0xf0) >> 4));  
              buf.append(digits.charAt(bytes[j] & 0xf));  
          }  
      }  
  }  
  return buf.toString();   
}

即：

this.web.loadData(this.encode(html), "text/html", "utf-8");
```

### android在WebView中加载url，防止调用系统浏览器加载

android在WebView中加载url，防止调用系统浏览器加载
只要重写webView的WebViewClient
具体代码如下：
```
web_adSentence.setWebViewClient(new WebViewClient() {  
            //覆盖shouldOverrideUrlLoading 方法  
            @Override  
            public boolean shouldOverrideUrlLoading(WebView view, String url) {  
                view.loadUrl(url);  
                return true;  
            }  
        });  
```
只进行上述操作就可以让url在当前应用的webView中加载，不再调用系统浏览器
但是还建议对WebView进行设置，添加JavaScript等支持
具体代码如下：

```
webView.getSettings().setJavaScriptEnabled(true);  
        webView.getSettings().setAppCacheEnabled(true);  
        //设置 缓存模式  
        webView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);  
        // 开启 DOM storage API 功能  
        webView.getSettings().setDomStorageEnabled(true);  

```
