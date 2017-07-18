
import json
import requests
import time

#Creating HTTP header and API url endpoint

url='http://localhost:8000/predict'
headers = {'content-type': 'application/json'}

#File path

CSV_PATH = '/home/kevin/e.csv'

#Follow function to read new log entries

def follow(logfile):
    csv_file=open(logfile, 'r')
    csv_file.seek(0,1)
    while True:
        line = csv_file.readline()
        if not line:
            break
##            time.sleep(0.1)
##            continue
        yield line.strip('\n')
        
stream=follow(CSV_PATH)
times=[]

#Simulating an input streaming data

for line in stream:
    entry=[line.split(',') for line in stream]
    for l in entry:
        intentry=[int(x) for x in l]
        Arr_time,Del_Time,Byte_Size=intentry[0],intentry[1],intentry[2]
        
        #HTTP payload
        
        payload={"Arr_time":Arr_time,'Del_Time':Del_Time,"Byte_Size":Byte_Size}
        
        #Segment duration response
        
        start = time.time()
        response = requests.post(url,data=json.dumps(payload))
        print(response.json(),end='')
        stop= time.time()
        duration=stop-start
        times.append(duration)
        
print('The average time taken for a request-response cycle is %f milliseconds'%(sum(times)/len(times)))
        






