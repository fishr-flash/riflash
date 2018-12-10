#!/usr/bin/python

# multythreading flash policy-free tunnel
# written by Michael Ochnev @ritm 2015-2016
# v.2.1.4

from socket import *
import logging
import threading
import httplib
import os
try:
    import json
except ImportError:
    import simplejson as json

def handler(clientsocket, clientaddr):
    l = 'Accepted connection from: ', clientaddr, ', total threads: ', threading.activeCount()
    #logger.info(l)

    while 1:
        data = ""
        try:
            data = clientsocket.recv(1024)
        except Exception, e:
            l = 'Exception getting data from client: ', e
            #logger.error(l)
            data = ''
            break
        if not data:
            #logger.error('No data from client')
            data = ''
            break
	if data == "":
            break
        elif "<policy-file-request/>\0" in data:
            clientsocket.send("""
                    <?xml version="1.0"?>
                    <cross-domain-policy>
                    <allow-access-from domain="*" to-ports="*"/>
                    </cross-domain-policy>""")
            clientsocket.close()
        else:
            try:
                r = json.loads(data)
            except BaseException:
                l = 'JSON parsing error: ', data
                #logger.error(l)
            if 'decodelbs' in r['request']:
                arr = r['lbs'].split(',')
                if (len(arr) == 4):
                    hconn = httplib.HTTPConnection('mobile.maps.yandex.net')
                    hconn.request("GET", '/cellid_location/?&cellid='+arr[0]+'&operatorid='+arr[1]+'&countrycode='+arr[2]+'&lac='+arr[3])
                    r1 = hconn.getresponse()
                    xml = r1.read()
                try:
                    hconn.close()
                except BaseException:
				    l = "couldt close http connection"
                    #logger.error("could't close http connection")
                clientsocket.send(xml)
            elif 'decodewifi' in r['request']:
                hconn = httplib.HTTPConnection('mobile.maps.yandex.net')
                hconn.request("GET", '/cellid_location/?wifinetworks='+r['lbs'])
                r1 = hconn.getresponse()
                xml = r1.read()
                try:
                    hconn.close()
                except BaseException:
				    l = "couldt close http connection"
                    #logger.error("could't close http connection")
                clientsocket.send(xml)
            else:
                l = 'Unhandled request', r['request']
                #logger.error(l)
                clientsocket.send("bad request")

    clientsocket.close()
    #logger.info('client disconnected');
    #thread.exit()
    
 
if __name__ == "__main__":
 
    #logger = logging.getLogger('lbstunnel')
    #hdlr = logging.FileHandler('lbs.log')
    #formatter = logging.Formatter('%(asctime)s %(thread)d %(message)s')
    #hdlr.setFormatter(formatter)
    #logger.addHandler(hdlr) 
    #logger.setLevel(logging.INFO)

    host = ''
    port = 55572
    buf = 1024

    addr = (host, port)
    serversocket = socket(AF_INET, SOCK_STREAM)
    serversocket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    serversocket.bind(addr)
    serversocket.listen(50)

    while 1:
        try:
            clientsocket, clientaddr = serversocket.accept()
        except Exception, e:
            l = 'sockets exception: ', e
            #logger.error(l)
        else:
            try:
                t = threading.Thread(target=handler, args=(clientsocket, clientaddr))
            except Exception, e:
                l = 'error create thread', threading.activeCount(), e
                #logger.error(l)
            else:
                try:
                    t.start();
                except Exception, e:
                    l = 'error start ', threading.activeCount(), e
                    #logger.error(l)
    #logger.info('server close')
    serversocket.close()