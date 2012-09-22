import sys

def fix_tab(filename):
	out = []
	for line in open(filename):
		stripped = line.lstrip(' ')
		out.append('\t'*((len(line)-len(stripped))/2) + stripped)

	open(filename, 'w').write(''.join(out))

if __name__ == '__main__':
	if len(sys.argv) < 1:
		print 'usage: fix_tab <filename>'
	else:
		fix_tab(sys.argv[1])
