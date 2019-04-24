---
title: react深入理解之三：react的生命周期
tags:
  - react深入理解
  - react
categories: react
top: false
copyright: true
date: 2018-10-16 17:15:08
---
react中的生命周期
<!--more-->
* getDefaultProps
* getInitialState
* componentWillMount（页面初始化的时候）
* render(必须要有)
* componentDidMount
* componentWillReceiveProps
* shouldComponentUpdate（this.setState）
* componentWillUpdate
* componentDidUpdate
* componentWillUnmount

可以使用下述代码测试生命周期
```
import React from 'react'

export default class Child extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            count: 0
        }
    }

    componentWillMount() {
        console.log('will mount')
    }

    componentDidMount() {
        console.log('did mount')
    }

    componentWillReceiveProps(newProps) {
        console.log('will props:' + newProps.count)
    }

    shouldComponentUpdate() {
        console.log('should update')
        return true
    }

    componentWillUpdate() {
        console.log('will update')
    }

    componentDidUpdate() {
        console.log('did update')
    }



    render() {
        return (
            <div>
                <p>这里是子组件</p>
                <p>{this.props.count}</p>
            </div>
        )
    }
}
```

**参考资料**
[]()

![](http://static.zhyjor.com/wexin.png)
