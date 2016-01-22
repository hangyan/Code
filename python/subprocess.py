import subprocess32 as subprocess
child = subprocess.check_output(["ls","-l"], cwd='/dd')
print child
print("parent process")
