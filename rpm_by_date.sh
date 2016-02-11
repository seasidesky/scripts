rpm -qa --queryformat '%{installtime} %{name}-%{version}-%{release}.%{arch} %{installtime:date}\n' | sort -n -k 1 | sed -e 's/^[^ ]* //' | tail -120 | column -t

