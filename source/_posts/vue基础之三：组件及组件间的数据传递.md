---
title: vue基础之三：组件间的数据传递
tags:
  - vue
  - vue基础
top: false
categories: vue
copyright: true
date: 2017-10-23 14:01:03
---
组件的数据传递需要明确一下几个概念： 
* 每个组件是没关系的，都应该产生自己的数据。在组件中data使用的方法和默认的vm一样。只是data不再是对象而是函数。组件可以无限嵌套。
* 声明组件的名字，不能为已经存在的标签。
* 组件的嵌套，子组件必须写在父组建的模板中才能使用

<!--more-->

### 父级向子级传递数据（传递的属性值）

* 如果直接写a='b'格式传递的是字符串，动态数据获取用的是v-bind，一般无论是动态还是静态，我们都会采用:。
* :msg='meat',meat是变量;msg='meat',meat是字符串，:msg="'meat'",meat是字符串
* 子级不能直接改变父级的数据，如果要修改可以将父级的数据修改后赋值给子级的变量，可以使用data或者computed

```js
<div id=app>
    <child :data='aaa' :data1="bbb"></child>
    //此处，在子组件中左边的是子组件的接收,用props接收,如果是放在数组中每一项就是一个字符串,右边是从父级传递的数据。
</div>
<script>
    let vm=new Vue({
            el:'#app',
            data:{
            aaa:'xxxxx',
            bbb:'yyyyy'
            }
            components:{//
                child:{
                props:['data','data1']，
                template:'<div>{{msg}}</div>',
                data(){
                    return {msg:this.data+'zxvv'}
                    }，
                computed：{
                    msg:{
                        get(){
                        return  this.data+'zxvv'
                            }
                        }
                    }
                }   
            }
        })
</script>
```
props中的validate：
```js
1、props：['xx','yy','zz'];
2、props：{
    aa:{
        type:[Number,String],//选择值得类型符不符合要求
        default:'acac',//默认值
        validator(val){//校验函数
            return val>200//返回false，校验失败。
        }
        required：true，//代表属性必须填     
    }
}
```

### 子级向父级传递数据（借助于事件）

子级$emit后会触发自己身上的某一个自定的方法，这个方法对应的函数在父级的身上。
```js
<div id="app1">
    {{datas}}
    <child @get-data="getData"></child>//自定义方法写在自己身上，右边的是父级对应方法的函数
</div>
let vm1 = new Vue({
        el: '#app1',
        data: {
            datas: '',//用来接收自己传递的空数据
        },
        methods: {
            getData(msg){//接受的参数就是从子级传递过来的数据
                this.datas = msg;
            }
        },
        components: {
            child: {
                template: `<div><button @click="say">{{msg}}</button></div>`,//绑定触发事件
                methods: {
                    say(){//触发事件，以及自定义方法
                        this.$emit('get-data', this.msg);//这里的this指的是当前子组件
                    }
                },
                data(){
                    return {
                        msg: 'xxx'
                    }
                }
            }
        }

    })
```
### 兄弟之间传递数据

* 兄弟之间传递数据需要借助于类似的事件总线，通过事件车的方式传递数据eventBus
* 创建一个Vue的实例，让各个兄弟共用同一个事件机制。
* 传递数据方，通过一个事件触发bus.$emit(方法名，传递的数据)。
* 接收数据方，通过mounted(){}触发bus.$on(方法名，function(接收数据的参数){用该组件的数据接收传递过来的数据})，此时函数中的this已经发生了改变，可以使用箭头函数。

### slot
具名slot，通过组件传入模板，每个模板指定是slot名字，这个名字和定制模板匹配到，会替换定制的模板。
slot是vue中提供的一个标签，用来做模板定制的。属性，事件，定制模板组成了组件的API。
**使用slot分发内容**
为了让组件可以组合，我们需要一种防暑混合父组件的内容与子组件自己的模板。这个过程被称作内容分发（transclusion），vue.js实现了一个内容分发API，使用特殊的<slot>元素作为原始内容的插槽。
**编译作用域**
 父组件模板的内容在父组件作用域内编译；子组件模板的内容在子组件作用域内编译。
 **单个slot**
 除非子组件模板包含至少一个 <slot> 插口，否则父组件的内容将会被丢弃。当子组件模板只有一个没有属性的 slot 时，父组件整个内容片段将插入到 slot 所在的 DOM 位置，并替换掉 slot 标签本身。
 最初在 <slot> 标签中的任何内容都被视为备用内容。备用内容在子组件的作用域内编译，并且只有在宿主元素为空，且没有要插入的内容时才显示备用内容。
 **具名slot**
 <slot>元素可以用有个特殊的属性name来配置如何分发内容。多个slot可以有不同的名字。具名slot将匹配内容片段中对应slot特性的元素。但任然可以有一个匿名slot，它是默认的slot，作为找不到匹配的内容片段的备用插槽。如果没有默认的slot，这些找不到匹配的内容将被抛弃。


**参考资料**
[]()

![](http://oankigr4l.bkt.clouddn.com/wexin.png)