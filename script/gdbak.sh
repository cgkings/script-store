#!/bin/bash
check_doing() {
  if [[ "$?" -eq "0" ]]; then
    cat >> /root/install_log.txt << EOF
$(date '+%Y-%m-%d %H:%M:%S') [INFO] 备份到 ${doing_name} ==> Upload done ✔
--------------------------------------------------------------------------------------------------------------
EOF
    sleep 5s
  else
    cat >> /root/install_log.txt << EOF
--------------------------------------------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 备份到 ${doing_name} ==> Upload failed ❌
--------------------------------------------------------------------------------------------------------------
EOF
  fi
}

whiptail --clear --ok-button "选择完毕自动开始备份" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "网盘同步模式" --checklist --separate-output --nocancel "请按空格及方向键来选择需要同步的任务，ESC退出脚本" 19 64 11 \
        "gd to gd task 1" "  : personal to personal 1" on \
        "gd to gd task 2" "  : personal 1 to personal bak" on \
        "gd to odcn task 1" "  : personal to odcn影视" on \
        "gd to odcn task 2" "  : personal to odcn动漫" on \
        "gd to odcn task 3" "  : personal to odcn综艺" on \
        "gd to odcn task 4" "  : personal to odcn剧集" on \
        "gd to ode5 task 1" "  : personal to ode5影视" on \
        "gd to ode5 task 2" "  : personal to ode5动漫" on \
        "gd to ode5 task 3" "  : personal to ode5综艺" on \
        "gd to ode5 task 4" "  : personal to ode5剧集" on \
        "gd to ode5 task 5" "  : personal to ode5jav" on 2> results
      while read -r choice; do
        case $choice in
          "gd to gd task 1")
            doing_name="personal 1"
            echo -e "开始 gd to gd task 1 : personal to personal 1" | tee -a /root/install_log.txt
            fclone sync gd-frreq:{0AOoUhVD6ULIfUk9PVA} gd-frreq:{0AM2AXmxuonynUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=256 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
            check_doing
            ;;
          "gd to gd task 2")
            doing_name="personal bak"
            echo -e "开始 gd to gd task 2 : personal 1 to personal bak" | tee -a /root/install_log.txt
            fclone sync gd-frreq:{0AM2AXmxuonynUk9PVA} gd-frreq:{0AL1vRw5scrxmUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
            check_doing
            ;;
          "gd to odcn task 1")
            doing_name="odcn-film:/影视"
            echo -e "开始 gd to odcn task 1 : personal to odcn影视" | tee -a /root/install_log.txt
            rclone sync gd-frreq:"1 影视" odcn-film:/影视 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G
            check_doing
            ;;
          "gd to odcn task 2")
            doing_name="odcn-film:/动漫"
            echo -e "开始 gd to odcn task 2 : personal to odcn动漫" | tee -a /root/install_log.txt
            rclone sync gd-frreq:"3 动漫" odcn-film:/动漫 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G
            check_doing
            ;;
          "gd to odcn task 3")
            doing_name="odcn-film:/综艺"
            echo -e "开始 gd to odcn task 3 : personal to odcn综艺" | tee -a /root/install_log.txt
            rclone sync gd-frreq:"4 综艺" odcn-film:/综艺 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G
            check_doing
            ;;
          "gd to odcn task 4")
            doing_name="odcn-tv:/剧集"
            echo -e "开始 gd to odcn task 4 : personal to odcn剧集" | tee -a /root/install_log.txt
            rclone sync gd-cgking:"/2 剧集" odcn-tv:/剧集 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G
            check_doing
            ;;
          "gd to ode5 task 1")
            doing_name="ode5-film:/影视"
            echo -e "开始 gd to ode5 task 1 : personal to ode5影视" | tee -a /root/install_log.txt
            fclone sync gd-frreq:"/1 影视" ode5-film:/影视 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --check-first
            check_doing
            ;;
          "gd to ode5 task 2")
            doing_name="ode5-film:/动漫"
            echo -e "开始 gd to ode5 task 2 : personal to ode5动漫" | tee -a /root/install_log.txt
            fclone sync gd-frreq:"3 动漫" ode5-film:/动漫 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --check-first
            check_doing
            ;;
          "gd to ode5 task 3")
            doing_name="ode5-film:/综艺"
            echo -e "开始 gd to ode5 task 3 : personal to ode5综艺" | tee -a /root/install_log.txt
            fclone sync gd-frreq:"4 综艺" ode5-film:/综艺 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --check-first
            check_doing
            ;;
          "gd to ode5 task 4")
            doing_name="ode5-tv:/剧集"
            echo -e "开始 gd to ode5 task 4 : personal to ode5剧集" | tee -a /root/install_log.txt
            fclone sync gd-frreq:"/2 剧集" ode5-tv:/剧集 --drive-root-folder-id "0AM2AXmxuonynUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --check-first
            check_doing
            ;;
          "gd to ode5 task 5")
            doing_name="ode5-jav"
            echo -e "开始 gd to ode5 task 5 : personal to ode5-jav" | tee -a /root/install_log.txt
            fclone sync gd-frreq:{1qitlvImjpef9NMQ1vV8Z2Qf0vLQc-3jL} ode5-jav: --fast-list --drive-use-trash=false --stats=5s --stats-one-line -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --check-first
            check_doing
            ;;
          *)
            exit
            ;;
  esac
done       < results
      rm results
exit
