# picture_r
picture_r是一个在终端运行的画板，使用shell脚本编写，支持256色调色板，支持新建、保存、重新打开。

保存文件格式是原始的终端ASCII色彩编码，可以直接使用echo -e来打开查看：

echo -e \`cat xxx.save\`"\e[0m"

https://github.com/callcz/picture_r/blob/main/%E6%88%AA%E5%9B%BE_%E9%80%89%E6%8B%A9%E5%8C%BA%E5%9F%9F_20230106134646.png?raw=true

已知待修正：

调色板方向键选色逻辑

计划添加功能：

1.调色板宽高超过终端尺寸的处理

2.添加控制画板大小参数
