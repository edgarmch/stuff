def getFile(url, file_name):
	from urllib2 import Request, urlopen, URLError, HTTPError	
	req = Request(url)	
	try:
		f = urlopen(req)
		print "downloading... " + url
		local_file = open(str(index) + ".txt", "w")
                next(f, None)
                next(f, None)
                next(f, None)
                next(f, None)
		local_file.write(f.read())
		local_file.close()
	except HTTPError, e:
		print "HTTP Error:",e.code , url
	except URLError, e:
		print "URL Error:",e.reason , url

folder = range(1,5)

for index in folder:	
	base_url = 'http://smn.cna.gob.mx/'
	file_name =  "emas/txt/" + "DF0"+str(index)+"_24H.TXT"
        url = base_url + file_name
	getFile(url, index)
