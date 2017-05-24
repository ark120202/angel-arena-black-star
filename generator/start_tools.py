import time, os, sys, getopt
addonName = 'angelarenablackstar'

def main(argv):
	dotaPath = 'G:/Program Files/Steam/steamapps/common/dota 2 beta'
	mode = 0
	try:
		opts, args = getopt.getopt(argv, 'hd:m:')
	except getopt.GetoptError:
		print('start_tools.py -d <dotaPath>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('start_tools.py -d <dotaPath> [-m <mode>]')
			sys.exit()
		elif opt == "-d":
			dotaPath = arg
		elif opt == "-m":
			mode = arg
	dotaPath += '/game'
	addonsDir = dotaPath + '/dota_addons/'

	if mode == 0 or mode == 1:
		#Rename old symlink
		os.rename(addonsDir + addonName, addonsDir + '___' + addonName)

		#Make dummy directory, so dota can index it
		os.makedirs(addonsDir + addonName)
	if mode == 0:
		# We don't need annoying steam_appid.txt in cwd
		os.chdir(dotaPath + '/bin/win64')
		#Run tools
		os.startfile(dotaPath + '/bin/win64/dota2cfg.exe')
		time.sleep(1)
		#app = Application(backend='uia').connect(path='dota2cfg.exe', title='Dota 2 Workshop Tools')
	if mode == 0 or mode == 2:
		# Remove dummy directory
		os.rmdir(addonsDir + addonName)

		#Bring your link back
		os.rename(addonsDir + '___' + addonName, addonsDir + addonName)

if __name__ == "__main__":
	main(sys.argv[1:])
