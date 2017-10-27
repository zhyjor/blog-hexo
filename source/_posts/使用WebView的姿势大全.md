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
最近在整理混合开发，WebView需系统的学习下，对基本的api，性能的优化，源码方面都要进行分析
<!--more-->
#### webview中loadDataWithBaseURL()与loadData()的差别
在第一篇中，我们就已经讲了通过loadUrl()来加载本地页面和在线地址的方式，这里给大家再补充两个方法LoadData()与loadDataWithBaseURL()，它们不是用来加载整个页面文件的，而是用来加载一段代码片的。


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

####  shouldOverrideUrlLoading用途

在利用shouldOverrideUrlLoading来拦截URL时，如果return true，则会屏蔽系统默认的显示URL结果的行为，不需要处理的URL也需要调用loadUrl()来加载进WebVIew，不然就会出现白屏；如果return false，则系统默认的加载URL行为是不会被屏蔽的，所以一般建议大家return false，我们只关心我们关心的拦截内容，对于不拦截的内容，让系统自己来处理即可。

```
public boolean shouldOverrideUrlLoading(WebView view, String url) {  
   if (url.contains("blog.csdn.net")){  
        view.loadUrl("http://www.baidu.com");  
    }else {  
        view.loadUrl(url);  
    }  
   return true;  
}  


mWebView.setWebViewClient(new WebViewClient(){  
    @Override  
    public boolean shouldOverrideUrlLoading(WebView view, String url) {  
        if (url.contains("blog.csdn.net")){  
            view.loadUrl("http://www.baidu.com");  
        }  
        return false;  
    }  
}      
```

#### WebViewClient之shouldInterceptRequest
在每一次请求资源时，都会通过这个函数来回调，比如超链接、JS文件、CSS文件、图片等，也就是说浏览器中每一次请求资源时，都会回调回来，无论任何资源！但是必须注意的是shouldInterceptRequest函数是在非UI线程中执行的，在其中不能直接做UI操作，如果需要做UI操作，则需要利用Handler来实现


### 异常 
**All WebView methods must be called on the same thread. **
新版的Android的SDK要求在创建WebView所在的线程中操作它，在其它线程中操作它都会报这个错误。无论是否是loadUrl的方法的执行，还是其他的地方，只要新建线程就必须post到mianlooper里面。

**解决方式一：**

```
if (null != sessionClient) {
            Runnable callbackRunnable = new Runnable() {
                @Override
                public void run() {
                   
                }

            };
            if (Looper.getMainLooper() == Looper.myLooper()) {
                callbackRunnable.run();
            } else {
                new Handler(Looper.getMainLooper()).post(callbackRunnable);
            }
        }
```

**解决方式二：**
BroswerActivity就是webview所在的Activity。
```
BroswerActivity.this.runOnUiThread(new Runnable() {
	@Override
	public void run() {
		webview.loadUrl("http://www.lanhusoft.com");  
	}
});
```