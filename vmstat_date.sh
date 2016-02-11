vmstat $* |awk '{now=strftime("%Y-%m-%d %T  "); print now $0; fflush()}'
