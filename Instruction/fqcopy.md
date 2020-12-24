# make-swapfile
Useful linux shell script - create a swapfile with a bash file

# Usage
- List memory/swap info
```sh
sena@vs:~/$ cat /proc/meminfo
...
SwapTotal:      0 kB
SwapFree:       0 kB
...
```
- Crate a swapfile with a custom size (gigabytes)
```sh
sena@vs:~/$ bash make-swapfile.sh 30
swapoff /swapfile
Setting up swapspace version 1, size = 30 GiB (32212250624 bytes)
no label, UUID=...
INFO
MemTotal:        8058320 kB
SwapTotal:      31457276 kB
SwapFree:       31457276 kB
```
- Create a swapfile with the double of your memory ram
```sh
sena@vs:~/$ bash make-swapfile.sh
swapoff /swapfile
Setting up swapspace version 1, size = 16 GiB (17179865088 bytes)
no label, UUID=...
INFO
MemTotal:        8058320 kB
SwapTotal:      16777212 kB
SwapFree:       16777212 kB
```