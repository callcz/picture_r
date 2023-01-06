# picture_r
picture_r是一个在终端运行的画板，使用shell脚本编写，支持256色调色板，支持新建、保存、重新打开。

保存文件格式是原始的终端ASCII色彩编码，可以直接使用echo -e来打开查看：

echo -e \`cat xxx.save\`" \e[0m"
