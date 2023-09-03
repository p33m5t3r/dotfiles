#!/home/anon/.virtualenvs/general/bin/python

import sys
import subprocess

def pct_to_color(pct):
    COLORS = ['', '\033[93m', '\033[91m']
    ENDC = '\033[0m'
    color = COLORS[min(2, int(pct/33))]
    ec = ENDC if color else ''
    return color, ec

def get_time():
    from datetime import datetime
    import pytz
    fmt_long = lambda dt: dt.strftime("%-I:%M%p, %A %B %-d").lower()
    fmt_short = lambda dt: dt.strftime("%a %H:%M").lower()
    localtime = fmt_long(datetime.now())
    utc_time = fmt_short(datetime.now(pytz.UTC))
    return f"TIME::|{localtime} (utc:{utc_time}) [nyc-4 lon+1 ams+2 ind+5:30]|"

def get_btc_px():
    import requests
    try:
        r = requests.get('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd')
        return f"BTC::|${r.json().get('bitcoin').get('usd')}|"
    except:
        return "BTC::|unknown|"

def get_gpu_usage(use_colors=True):
    import GPUtil
    try:
        gpu = GPUtil.getGPUs()[0]
        color, ec = pct_to_color(gpu.load*100)
        load = f"{color}{gpu.load*100:.2f}%{ec}" if use_colors else f"{gpu.load*100:.2f}%"
        return f"GPU::|{load}|{gpu.memoryUsed/1000:.2f}/{int(gpu.memoryTotal/1000)}GiB|"
    except:
        return "GPU::|Offline|"

def get_cpu_usage(use_colors=True):
    try:
        cpu = subprocess.check_output("top -bn1 | grep 'load average'", shell=True, text=True).split(' ')
        load = list(map(lambda s: s.strip('\n').strip(','), [cpu[-3], cpu[-2], cpu[-1]]))
        norm_to_100 = lambda x: 4*x*x*x
        mult = float(load[0]) / float(load[1])
        color, ec = pct_to_color(norm_to_100(mult))
        load = f"{color}{load[0]}% {load[1]}% {load[2]}%{ec}" if use_colors else f"{load[0]}% {load[1]}% {load[1]}%"
        return f"CPU::|{load}|"
    except Exception as e:
        raise e
        return "CPU::|Offline|"

def get_disk_usage():
    try:
        disk_usage = subprocess.check_output("df -h", shell=True, text=True)
        disk_raw = [s for s in disk_usage.strip().split("\n")[1:] if s.endswith('/home')][0].split(' ')
        return f"DISK::|{disk_raw[4]}/{disk_raw[2]}|"
    except:
        return "DISK::|Offline|"

def get_ram_usage():
    try:
        ram_usage = subprocess.check_output("free -h", shell=True, text=True)
        out = [s for s in ram_usage.strip().split("\n")[1].split(' ') if s != '']
        print(out)
        free = out[1][:-2]
        used = out[2][:-2]
        return f"RAM::|{used}/{free}GiB|"

    except:
        return "RAM::|Offline|"

def get_inet_info():
    import json
    import requests
    try:
        raw = json.loads(subprocess.check_output(["ip", "-h", "-f", "inet", "-j", "addr"], text=True))
        local_addr = [i for i in raw if i.get('ifname') != 'lo'][0].get('addr_info')[0]
        local_str = f"{local_addr.get('local')}/{local_addr.get('prefixlen')}"
        wtfismyip = json.loads(requests.get('https://wtfismyip.com/json').text)
        extern_ip = wtfismyip.get('YourFuckingIPAddress') 
        extern_loc = f"{wtfismyip.get('YourFuckingCity')}, {wtfismyip.get('YourFuckingCountryCode')}"
        extern_str = f"{extern_ip} ({extern_loc})"
        return f"INET::|lo:{local_str}|pub:{extern_str}|"

    except:
        return "INET::|Offline|"

if __name__ == "__main__":
    actual_args = [arg for arg in sys.argv if (".py" not in arg and "python" not in arg)]
    if len(actual_args) < 1:
        print("Error: No arguments supplied!")
        exit(1)

    arg = actual_args[0]
    cmds = {"gpu": get_gpu_usage,
            "inet": get_inet_info,
            "btc": get_btc_px,
            "time": get_time,
            "ram": get_ram_usage,
            "cpu": get_cpu_usage,
            "disk": get_disk_usage
            }
    if arg not in cmds.keys():
        print("Error: invalid argument!")
        exit(1)

    print(cmds[arg]())

