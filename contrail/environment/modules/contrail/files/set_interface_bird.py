import sys, argparse
import subprocess

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--ip_list', nargs = '+', help = 'list of comma separated ip addresses')
    return parser.parse_args()

def main():
    args = parse_args()
    if not args.ip_list:
        print "ERROR: no ip addresses specified"
        sys.exit(255)
    lines = ''
    i = 101
    fh = open('/etc/network/interfaces', 'a+')
    fh.seek(0)
    text = fh.read()
    ip_set = set(args.ip_list)
    for ip in ip_set:
        intf = "lo:%d" %i
        i += 1
        if intf in text:
            continue
        lines = lines + "\nauto %s\n" %intf
        lines = lines + "  iface %s inet static\n" %intf
        lines = lines + "  address %s\n" %ip
        lines = lines + "  netmask 255.255.255.255"
    fh.writelines(lines)
    fh.close()
    for x in range(len(ip_set)):
        subprocess.Popen('ifup lo:%d' %(101+x), shell = True)

if __name__ == "__main__":
    main()

