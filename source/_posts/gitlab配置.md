---
title: gitlab配置
tags:
  - gitlab
categories: gitlab
top: false
copyright: true
date: 2020-10-21 10:24:30
---
Repository mirroring allows for mirroring of repositories to and from external sources.
<!--more-->

**参考资料**

* 同步时间问题


[**Repository mirroring**](https://docs.gitlab.com/ee/user/project/repository/repository_mirroring.html)
[Improve CI for external repo with configurable maximum mirroring frequency](https://gitlab.com/gitlab-org/gitlab/-/issues/237891)
[Repository pull mirror scheduling design](https://gitlab.com/gitlab-org/gitlab/-/issues/12758)
[Reduce rate of RepositoryUpdateMirrorWorker jobs](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/78#note_262385767)
[Application limits for pull mirror API](https://gitlab.com/gitlab-org/gitlab/-/issues/118753)
[MIN_DELAY = 30.minutes](https://gitlab.com/gitlab-org/gitlab/blob/master/ee/lib/gitlab/mirror.rb)
[Dynamically determine mirror update interval based on total number of mirrors, average update time, and available concurrency](https://gitlab.com/gitlab-org/gitlab/-/issues/5258)
[GitLab application limits](https://docs.gitlab.com/ee/administration/instance_limits.html#number-of-webhooks)

* 其他

[Building Docker images with GitLab CI/CD](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)

[GitLab Runner安装注册配置管理](https://cloud.tencent.com/developer/article/1624837)
[如何做Git项目的持续集成](https://cloud.tencent.com/developer/article/1530690)
[(17年的文章，有点旧，但是技术细节还不错)当谈到 GitLab CI 的时候，我们该聊些什么（上篇）](https://www.upyun.com/tech/article/245/%E5%BD%93%E8%B0%88%E5%88%B0%20GitLab%20CI%20%E7%9A%84%E6%97%B6%E5%80%99%EF%BC%8C%E6%88%91%E4%BB%AC%E8%AF%A5%E8%81%8A%E4%BA%9B%E4%BB%80%E4%B9%88%EF%BC%88%E4%B8%8A%E7%AF%87%EF%BC%89.html)
[当谈到 GitLab CI 的时候，我们都该聊些什么（下篇）](https://www.upyun.com/tech/article/246/%E5%BD%93%E8%B0%88%E5%88%B0%20GitLab%20CI%20%E7%9A%84%E6%97%B6%E5%80%99%EF%BC%8C%E6%88%91%E4%BB%AC%E9%83%BD%E8%AF%A5%E8%81%8A%E4%BA%9B%E4%BB%80%E4%B9%88%EF%BC%88%E4%B8%8B%E7%AF%87%EF%BC%89.html )
[基于镜像部署的Gitlab-CI/CD实践和坑位指南](https://www.jqhtml.com/50142.html)
[docker运行gitlab runner且指定shell executor](https://www.cnblogs.com/jimaojin/p/12611584.html) 
[gitlab-runner docs configuration advanced-configuration](https://gitlab.com/gitlab-org/gitlab-runner/-/blob/master/docs/configuration/advanced-configuration.md)
[Executors](https://docs.gitlab.com/runner/executors/)
[Docker 从容器中拷贝文件到宿主机中](https://blog.csdn.net/libertine1993/article/details/80651552)
[Docker容器访问宿主机网络](https://jingsam.github.io/2018/10/16/host-in-docker.html)
[解决unable to locate package net-tools](https://blog.csdn.net/u010502101/article/details/89067757)
[修改gitlab默认端口](https://blog.csdn.net/q_Catherine/article/details/90741613)
[GitLab导致8080端口冲突](https://zj-git-guide.readthedocs.io/zh_CN/latest/platform/GitLab%E5%AF%BC%E8%87%B48080%E7%AB%AF%E5%8F%A3%E5%86%B2%E7%AA%81/)
[linux安装gitlab并修改gitlab默认端口号](https://blog.csdn.net/wangyy130/article/details/85633303)
[docker从入门到实践](https://yeasy.gitbook.io/docker_practice/container/attach_exec)
[gitlab-ee 企业版自签许可证license](https://blog.mayershi.me/2019/12/23/crack-gitlab-ee-licence/index.html)
[生成 GitLab EE 许可证](https://blog.starudream.cn/2020/01/19/6-crack-gitlab/)
[Gitlab 中文文档](https://www.bookstack.cn/read/gitlab-doc-zh/docs-226.md)
[Mirror确实可以工作，但是速度很慢](https://www.coder.work/article/6562560)
[External CI/CD configuration in Starter and Bronze](https://about.gitlab.com/releases/2018/03/22/gitlab-10-6-released/#gitlab-cicd-for-external-repos)
[配置 GitLab Runners](https://www.jianshu.com/p/825dad1266cf)
[gitlab-ci-multi-runner和GitLab Runner区别](https://bbs.aqzt.com/thread-621-1-1.html)
[GitLab-CI与GitLab-Runner](https://www.jianshu.com/p/2b43151fb92e)
[在容器中运行GitLab Runner](https://docs.gitlab.com/runner/install/docker.html)
[Docker安装Gitlab、Gitlab-Runner并实现项目CICD](https://juejin.im/post/6844904152955355149)
[Repository mirroring](https://forge.etsi.org/rep/help/workflow/repository_mirroring.md)

[GitLab CI流水线配置文件.gitlab-ci.yml详解](https://meigit.readthedocs.io/en/latest/gitlab_ci_.gitlab-ci.yml_detail.html)

* issue

[reset_token_url: reset_registration_token_admin_application_settings_path](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/57038)
[Internal Server Error 500 while accessing $GITLAB/admin/runners](https://stackoverflow.com/questions/54216933/internal-server-error-500-while-accessing-gitlab-admin-runners)

[](https://blog.csdn.net/ouyang_peng/article/details/84066417)

![](http://static.zhyjor.com/wexin.png)