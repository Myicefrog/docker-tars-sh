# docker-tars-sh
将脚本中的ip地址替换为部署机器地址，示例中为192.168.79.134

顺序执行：

runsql.sh--等mysql初始化完进行下一步

importTableToMyql.sh

host_run_docker_tars.sh

即可访问：http://192.168.79.134:3000

