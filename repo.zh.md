---
title: use dnf with metalink
date: '2023-05-15'
category: blog
tags:
  - Sample
  - ABC
  - cccc
sig: A-Tune
archives: '2023-05'
author:
  - openEuler Blog Maintainer
summary: how can we use metalink to replace baseurl to speed up dnf downloading software package, and the configuration of each version of openEuler.
---

## HTML Elements

# 使用metalink提升dnf软件包安装速度

## 背景
目前openeuler系统中，dnf安装软件包默认使用的是baseurl方式，以openEuler-23.03的OS软件仓为例，配置如下：
```
[OS]
name=OS
baseurl=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/RPM-GPG-KEY-openEuler
```

baseurl方式是直接指定下载软件包访问的站点，repo.openeuler.org站点服务器在香港。使用baseurl有许多缺点：
- 单点故障——出现故障后影响所有软件包的安装
- 带宽受限——一个站点的出口带宽无法满足大量用户同时安装软件包
- 网络问题——国内或者欧美等地域，访问香港站点速度缓慢

为解决以上问题，推荐使用metalink替换baseurl。

## metalink原理简介
还是以openEuler-23.03的OS软件仓为例，修改为metalink方式如下：
```
[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/RPM-GPG-KEY-openEuler
```

dnf客户端访问metalink链接地址，metalink服务器会根据主机ip地址、镜像站点出口带宽、运营商等参数进行运算，从所有镜像站中选择主机访问最快的若干镜像站，按照优先级排序，然后将该镜像站列表返回给dnf客户端，dnf将该列表文件缓存到本地。之后dnf根据特定的算法从站点列表下载软件包。

**注：openEuler总共有27个镜像站点，遍布亚洲、欧洲各地，具体可通过以下地址查阅**
https://www.openeuler.org/en/mirror/list/

## metalink vs baseurl
为了验证metalink的实际效果，与baseurl在安装软件包速度方面作一个简单的对比测试。

测试步骤：
1. 以docker容器方式运行系统openEuler-23.03并进入容器
2. 执行dnf install golang命令安装golang软件包及依赖（共242MB）
3. 记录从输入确认信息到所有包下载完成的时间

不同地域的主机重复以上步骤，分别以metalink和baseurl方式执行三次，结果如下：
<table>
    <tr>
        <td>主机IP</td>
        <td>主机所在地</td>
        <td>主机带宽</td>
        <td>安装方式</td>
        <td>第一次</td>
        <td>第二次</td>
        <td>第三次</td>
    </tr>
    <tr>
        <td rowspan="2">123.60.110.6</td>
        <td rowspan="2">上海</td>
        <td rowspan="2">100Mb</td>
        <td>baseurl</td>
        <td>12m14s</td>
        <td>10m22s</td>
        <td>13m11s</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>20s</td>
        <td>25s</td>
        <td>25s</td>
    </tr>
    <tr>
        <td rowspan="2">139.9.250.51</td>
        <td rowspan="2">贵阳</td>
        <td rowspan="2">100Mb</td>
        <td>baseurl</td>
        <td>9m33s</td>
        <td>10m29s</td>
        <td>10m11s</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>20s</td>
        <td>20s</td>
        <td>20s</td>
    </tr>
    <tr>
        <td rowspan="2">139.159.199.31</td>
        <td rowspan="2">深圳</td>
        <td rowspan="2">100Mb</td>
        <td>baseurl</td>
        <td>2m40s</td>
        <td>2m26s</td>
        <td>2m20s</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>2m14s</td>
        <td>3m12s</td>
        <td>2m23s</td>
    </tr>
    <tr>
        <td rowspan="2">101.44.36.113</td>
        <td rowspan="2">土耳其</td>
        <td rowspan="2">100Mb</td>
        <td>baseurl</td>
        <td>35s</td>
        <td>34s</td>
        <td>35s</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>35s</td>
        <td>25s</td>
        <td>33s</td>
    </tr>
    <tr>
        <td rowspan="2">13.39.48.16</td>
        <td rowspan="2">巴黎</td>
        <td rowspan="2">无限制</td>
        <td>baseurl</td>
        <td>60m+</td>
        <td>60m+</td>
        <td>60m+</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>58s</td>
        <td>52s</td>
        <td>56s</td>
    </tr>
    <tr>
        <td rowspan="2">18.197.160.221</td>
        <td rowspan="2">德国</td>
        <td rowspan="2">无限制</td>
        <td>baseurl</td>
        <td>60m+</td>
        <td>60m+</td>
        <td>60m+</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>45s</td>
        <td>48s</td>
        <td>49s</td>
    </tr>
    <tr>
        <td rowspan="2">44.205.20.228</td>
        <td rowspan="2">美国</td>
        <td rowspan="2">无限制</td>
        <td>baseurl</td>
        <td>60m+</td>
        <td>60m+</td>
        <td>60m+</td>
    </tr>
    <tr>
        <td>metalink</td>
        <td>24s</td>
        <td>18s</td>
        <td>22s</td>
    </tr> 
</table>

**注：12m14s代表12分14秒，60m+代表耗时超过60分钟，未具体记录。**

由统计数据可见，metalink在任何情况下均不逊色于baseurl，在国内以及欧洲表现突出，下载速度有质的提高。


## 各版本openEuler.repo配置
现列出openEuler系统各版本的metalink配置，用户可按需修改，文件路径/etc/yum.repos.d/openEuler.repo。

**注：openEuler-20.09、openEuler-21.03、openEuler-21.03以及openEuler-20.03-LTS已停止维护。**

### openEuler-23.03
```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-23.03/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-23.03/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-23.03/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-23.03/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-23.03/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-23.03/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-23.03/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/OS/$basearch/RPM-GPG-KEY-openEuler

[update-source]
name=update-source
#baseurl=http://repo.openeuler.org/openEuler-23.03/update/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-23.03/update/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-23.03/source/RPM-GPG-KEY-openEuler
```

### openEuler-22.09 

```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-22.09/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.09/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-22.09/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.09/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-22.09/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.09/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-22.09/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.09/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-22.09/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-22.09/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-22.09/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.09/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.09/OS/$basearch/RPM-GPG-KEY-openEuler
```
### openEuler-22.03-LTS-SP1
```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS-SP1/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS-SP1/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS-SP1/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS-SP1/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-22.03-LTS-SP1/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS-SP1/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler

[update-source]
name=update-source
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/update/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-22.03-LTS-SP1/update/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS-SP1/source/RPM-GPG-KEY-openEuler
```
### openEuler-22.03-LTS
```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-22.03-LTS/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-22.03-LTS/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-22.03-LTS/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/OS/$basearch/RPM-GPG-KEY-openEuler
```
### openEuler-20.03-LTS-SP3
```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/OS/$basearch/RPM-GPG-KEY-openEuler

[EPOL-UPDATE]
name=EPOL-UPDATE
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/EPOL/update/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/EPOL/update/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-20.03-LTS-SP3/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP3/OS/$basearch/RPM-GPG-KEY-openEuler
```


### openEuler-20.03-LTS-SP2

```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP2/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP2/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/EPOL/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP2/EPOL/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/OS/$basearch/RPM-GPG-KEY-openEuler

[EPOL-UPDATE]
name=EPOL-UPDATE
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/EPOL/update/main/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP3/EPOL/update/main&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP2/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-20.03-LTS-SP2/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP2/update&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP2/OS/$basearch/RPM-GPG-KEY-openEuler
```

### openEuler-20.03-LTS-SP1

```
#generic-repos is licensed under the Mulan PSL v2.
#You can use this software according to the terms and conditions of the Mulan PSL v2.
#You may obtain a copy of Mulan PSL v2 at:
#    http://license.coscl.org.cn/MulanPSL2
#THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
#PURPOSE.
#See the Mulan PSL v2 for more details.

[OS]
name=OS
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/OS/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP1/OS&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler

[everything]
name=everything
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/everything/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP1/everything&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/everything/$basearch/RPM-GPG-KEY-openEuler

[EPOL]
name=EPOL
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/EPOL/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP1/EPOL&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler

[debuginfo]
name=debuginfo
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/debuginfo/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP1/debuginfo&arch=$basearch
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/debuginfo/$basearch/RPM-GPG-KEY-openEuler

[source]
name=source
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/source/
metalink=https://mirrors.openeuler.org/metalink?path=openeuler/openEuler-20.03-LTS-SP1/source/repodata/repomd.xml
metadata_expire=7d
enabled=1
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/source/RPM-GPG-KEY-openEuler

[update]
name=update
#baseurl=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/update/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=openEuler-20.03-LTS-SP1/update&arch=$basearch
metadata_expire=7d
enabled=0
gpgcheck=1
gpgkey=http://repo.openeuler.org/openEuler-20.03-LTS-SP1/OS/$basearch/RPM-GPG-KEY-openEuler
```
