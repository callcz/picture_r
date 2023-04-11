# picture_r
picture_r是一个在终端运行的画板，使用shell脚本编写，支持256色调色板，支持新建、保存、重新打开。

保存文件格式是原始的终端ASCII色彩编码，可以直接使用echo -e来打开查看：

echo -e \`cat picture_r_13.save\`"\e[0m"

![a smile face with rainbow](https://github.com/callcz/picture_r/raw/main/%E6%88%AA%E5%9B%BE%202023-04-11%2022-23-42.png)

运行./picture.sh启动

运行./run.sh启动可屏蔽乱七八糟的错误报告

已知待修正：

调色板方向键选色逻辑 [20230406已修正]

计划添加功能：

1.调色板宽高超过终端尺寸的处理

2.添加控制画板大小参数 [20230406已完成]
